# CBSA COBOL Coding Standards - Code Examples

This file provides additional code examples extracted from the CICS Banking Sample Application codebase.

## Table of Contents

1. [Complete Program Examples](#complete-program-examples)
2. [Error Handling Patterns](#error-handling-patterns)
3. [DB2 Integration Examples](#db2-integration-examples)
4. [CICS Integration Examples](#cics-integration-examples)
5. [Data Structure Examples](#data-structure-examples)
6. [Common Anti-Patterns](#common-anti-patterns)

## Complete Program Examples

### Simple Utility Program (GETCOMPY.cbl)

```cobol
       CBL CICS('SP,EDF')
      ******************************************************************
      *                                                                *
      *  Copyright IBM Corp. 2023                                      *
      *                                                                *
      ******************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID. GETCOMPY.
       AUTHOR. James O'Grady.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  IBM-370.
       OBJECT-COMPUTER.  IBM-370.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01 DFHCOMMAREA.
           COPY GETCOMPY.

       PROCEDURE DIVISION USING DFHCOMMAREA.
       PREMIERE SECTION.
       A010.
           MOVE 'CICS Bank Sample Application' TO COMPANY-NAME.

           EXEC CICS RETURN
           END-EXEC.

           GOBACK.
```

**Key Points:**
- Minimal structure for simple utility
- Standard divisions and sections
- COMMAREA-based interface
- Clean CICS RETURN

### BMS Handler Program Structure (BNKMENU.cbl excerpt)

```cobol
       PROCESS CICS,NODYNAM,NSYMBOL(NATIONAL),TRUNC(STD)
       CBL CICS('SP,EDF')
      ******************************************************************
      * This is the BANK MENU (i.e. the first program initiated by the
      * BMS suite). It displays the map and allows the user to select
      * an option, validates the option number/letter and returns with
      * the appropriate transaction.
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BNKMENU.
       AUTHOR. Jon Collett.

       [...]

       WORKING-STORAGE SECTION.

       01 WS-CICS-WORK-AREA.
          03 WS-CICS-RESP              PIC S9(8) COMP VALUE 0.
          03 WS-CICS-RESP2             PIC S9(8) COMP VALUE 0.

       01 WS-FAIL-INFO.
          03 FILLER                    PIC X(9) VALUE 'BNKMENU  '.
          03 WS-CICS-FAIL-MSG          PIC X(70) VALUE ' '.
          03 FILLER                    PIC X(6)  VALUE ' RESP='.
          03 WS-CICS-RESP-DISP         PIC 9(10) VALUE 0.
          03 FILLER                    PIC X(7)  VALUE ' RESP2='.
          03 WS-CICS-RESP2-DISP        PIC 9(10) VALUE 0.
          03 FILLER                    PIC X(15) VALUE ' ABENDING TASK.'.

       01 SWITCHES.
           03 VALID-DATA-SW            PIC X VALUE 'Y'.
              88 VALID-DATA                VALUE 'Y'.

       01 FLAGS.
           03 SEND-FLAG                PIC X.
              88 SEND-ERASE              VALUE '1'.
              88 SEND-DATAONLY           VALUE '2'.
              88 SEND-DATAONLY-ALARM     VALUE '3'.

       COPY BNK1MAI.
       COPY DFHAID.

       01 WS-ABEND-PGM                 PIC X(8) VALUE 'ABNDPROC'.
       01 ABNDINFO-REC.
           COPY ABNDINFO.
```

**Key Points:**
- PROCESS statement for compiler options
- Comprehensive error message structure
- Level-88 conditions for flags
- BMS map copybooks
- Abend handling setup

## Error Handling Patterns

### CICS LINK with Error Handling

```cobol
      *
      *    We need to validate that the supplied CUSTOMER actually
      *    exists by linking to INQCUST.
      *
       MOVE COMM-CUSTNO IN DFHCOMMAREA TO INQCUST-CUSTNO.

       EXEC CICS LINK PROGRAM('INQCUST ')
                 COMMAREA(INQCUST-COMMAREA)
                 RESP(WS-CICS-RESP)
       END-EXEC.

      *
      *    If the link failed for some reason, or the link to INQCUST
      *    indicated that customer information could not be
      *    successfully retrieved then set fail flags and finished.
      *
       IF EIBRESP IS NOT EQUAL TO DFHRESP(NORMAL)
       OR INQCUST-INQ-SUCCESS IS NOT EQUAL TO 'Y'

         MOVE 'N' TO COMM-SUCCESS IN DFHCOMMAREA
         MOVE '1' TO COMM-FAIL-CODE IN DFHCOMMAREA

         PERFORM GET-ME-OUT-OF-HERE

       END-IF
```

**Key Points:**
- Clear comment explaining purpose
- RESP parameter on CICS command
- Check both CICS response and business logic success
- Set failure flags
- Use common exit paragraph

### Abend Handler Setup and Usage

```cobol
       WORKING-STORAGE SECTION.
       01 WS-ABEND-PGM                 PIC X(8) VALUE 'ABNDPROC'.
       01 ABNDINFO-REC.
           COPY ABNDINFO.

       PROCEDURE DIVISION USING DFHCOMMAREA.
       PREMIERE SECTION.
       A010.
           INITIALIZE OUTPUT-DATA.
      *
      *    Set up the abend handling
      *
           EXEC CICS HANDLE
              ABEND LABEL(ABEND-HANDLING)
           END-EXEC.

           [Main processing logic]

       ABEND-HANDLING.
           [Populate ABNDINFO-REC with error details]
           
           EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                     COMMAREA(ABNDINFO-REC)
           END-EXEC.
```

**Key Points:**
- Abend program name as constant
- ABNDINFO copybook for error details
- HANDLE ABEND at start of program
- Dedicated abend handling paragraph
- Link to centralized abend processor

### Named Counter Pattern (Complete)

```cobol
      *
      *    ENQ the Named Counter, increment it and take the new value
      *
       EXEC CICS ENQ RESOURCE(NCS-ACC-NO-NAME)
                 LENGTH(16)
                 RESP(WS-CICS-RESP)
       END-EXEC.

       IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
          [Handle ENQ failure]
       END-IF.

       ADD 1 TO NCS-ACC-NO-VALUE.
       MOVE NCS-ACC-NO-VALUE TO NCS-ACC-NO-DISP.

      *
      *    Now write the ACCOUNT record to DB2
      *
       PERFORM WRITE-ACCOUNT-DB2.

       IF SQLCODE NOT = 0
      *
      *    CRITICAL: If DB2 write failed, we must decrement the
      *    counter to restore it to the original state before DEQUEUE
      *
          SUBTRACT 1 FROM NCS-ACC-NO-VALUE
          
          EXEC CICS DEQ RESOURCE(NCS-ACC-NO-NAME)
                    LENGTH(16)
          END-EXEC
          
          MOVE 'N' TO COMM-SUCCESS
          MOVE '2' TO COMM-FAIL-CODE
          PERFORM GET-ME-OUT-OF-HERE
       END-IF.

      *
      *    Success - DEQUEUE the Named Counter
      *
       EXEC CICS DEQ RESOURCE(NCS-ACC-NO-NAME)
                 LENGTH(16)
       END-EXEC.
```

**Key Points:**
- ENQ before increment
- Check ENQ response
- Increment counter
- Attempt DB2 write
- **CRITICAL:** Decrement on failure before DEQUEUE
- DEQUEUE on success path

## DB2 Integration Examples

### Host Variable Declaration

```cobol
       WORKING-STORAGE SECTION.

      * Get the ACCOUNT DB2 copybook
           EXEC SQL
              INCLUDE ACCDB2
           END-EXEC.

      * ACCOUNT Host variables for DB2
       01 HOST-ACCOUNT-ROW.
          03 HV-ACCOUNT-EYECATCHER          PIC X(4).
          03 HV-ACCOUNT-CUST-NO             PIC X(10).
          03 HV-ACCOUNT-SORTCODE            PIC X(6).
          03 HV-ACCOUNT-ACC-NO              PIC X(8).
          03 HV-ACCOUNT-ACC-TYPE            PIC X(8).
          03 HV-ACCOUNT-INT-RATE            PIC S9(4)V99 COMP-3.
          03 HV-ACCOUNT-OPENED              PIC X(10).
          03 HV-ACCOUNT-OPENED-GROUP REDEFINES HV-ACCOUNT-OPENED.
             05 HV-ACCOUNT-OPENED-DAY       PIC XX.
             05 HV-ACCOUNT-OPENED-DELIM1    PIC X.
             05 HV-ACCOUNT-OPENED-MONTH     PIC XX.
             05 HV-ACCOUNT-OPENED-DELIM2    PIC X.
             05 HV-ACCOUNT-OPENED-YEAR      PIC X(4).
          03 HV-ACCOUNT-OVERDRAFT-LIM       PIC S9(9) COMP.
          03 HV-ACCOUNT-LAST-STMT           PIC X(10).
          03 HV-ACCOUNT-AVAIL-BAL           PIC S9(10)V99 COMP-3.
          03 HV-ACCOUNT-ACTUAL-BAL          PIC S9(10)V99 COMP-3.

      * Pull in the SQL COMMAREA
        EXEC SQL
          INCLUDE SQLCA
        END-EXEC.
```

**Key Points:**
- EXEC SQL INCLUDE for DB2 copybooks
- HV- prefix for host variables
- REDEFINES for date parsing
- Appropriate COMP types for numeric fields
- SQLCA for error information

### Cursor Declaration and Usage

```cobol
      * Declare the CURSOR for ACCOUNT table
           EXEC SQL DECLARE ACC-CURSOR CURSOR FOR
              SELECT ACCOUNT_EYECATCHER,
                     ACCOUNT_CUSTOMER_NUMBER,
                     ACCOUNT_SORTCODE,
                     ACCOUNT_NUMBER,
                     ACCOUNT_TYPE,
                     ACCOUNT_INTEREST_RATE,
                     ACCOUNT_OPENED,
                     ACCOUNT_OVERDRAFT_LIMIT,
                     ACCOUNT_LAST_STATEMENT,
                     ACCOUNT_NEXT_STATEMENT,
                     ACCOUNT_AVAILABLE_BALANCE,
                     ACCOUNT_ACTUAL_BALANCE
                     FROM ACCOUNT
                     WHERE ACCOUNT_SORTCODE = :HV-ACCOUNT-SORTCODE
                       AND ACCOUNT_NUMBER = :HV-ACCOUNT-ACC-NO
                     FOR FETCH ONLY
           END-EXEC.

       [In PROCEDURE DIVISION:]

       EXEC SQL
          OPEN ACC-CURSOR
       END-EXEC.

       IF SQLCODE NOT = 0
          [Handle error]
       END-IF.

       EXEC SQL
          FETCH ACC-CURSOR
          INTO :HV-ACCOUNT-EYECATCHER,
               :HV-ACCOUNT-CUST-NO,
               :HV-ACCOUNT-SORTCODE,
               [...]
       END-EXEC.

       IF SQLCODE NOT = 0
          [Handle error]
       END-IF.

       EXEC SQL
          CLOSE ACC-CURSOR
       END-EXEC.
```

**Key Points:**
- Cursor declared in WORKING-STORAGE
- FOR FETCH ONLY for read-only cursors
- Host variables with colon prefix in SQL
- Check SQLCODE after each operation
- Always close cursor

### DB2 INSERT Operation

```cobol
       WRITE-ACCOUNT-DB2.

           MOVE 'ACCT'                  TO HV-ACCOUNT-EYECATCHER.
           MOVE COMM-CUSTNO             TO HV-ACCOUNT-CUST-NO.
           MOVE SORTCODE                TO HV-ACCOUNT-SORTCODE.
           MOVE ACCOUNT-NUMBER          TO HV-ACCOUNT-ACC-NO.
           MOVE COMM-ACC-TYPE           TO HV-ACCOUNT-ACC-TYPE.
           MOVE COMM-INT-RATE           TO HV-ACCOUNT-INT-RATE.
           MOVE WS-ORIG-DATE            TO HV-ACCOUNT-OPENED.
           MOVE COMM-OVERDRAFT          TO HV-ACCOUNT-OVERDRAFT-LIM.
           MOVE WS-ORIG-DATE            TO HV-ACCOUNT-LAST-STMT.
           MOVE WS-FUTURE-CONV          TO HV-ACCOUNT-NEXT-STMT.
           MOVE COMM-AVAIL-BAL          TO HV-ACCOUNT-AVAIL-BAL.
           MOVE COMM-ACTUAL-BAL         TO HV-ACCOUNT-ACTUAL-BAL.

           EXEC SQL
              INSERT INTO ACCOUNT
                 (ACCOUNT_EYECATCHER,
                  ACCOUNT_CUSTOMER_NUMBER,
                  ACCOUNT_SORTCODE,
                  ACCOUNT_NUMBER,
                  ACCOUNT_TYPE,
                  ACCOUNT_INTEREST_RATE,
                  ACCOUNT_OPENED,
                  ACCOUNT_OVERDRAFT_LIMIT,
                  ACCOUNT_LAST_STATEMENT,
                  ACCOUNT_NEXT_STATEMENT,
                  ACCOUNT_AVAILABLE_BALANCE,
                  ACCOUNT_ACTUAL_BALANCE)
              VALUES
                 (:HV-ACCOUNT-EYECATCHER,
                  :HV-ACCOUNT-CUST-NO,
                  :HV-ACCOUNT-SORTCODE,
                  :HV-ACCOUNT-ACC-NO,
                  :HV-ACCOUNT-ACC-TYPE,
                  :HV-ACCOUNT-INT-RATE,
                  :HV-ACCOUNT-OPENED,
                  :HV-ACCOUNT-OVERDRAFT-LIM,
                  :HV-ACCOUNT-LAST-STMT,
                  :HV-ACCOUNT-NEXT-STMT,
                  :HV-ACCOUNT-AVAIL-BAL,
                  :HV-ACCOUNT-ACTUAL-BAL)
           END-EXEC.

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO WS-SQLCODE-DISP
              DISPLAY 'WRITE-ACCOUNT-DB2 SQLCODE=' WS-SQLCODE-DISP
           END-IF.
```

**Key Points:**
- Populate host variables first
- Column names and values aligned
- Host variables with colon prefix
- Check SQLCODE after INSERT
- Display error for debugging

### DB2 UPDATE Operation

```cobol
       UPDATE-ACCOUNT-DB2.

           EXEC SQL
              UPDATE ACCOUNT
              SET ACCOUNT_AVAILABLE_BALANCE = :HV-ACCOUNT-AVAIL-BAL,
                  ACCOUNT_ACTUAL_BALANCE = :HV-ACCOUNT-ACTUAL-BAL
              WHERE ACCOUNT_SORTCODE = :HV-ACCOUNT-SORTCODE
                AND ACCOUNT_NUMBER = :HV-ACCOUNT-ACC-NO
           END-EXEC.

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO WS-SQLCODE-DISP
              DISPLAY 'UPDATE-ACCOUNT-DB2 SQLCODE=' WS-SQLCODE-DISP
           END-IF.
```

## CICS Integration Examples

### BMS Map Send/Receive

```cobol
       SEND-MAP.
           IF SEND-ERASE
              EXEC CICS SEND MAP('BNK1MA')
                        MAPSET('BNK1MAI')
                        FROM(BNK1MAO)
                        ERASE
                        RESP(WS-CICS-RESP)
              END-EXEC
           END-IF.

           IF SEND-DATAONLY
              EXEC CICS SEND MAP('BNK1MA')
                        MAPSET('BNK1MAI')
                        FROM(BNK1MAO)
                        DATAONLY
                        RESP(WS-CICS-RESP)
              END-EXEC
           END-IF.

       RECEIVE-MAP.
           EXEC CICS RECEIVE MAP('BNK1MA')
                     MAPSET('BNK1MAI')
                     INTO(BNK1MAI)
                     RESP(WS-CICS-RESP)
           END-EXEC.

           IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
              [Handle error]
           END-IF.
```

**Key Points:**
- Use level-88 conditions for send options
- ERASE vs DATAONLY options
- RESP checking on all commands
- Separate FROM and INTO areas

### Program Return Patterns

```cobol
      * Return to CICS with COMMAREA
       GET-ME-OUT-OF-HERE.
           EXEC CICS RETURN
           END-EXEC.

           GOBACK.

      * Return with transaction ID
       RETURN-TO-PREV-SCREEN.
           EXEC CICS RETURN TRANSID('OMEN')
                     COMMAREA(COMMUNICATION-AREA)
           END-EXEC.

           GOBACK.
```

## Data Structure Examples

### Date Handling with REDEFINES

```cobol
       01 WS-ORIG-DATE                 PIC X(10).
       01 WS-ORIG-DATE-GRP REDEFINES WS-ORIG-DATE.
          03 WS-ORIG-DATE-DD           PIC 99.
          03 FILLER                    PIC X.
          03 WS-ORIG-DATE-MM           PIC 99.
          03 FILLER                    PIC X.
          03 WS-ORIG-DATE-YYYY         PIC 9999.

       01 WS-ORIG-DATE-GRP-X.
          03 WS-ORIG-DATE-DD-X         PIC XX.
          03 FILLER                    PIC X VALUE '.'.
          03 WS-ORIG-DATE-MM-X         PIC XX.
          03 FILLER                    PIC X VALUE '.'.
          03 WS-ORIG-DATE-YYYY-X       PIC X(4).
```

**Usage:**
```cobol
       EXEC CICS ASKTIME ABSTIME(WS-U-TIME)
       END-EXEC.

       EXEC CICS FORMATTIME ABSTIME(WS-U-TIME)
                 DDMMYYYY(WS-ORIG-DATE)
                 DATESEP
       END-EXEC.

       MOVE WS-ORIG-DATE-DD TO WS-ORIG-DATE-DD-X.
       MOVE WS-ORIG-DATE-MM TO WS-ORIG-DATE-MM-X.
       MOVE WS-ORIG-DATE-YYYY TO WS-ORIG-DATE-YYYY-X.
```

### Time Handling

```cobol
       01 WS-TIME-DATA.
           03 WS-TIME-NOW              PIC 9(6).
           03 WS-TIME-NOW-GRP REDEFINES WS-TIME-NOW.
              05 WS-TIME-NOW-GRP-HH       PIC 99.
              05 WS-TIME-NOW-GRP-MM       PIC 99.
              05 WS-TIME-NOW-GRP-SS       PIC 99.
```

**Usage:**
```cobol
       EXEC CICS ASKTIME ABSTIME(WS-U-TIME)
       END-EXEC.

       EXEC CICS FORMATTIME ABSTIME(WS-U-TIME)
                 TIME(WS-TIME-NOW)
       END-EXEC.
```

### Copybook with Level-88 Conditions

```cobol
       01 DATA-STORE-TYPE              PIC X.
          88 DATASTORE-TYPE-DLI        VALUE '1'.
          88 DATASTORE-TYPE-DB2        VALUE '2'.
          88 DATASTORE-TYPE-VSAM       VALUE 'V'.
```

**Usage:**
```cobol
       SET DATASTORE-TYPE-DB2 TO TRUE.

       IF DATASTORE-TYPE-DB2
          PERFORM DB2-PROCESSING
       END-IF.
```

## Common Anti-Patterns

### Anti-Pattern 1: Missing RESP Checking

❌ **Bad:**
```cobol
       EXEC CICS LINK PROGRAM('INQCUST')
                 COMMAREA(INQCUST-COMMAREA)
       END-EXEC.
```

✅ **Good:**
```cobol
       EXEC CICS LINK PROGRAM('INQCUST')
                 COMMAREA(INQCUST-COMMAREA)
                 RESP(WS-CICS-RESP)
       END-EXEC.

       IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
          [Handle error]
       END-IF.
```

### Anti-Pattern 2: Missing SQLCODE Checking

❌ **Bad:**
```cobol
       EXEC SQL
          INSERT INTO ACCOUNT VALUES (...)
       END-EXEC.
```

✅ **Good:**
```cobol
       EXEC SQL
          INSERT INTO ACCOUNT VALUES (...)
       END-EXEC.

       IF SQLCODE NOT = 0
          MOVE SQLCODE TO WS-SQLCODE-DISP
          [Handle error]
       END-IF.
```

### Anti-Pattern 3: Incorrect Named Counter Pattern

❌ **Bad:**
```cobol
       EXEC CICS ENQ RESOURCE(NCS-ACC-NO-NAME) LENGTH(16) END-EXEC.
       ADD 1 TO NCS-ACC-NO-VALUE.
       PERFORM WRITE-ACCOUNT-DB2.
       EXEC CICS DEQ RESOURCE(NCS-ACC-NO-NAME) LENGTH(16) END-EXEC.
```

✅ **Good:**
```cobol
       EXEC CICS ENQ RESOURCE(NCS-ACC-NO-NAME) LENGTH(16)
                 RESP(WS-CICS-RESP)
       END-EXEC.
       
       IF WS-CICS-RESP = DFHRESP(NORMAL)
          ADD 1 TO NCS-ACC-NO-VALUE
          PERFORM WRITE-ACCOUNT-DB2
          
          IF SQLCODE NOT = 0
             SUBTRACT 1 FROM NCS-ACC-NO-VALUE
          END-IF
          
          EXEC CICS DEQ RESOURCE(NCS-ACC-NO-NAME) LENGTH(16) END-EXEC
       END-IF.
```

### Anti-Pattern 4: Cryptic Variable Names

❌ **Bad:**
```cobol
       01 CR.
          03 ID              PIC 9(8).
          03 NM              PIC X(50).
          03 BAL             PIC S9(9)V99 COMP-3.
```

✅ **Good:**
```cobol
       01 WS-CUSTOMER-RECORD.
          03 WS-CUST-ID          PIC 9(8).
          03 WS-CUST-NAME        PIC X(50).
          03 WS-CUST-BALANCE     PIC S9(9)V99 COMP-3.
```

### Anti-Pattern 5: Missing Comments

❌ **Bad:**
```cobol
       MOVE COMM-CUSTNO TO INQCUST-CUSTNO.
       EXEC CICS LINK PROGRAM('INQCUST') COMMAREA(INQCUST-COMMAREA)
                 RESP(WS-CICS-RESP)
       END-EXEC.
```

✅ **Good:**
```cobol
      *
      *    Validate that the supplied CUSTOMER exists by linking
      *    to INQCUST inquiry program
      *
       MOVE COMM-CUSTNO TO INQCUST-CUSTNO.
       
       EXEC CICS LINK PROGRAM('INQCUST')
                 COMMAREA(INQCUST-COMMAREA)
                 RESP(WS-CICS-RESP)
       END-EXEC.
```

## Summary

These examples demonstrate the coding standards in practice from the CICS Banking Sample Application. Key takeaways:

1. **Always check return codes** (RESP, SQLCODE)
2. **Use descriptive names** with proper prefixes
3. **Comment business logic**, not obvious code
4. **Follow the Named Counter pattern** exactly
5. **Structure programs consistently**
6. **Use copybooks** for shared data
7. **Handle errors gracefully**
8. **Use level-88 conditions** for boolean flags
9. **Apply proper data types** (COMP, COMP-3)
10. **Document critical patterns** in comments

Refer to the actual source files for complete context and additional patterns.