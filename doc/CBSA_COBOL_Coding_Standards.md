# CICS Banking Sample Application - COBOL Coding Standards

**Version:** 1.0  
**Last Updated:** 2026-06-08  
**Applies To:** IBM Enterprise COBOL for z/OS

---

## Table of Contents

1. [Introduction](#introduction)
2. [File Organization](#file-organization)
3. [Compiler Directives](#compiler-directives)
4. [Program Structure](#program-structure)
5. [Naming Conventions](#naming-conventions)
6. [Data Division Standards](#data-division-standards)
7. [Procedure Division Standards](#procedure-division-standards)
8. [CICS Programming Standards](#cics-programming-standards)
9. [DB2 SQL Standards](#db2-sql-standards)
10. [Error Handling](#error-handling)
11. [Comments and Documentation](#comments-and-documentation)
12. [Copybook Usage](#copybook-usage)
13. [Code Formatting](#code-formatting)

---

## 1. Introduction

This document defines the COBOL coding standards for the CICS Banking Sample Application (CBSA). These standards ensure consistency, maintainability, and quality across the codebase.

### 1.1 Purpose

- Establish consistent coding practices
- Improve code readability and maintainability
- Facilitate code reviews and knowledge transfer
- Ensure compatibility with IBM Enterprise COBOL for z/OS

### 1.2 Scope

These standards apply to all COBOL programs in the CBSA project, including:
- CICS transaction programs
- Batch programs
- Utility programs
- Subroutines

---

## 2. File Organization

### 2.1 Source File Structure

**Standard:**
```cobol
       [Compiler Directives]
       [Copyright Header]
       [Program Description]
       IDENTIFICATION DIVISION.
       PROGRAM-ID. [program-name].
       AUTHOR. [author-name].

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  IBM-370.
       OBJECT-COMPUTER.  IBM-370.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       [FILE SECTION.]
       WORKING-STORAGE SECTION.
       [LOCAL-STORAGE SECTION.]
       LINKAGE SECTION.

       PROCEDURE DIVISION [USING DFHCOMMAREA].
```

### 2.2 File Naming

- **Programs:** 8 characters maximum, uppercase
  - Example: `CREACC.cbl`, `BNKMENU.cbl`, `UPDACC.cbl`
- **Copybooks:** Descriptive names with `.cpy` extension
  - Example: `ACCOUNT.cpy`, `SORTCODE.cpy`, `ABNDINFO.cpy`

---

## 3. Compiler Directives

### 3.1 Required Directives

**For CICS Programs:**
```cobol
       CBL CICS('SP,EDF')
```

**For CICS Programs with DB2:**
```cobol
       CBL CICS('SP,EDF')
       CBL SQL
```

**For Programs with Advanced Features:**
```cobol
       PROCESS CICS,NODYNAM,NSYMBOL(NATIONAL),TRUNC(STD)
       CBL CICS('SP,EDF')
```

### 3.2 Directive Placement

- Place compiler directives at the very beginning of the source file
- Place before copyright header
- Use separate lines for each directive type

**Example from UPDACC.cbl:**
```cobol
       PROCESS CICS,NODYNAM,NSYMBOL(NATIONAL),TRUNC(STD)
       CBL CICS('SP,EDF,DLI')
       CBL SQL
```

---

## 4. Program Structure

### 4.1 Copyright Header

**Standard Format:**
```cobol
      ******************************************************************
      *                                                                *
      *  Copyright IBM Corp. 2023                                      *
      *                                                                *
      ******************************************************************
```

### 4.2 Program Description

**Standard Format:**
```cobol
      ******************************************************************
      * [Brief program description - what it does]
      *
      * [Detailed description of functionality]
      *
      * [Input/Output description]
      *
      * [Special considerations or business rules]
      *
      ******************************************************************
```

**Example from UPDACC.cbl:**
```cobol
      ******************************************************************
      * This program gets called when someone updates the account
      * details (this excludes the balance which must be updated by
      * crediting or debitting money to/from the account).
      *
      * The program receives as input all of the fields which make
      * up the Account record.
      *
      * It then accesses DB2 datastore & updates the associated
      * Account record.
      *
      * Because it is only permissible to change a limited number of
      * fields on the Account record, and it is NOT possible to amend
      * the balance, no record needs to be written to PR0CTRAN (as the
      * the balance cannot be amended using this method).
      *
      * If the Account cannot be updated then a failure flag is returned
      * to the calling program.
      *
      ******************************************************************
```

### 4.3 IDENTIFICATION DIVISION

**Standard:**
```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. [PROGRAM-NAME].
       AUTHOR. [Author Name].
```

- Program name must match filename (without extension)
- Always include AUTHOR clause
- Use consistent author name format

### 4.4 ENVIRONMENT DIVISION

**Standard:**
```cobol
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
      *SOURCE-COMPUTER.   IBM-370 WITH DEBUGGING MODE.
       SOURCE-COMPUTER.  IBM-370.
       OBJECT-COMPUTER.  IBM-370.

       INPUT-OUTPUT SECTION.
```

- Comment out debugging mode in production code
- Always include INPUT-OUTPUT SECTION even if empty

---

## 5. Naming Conventions

### 5.1 Program Names

- **Format:** 8 characters maximum, uppercase
- **Pattern:** Descriptive abbreviation
- **Examples:**
  - `CREACC` - Create Account
  - `UPDACC` - Update Account
  - `DELACC` - Delete Account
  - `INQACC` - Inquire Account
  - `BNKMENU` - Bank Menu

### 5.2 Variable Names

#### 5.2.1 Prefixes

| Prefix | Purpose | Example |
|--------|---------|---------|
| `WS-` | Working Storage variables | `WS-CICS-RESP` |
| `HV-` | Host Variables (DB2) | `HV-ACCOUNT-ACC-NO` |
| `COMM-` | Communication Area fields | `COMM-CUSTNO` |
| `ABND-` | Abend handling fields | `ABND-RESPCODE` |

#### 5.2.2 Structure

**Standard:**
```cobol
       01 [PREFIX]-[ENTITY]-[ATTRIBUTE].
          03 [PREFIX]-[ENTITY]-[SUB-ATTRIBUTE]  PIC X(n).
```

**Examples:**
```cobol
       01 WS-CICS-WORK-AREA.
          03 WS-CICS-RESP              PIC S9(8) COMP.
          03 WS-CICS-RESP2             PIC S9(8) COMP.

       01 HOST-ACCOUNT-ROW.
          03 HV-ACCOUNT-EYECATCHER     PIC X(4).
          03 HV-ACCOUNT-CUST-NO        PIC X(10).
          03 HV-ACCOUNT-SORTCODE       PIC X(6).
          03 HV-ACCOUNT-ACC-NO         PIC X(8).
```

### 5.3 Section and Paragraph Names

#### 5.3.1 Section Names

**Format:** Descriptive name in UPPERCASE with SECTION suffix

**Examples:**
```cobol
       PREMIERE SECTION.
       UPDATE-ACCOUNT-DB2 SECTION.
       GET-ME-OUT-OF-HERE SECTION.
       POPULATE-TIME-DATE SECTION.
```

#### 5.3.2 Paragraph Names

**Format:** Section abbreviation + sequential number

**Pattern:**
```cobol
       [SECTION-ABBREV][SEQUENCE].
```

**Examples:**
```cobol
       PREMIERE SECTION.
       A010.
           [code]
       A999.
           EXIT.

       UPDATE-ACCOUNT-DB2 SECTION.
       UAD010.
           [code]
       UAD999.
           EXIT.
```

**Standard Sequence:**
- `010` - First paragraph (main logic)
- `999` - Exit paragraph (always present)
- Intermediate numbers (020, 030, etc.) for additional paragraphs

### 5.4 Level Numbers

**Standard Usage:**
```cobol
       01  - Top-level group or elementary item
       03  - First-level subordinate
       05  - Second-level subordinate
       07  - Third-level subordinate
       77  - Independent elementary item
       88  - Condition name
```

**Example:**
```cobol
       01 ACCOUNT-KEY.
          03 ACCOUNT-SORT-CODE       PIC 9(6).
          03 ACCOUNT-NUMBER          PIC 9(8).

       77 SORTCODE                   PIC 9(6) VALUE 987654.

       01 FLAGS.
          03 SEND-FLAG               PIC X.
             88 SEND-ERASE              VALUE '1'.
             88 SEND-DATAONLY           VALUE '2'.
```

---

## 6. Data Division Standards

### 6.1 WORKING-STORAGE SECTION

#### 6.1.1 Organization

**Standard Order:**
1. Copybooks (SORTCODE, etc.)
2. DB2 includes (EXEC SQL INCLUDE)
3. Host variable structures
4. SQLCA include
5. CICS work areas
6. Application-specific data structures
7. Utility variables
8. Abend handling structures

**Example:**
```cobol
       WORKING-STORAGE SECTION.

       COPY SORTCODE.

       77 SYSIDERR-RETRY                PIC 999.

      * Get the ACCOUNT DB2 copybook
           EXEC SQL
              INCLUDE ACCDB2
           END-EXEC.

      * ACCOUNT Host variables for DB2
       01 HOST-ACCOUNT-ROW.
          03 HV-ACCOUNT-EYECATCHER      PIC X(4).
          03 HV-ACCOUNT-CUST-NO         PIC X(10).

      * Pull in the SQL COMMAREA
        EXEC SQL
          INCLUDE SQLCA
        END-EXEC.

       01 WS-CICS-WORK-AREA.
          05 WS-CICS-RESP               PIC S9(8) COMP.
          05 WS-CICS-RESP2              PIC S9(8) COMP.

       01 WS-ABEND-PGM                  PIC X(8) VALUE 'ABNDPROC'.

       01 ABNDINFO-REC.
           COPY ABNDINFO.
```

#### 6.1.2 Host Variables for DB2

**Standard Naming:**
- Prefix: `HV-` or `HOST-`
- Structure name: `HOST-[TABLE]-ROW`
- Field names: `HV-[TABLE]-[COLUMN]`

**Example:**
```cobol
       01 HOST-ACCOUNT-ROW.
          03 HV-ACCOUNT-EYECATCHER      PIC X(4).
          03 HV-ACCOUNT-CUST-NO         PIC X(10).
          03 HV-ACCOUNT-KEY.
             05 HV-ACCOUNT-SORTCODE     PIC X(6).
             05 HV-ACCOUNT-ACC-NO       PIC X(8).
          03 HV-ACCOUNT-ACC-TYPE        PIC X(8).
          03 HV-ACCOUNT-INT-RATE        PIC S9(4)V99 COMP-3.
```

#### 6.1.3 Date/Time Structures

**Standard Pattern:**
```cobol
       01 WS-U-TIME                     PIC S9(15) COMP-3.
       01 WS-ORIG-DATE                  PIC X(10).
       01 WS-ORIG-DATE-GRP REDEFINES WS-ORIG-DATE.
          03 WS-ORIG-DATE-DD            PIC 99.
          03 FILLER                     PIC X.
          03 WS-ORIG-DATE-MM            PIC 99.
          03 FILLER                     PIC X.
          03 WS-ORIG-DATE-YYYY          PIC 9999.

       01 WS-TIME-DATA.
          03 WS-TIME-NOW                PIC 9(6).
          03 WS-TIME-NOW-GRP REDEFINES WS-TIME-NOW.
             05 WS-TIME-NOW-GRP-HH      PIC 99.
             05 WS-TIME-NOW-GRP-MM      PIC 99.
             05 WS-TIME-NOW-GRP-SS      PIC 99.
```

#### 6.1.4 DB2 Date Reformatting

**Standard Pattern:**
```cobol
       01 DB2-DATE-REFORMAT.
          03 DB2-DATE-REF-YR            PIC 9(4).
          03 FILLER                     PIC X.
          03 DB2-DATE-REF-MNTH          PIC 99.
          03 FILLER                     PIC X.
          03 DB2-DATE-REF-DAY           PIC 99.
```

### 6.2 LOCAL-STORAGE SECTION

**Usage:**
- Use for data that should be reinitialized on each program invocation
- Preferred for recursive programs or programs called multiple times

**Example:**
```cobol
       LOCAL-STORAGE SECTION.
       01 DB2-DATE-REFORMAT.
          03 DB2-DATE-REF-YR            PIC 9(4).
          03 FILLER                     PIC X.
          03 DB2-DATE-REF-MNTH          PIC 99.
          03 FILLER                     PIC X.
          03 DB2-DATE-REF-DAY           PIC 99.
```

### 6.3 LINKAGE SECTION

**Standard:**
```cobol
       LINKAGE SECTION.
       01 DFHCOMMAREA.
           COPY [COMMAREA-COPYBOOK].
```

**Alternative with REPLACING:**
```cobol
       LINKAGE SECTION.
       COPY DELACC REPLACING DELACC-COMMAREA BY DFHCOMMAREA.
```

---

## 7. Procedure Division Standards

### 7.1 PROCEDURE DIVISION Header

**For CICS Programs:**
```cobol
       PROCEDURE DIVISION USING DFHCOMMAREA.
```

**For Non-CICS Programs:**
```cobol
       PROCEDURE DIVISION.
```

**For Batch Programs with Parameters:**
```cobol
       PROCEDURE DIVISION USING PARM-BUFFER.
```

### 7.2 Section Structure

**Standard Pattern:**
```cobol
       [SECTION-NAME] SECTION.
       [ABBREV]010.

           [Main logic here]

       [ABBREV]999.
           EXIT.
```

**Example:**
```cobol
       UPDATE-ACCOUNT-DB2 SECTION.
       UAD010.

           MOVE COMM-ACCNO TO DESIRED-ACC-NO.
           MOVE DESIRED-SORT-CODE TO HV-ACCOUNT-SORTCODE.

           EXEC SQL
              SELECT [columns]
              INTO [host-variables]
              FROM ACCOUNT
              WHERE [conditions]
           END-EXEC.

           IF SQLCODE NOT = 0
              MOVE 'N' TO COMM-SUCCESS
              GO TO UAD999
           END-IF.

       UAD999.
           EXIT.
```

### 7.3 PREMIERE SECTION

**Standard:**
- First section in PROCEDURE DIVISION
- Contains main program flow
- Calls other sections via PERFORM

**Example:**
```cobol
       PROCEDURE DIVISION USING DFHCOMMAREA.
       PREMIERE SECTION.
       A010.

           MOVE SORTCODE TO COMM-SCODE.
           MOVE SORTCODE TO DESIRED-SORT-CODE.

      *
      *    Update the account information
      *
           PERFORM UPDATE-ACCOUNT-DB2

      *
      *    The COMMAREA values have now been set so all we need to do
      *    is finish
      *

           PERFORM GET-ME-OUT-OF-HERE.

       A999.
           EXIT.
```

### 7.4 Program Termination

**Standard Section:**
```cobol
       GET-ME-OUT-OF-HERE SECTION.
       GMOOH010.

           EXEC CICS RETURN
           END-EXEC.

       GMOOH999.
           EXIT.
```

**Alternative for Subroutines:**
```cobol
       GET-ME-OUT-OF-HERE SECTION.
       GMOFH010.

           GOBACK.

       GMOFH999.
           EXIT.
```

### 7.5 Control Flow

#### 7.5.1 PERFORM Statements

**Preferred:**
```cobol
       PERFORM UPDATE-ACCOUNT-DB2.
       PERFORM WRITE-PROCTRAN.
```

**Avoid inline PERFORM unless very simple:**
```cobol
      * Acceptable for simple loops
       PERFORM VARYING WS-INDEX FROM 1 BY 1
           UNTIL WS-INDEX > 10
           [simple statement]
       END-PERFORM.
```

#### 7.5.2 GO TO Usage

**Acceptable Usage:**
- Error handling within a section
- Jumping to section exit paragraph

**Example:**
```cobol
       IF SQLCODE NOT = 0
          MOVE 'N' TO COMM-SUCCESS
          MOVE SQLCODE TO SQLCODE-DISPLAY
          DISPLAY 'ERROR: UPDACC returned ' SQLCODE-DISPLAY
          ' on SELECT'
          GO TO UAD999
       END-IF.
```

**Avoid:**
- GO TO statements across sections
- Complex GO TO logic that obscures program flow

#### 7.5.3 IF-THEN-ELSE

**Standard Format:**
```cobol
       IF [condition]
          [statements]
       END-IF.

       IF [condition]
          [statements]
       ELSE
          [statements]
       END-IF.
```

**Multi-line Conditions:**
```cobol
       IF (COMM-ACC-TYPE = SPACES OR 
           COMM-ACC-TYPE(1:1) = ' ')
          MOVE 'N' TO COMM-SUCCESS
          DISPLAY 'ERROR: UPDACC has invalid account-type'
          GO TO UAD999
       END-IF.
```

---

## 8. CICS Programming Standards

### 8.1 CICS Command Format

**Standard:**
```cobol
       EXEC CICS [COMMAND]
            [OPTION1(value1)]
            [OPTION2(value2)]
            RESP(WS-CICS-RESP)
            RESP2(WS-CICS-RESP2)
       END-EXEC.
```

**Example:**
```cobol
       EXEC CICS LINK PROGRAM('INQCUST ')
                 COMMAREA(INQCUST-COMMAREA)
                 RESP(WS-CICS-RESP)
       END-EXEC.
```

### 8.2 Response Code Checking

**Standard Pattern:**
```cobol
       01 WS-CICS-WORK-AREA.
          05 WS-CICS-RESP              PIC S9(8) COMP.
          05 WS-CICS-RESP2             PIC S9(8) COMP.

       [In PROCEDURE DIVISION:]

       EXEC CICS [COMMAND]
            RESP(WS-CICS-RESP)
            RESP2(WS-CICS-RESP2)
       END-EXEC.

       IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
          [error handling]
       END-IF.
```

**Alternative using EIBRESP:**
```cobol
       IF EIBRESP IS NOT EQUAL TO DFHRESP(NORMAL)
          [error handling]
       END-IF.
```

### 8.3 Common CICS Commands

#### 8.3.1 RETURN

**Standard:**
```cobol
       EXEC CICS RETURN
       END-EXEC.
```

**With TRANSID:**
```cobol
       EXEC CICS RETURN
            TRANSID('MENU')
            COMMAREA(COMMUNICATION-AREA)
            RESP(WS-CICS-RESP)
            RESP2(WS-CICS-RESP2)
       END-EXEC.
```

#### 8.3.2 LINK

**Standard:**
```cobol
       EXEC CICS LINK PROGRAM([program-name])
                 COMMAREA([commarea-name])
                 RESP(WS-CICS-RESP)
       END-EXEC.
```

#### 8.3.3 ASKTIME/FORMATTIME

**Standard Pattern:**
```cobol
       EXEC CICS ASKTIME
          ABSTIME(WS-U-TIME)
       END-EXEC.

       EXEC CICS FORMATTIME
                 ABSTIME(WS-U-TIME)
                 DDMMYYYY(WS-ORIG-DATE)
                 TIME(WS-TIME-NOW)
                 DATESEP
       END-EXEC.
```

### 8.4 ENQ/DEQ Pattern (Named Counters)

**Critical Pattern for Account/Customer Number Generation:**

```cobol
      * Enqueue the named counter
       EXEC CICS ENQ
            RESOURCE([counter-name])
            LENGTH([length])
            RESP(WS-CICS-RESP)
            RESP2(WS-CICS-RESP2)
       END-EXEC.

      * Read and increment counter
       [counter operations]

      * If DB2 write succeeds:
       EXEC CICS DEQ
            RESOURCE([counter-name])
            LENGTH([length])
       END-EXEC.

      * If DB2 write fails - MUST decrement counter before DEQ:
       [decrement counter]
       EXEC CICS DEQ
            RESOURCE([counter-name])
            LENGTH([length])
       END-EXEC.
```

**CRITICAL RULE:** If DB2 write fails, counter MUST be decremented before DEQUEUE to restore state.

---

## 9. DB2 SQL Standards

### 9.1 SQL Include Statements

**Standard:**
```cobol
      * Get the [TABLE] DB2 copybook
           EXEC SQL
              INCLUDE [TABLE-NAME]
           END-EXEC.

      * Pull in the SQL COMMAREA
        EXEC SQL
          INCLUDE SQLCA
        END-EXEC.
```

### 9.2 SQL Statement Format

**Standard:**
```cobol
       EXEC SQL
          [SQL-STATEMENT]
          [CLAUSE1]
          [CLAUSE2]
       END-EXEC.
```

**Example SELECT:**
```cobol
       EXEC SQL
          SELECT ACCOUNT_EYECATCHER,
                 ACCOUNT_CUSTOMER_NUMBER,
                 ACCOUNT_SORTCODE,
                 ACCOUNT_NUMBER,
                 ACCOUNT_TYPE
          INTO  :HV-ACCOUNT-EYECATCHER,
                :HV-ACCOUNT-CUST-NO,
                :HV-ACCOUNT-SORTCODE,
                :HV-ACCOUNT-ACC-NO,
                :HV-ACCOUNT-ACC-TYPE
          FROM ACCOUNT
          WHERE  (ACCOUNT_SORTCODE = :HV-ACCOUNT-SORTCODE AND
                  ACCOUNT_NUMBER = :HV-ACCOUNT-ACC-NO)
       END-EXEC.
```

**Example UPDATE:**
```cobol
       EXEC SQL
          UPDATE ACCOUNT
          SET ACCOUNT_TYPE = :HV-ACCOUNT-ACC-TYPE,
              ACCOUNT_INTEREST_RATE = :HV-ACCOUNT-INT-RATE,
              ACCOUNT_OVERDRAFT_LIMIT = :HV-ACCOUNT-OVERDRAFT-LIM
          WHERE (ACCOUNT_SORTCODE = :HV-ACCOUNT-SORTCODE AND
                 ACCOUNT_NUMBER = :HV-ACCOUNT-ACC-NO)
       END-EXEC.
```

**Example INSERT:**
```cobol
       EXEC SQL
          INSERT INTO PROCTRAN
                 (
                  PROCTRAN_EYECATCHER,
                  PROCTRAN_SORTCODE,
                  PROCTRAN_NUMBER,
                  PROCTRAN_DATE,
                  PROCTRAN_TIME
                 )
          VALUES
                 (
                  :HV-PROCTRAN-EYECATCHER,
                  :HV-PROCTRAN-SORT-CODE,
                  :HV-PROCTRAN-ACC-NUMBER,
                  :HV-PROCTRAN-DATE,
                  :HV-PROCTRAN-TIME
                 )
       END-EXEC.
```

**Example DELETE:**
```cobol
       EXEC SQL
          DELETE FROM ACCOUNT
          WHERE ACCOUNT_SORTCODE = :HV-ACCOUNT-SORTCODE AND
                ACCOUNT_NUMBER = :HV-ACCOUNT-ACC-NO
       END-EXEC.
```

### 9.3 SQLCODE Checking

**Standard Pattern:**
```cobol
       01 SQLCODE-DISPLAY              PIC S9(8) DISPLAY
           SIGN LEADING SEPARATE.

       [After SQL statement:]

       IF SQLCODE NOT = 0
          MOVE 'N' TO COMM-SUCCESS
          MOVE SQLCODE TO SQLCODE-DISPLAY
          DISPLAY 'ERROR: [PROGRAM] returned ' SQLCODE-DISPLAY
          ' on [OPERATION]'
          GO TO [EXIT-PARAGRAPH]
       END-IF.
```

**Checking for Row Not Found:**
```cobol
       IF SQLCODE = +100
          [handle not found]
       END-IF.
```

**Checking for Success or Not Found:**
```cobol
       IF SQLCODE NOT = 0 AND SQLCODE NOT = +100
          [handle error]
       END-IF.
```

### 9.4 Cursor Declarations

**Standard:**
```cobol
      * Declare the CURSOR for [TABLE] table
           EXEC SQL DECLARE [CURSOR-NAME] CURSOR FOR
              SELECT [columns]
                     FROM [table]
                     WHERE [conditions]
                     FOR FETCH ONLY
           END-EXEC.
```

**Example:**
```cobol
           EXEC SQL DECLARE ACC-CURSOR CURSOR FOR
              SELECT ACCOUNT_EYECATCHER,
                     ACCOUNT_CUSTOMER_NUMBER,
                     ACCOUNT_SORTCODE,
                     ACCOUNT_NUMBER
                     FROM ACCOUNT
                     WHERE ACCOUNT_SORTCODE = :HV-ACCOUNT-SORTCODE AND
                           ACCOUNT_NUMBER = :HV-ACCOUNT-ACC-NO
                     FOR FETCH ONLY
           END-EXEC.
```

---

## 10. Error Handling

### 10.1 Abend Handling Structure

**Standard Pattern:**

```cobol
       01 WS-ABEND-PGM                  PIC X(8) VALUE 'ABNDPROC'.

       01 ABNDINFO-REC.
           COPY ABNDINFO.

       [In error handling code:]

       INITIALIZE ABNDINFO-REC
       MOVE EIBRESP    TO ABND-RESPCODE
       MOVE EIBRESP2   TO ABND-RESP2CODE

       EXEC CICS ASSIGN APPLID(ABND-APPLID)
       END-EXEC

       MOVE EIBTASKN   TO ABND-TASKNO-KEY
       MOVE EIBTRNID   TO ABND-TRANID

       PERFORM POPULATE-TIME-DATE

       MOVE WS-ORIG-DATE TO ABND-DATE
       STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
             ':' DELIMITED BY SIZE,
              WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
              ':' DELIMITED BY SIZE,
              WS-TIME-NOW-GRP-MM DELIMITED BY SIZE
              INTO ABND-TIME
       END-STRING

       MOVE WS-U-TIME  TO ABND-UTIME-KEY
       MOVE '[CODE]'   TO ABND-CODE

       EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
       END-EXEC

       MOVE SQLCODE-DISPLAY TO ABND-SQLCODE

       STRING '[Error description]'
             DELIMITED BY SIZE,
             ' EIBRESP=' DELIMITED BY SIZE,
             ABND-RESPCODE DELIMITED BY SIZE,
             ' RESP2=' DELIMITED BY SIZE,
             ABND-RESP2CODE DELIMITED BY SIZE
             INTO ABND-FREEFORM
       END-STRING

       EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                 COMMAREA(ABNDINFO-REC)
       END-EXEC

       EXEC CICS ABEND
          ABCODE('[CODE]')
          NODUMP
       END-EXEC
```

### 10.2 Abend Codes

**Standard Format:** 4 characters, starting with 'H'

**Examples:**
- `HRAC` - Read Account error
- `HWPT` - Write PROCTRAN error
- `HBNK` - Bank Menu error

### 10.3 Error Messages

**Standard Format:**
```cobol
       DISPLAY '[PROGRAM] - [SECTION] - [Description]'
       DISPLAY 'SQLCODE=' SQLCODE-DISPLAY
       DISPLAY '[Additional context]'
```

**Example:**
```cobol
       DISPLAY 'ERROR: UPDACC returned ' SQLCODE-DISPLAY
       ' on SELECT'
```

---

## 11. Comments and Documentation

### 11.1 Comment Format

**Standard:**
```cobol
      *
      *    [Comment text]
      *
```

**For inline comments:**
```cobol
       MOVE SORTCODE TO COMM-SCODE.    * Set sort code
```

### 11.2 Section Documentation

**Standard:**
```cobol
      *
      *    [Section purpose and description]
      *
       [SECTION-NAME] SECTION.
       [ABBREV]010.
```

**Example:**
```cobol
      *
      *    Position ourself at the matching account record
      *
       UPDATE-ACCOUNT-DB2 SECTION.
       UAD010.
```

### 11.3 Complex Logic Documentation

**Standard:**
- Document business rules
- Explain non-obvious logic
- Reference external specifications

**Example:**
```cobol
      * During BMS processing the whole account record is
      * returned in the comm area on the update. However, the same
      * is NOT true if the update is coming in via the API.
      *
      * For example, if the API update supplies an account type
      * change, and doesn't supply the other fields, the interest
      * rate and the overdraft limit will come in as zeros. If
      * the updater was only intending to change the account type
      * from a LOAN account into an ISA, in this situation it
      * would also update the overdraft limit and the interest rate
      * to be zero. This may not have been the intention.
      *
      * To avoid this, we will put a rule into the Customer Service
      * interface that on an account update you must always supply the
      * account type AND the interest rate AND the overdraft limit.
```

### 11.4 Commented-Out Code

**Standard:**
- Use `*` in column 7 for commented-out code
- Include explanation of why code is commented
- Remove obsolete commented code before production

**Example:**
```cobol
      *    MOVE COMM-ACC-TYPE     TO
      *       HV-ACCOUNT-ACC-TYPE.
      *    MOVE COMM-INT-RATE     TO
      *       HV-ACCOUNT-INT-RATE.
```

---

## 12. Copybook Usage

### 12.1 COPY Statement Format

**Standard:**
```cobol
       COPY [copybook-name].
```

**With REPLACING:**
```cobol
       COPY [copybook-name] REPLACING 
            ==[old-text]== BY ==[new-text]==.
```

**Example:**
```cobol
       COPY INQACCCU REPLACING ==NUMBER-OF-ACCOUNTS.==
       BY ==NUMBER-OF-ACCOUNTS IN INQACCCU-COMMAREA.==.
```

### 12.2 Standard Copybooks

**Common Copybooks:**
- `SORTCODE` - Bank sort code constant
- `ACCOUNT` - Account data structure
- `CUSTOMER` - Customer data structure
- `ABNDINFO` - Abend information structure
- `DFHAID` - CICS attention identifier keys

**DB2 Copybooks:**
- `ACCDB2` - Account table definition
- `PROCDB2` - Process transaction table definition
- `CONTDB2` - Control table definition
- `SQLCA` - SQL Communication Area

### 12.3 Copybook Placement

**Working Storage:**
```cobol
       WORKING-STORAGE SECTION.

       COPY SORTCODE.

       [Other declarations]

       01 OUTPUT-DATA.
           COPY ACCOUNT.

       01 ABNDINFO-REC.
           COPY ABNDINFO.
```

**Linkage Section:**
```cobol
       LINKAGE SECTION.
       01 DFHCOMMAREA.
           COPY CREACC.
```

---

## 13. Code Formatting

### 13.1 Indentation

**Standard:**
- Use 3 spaces for each indentation level
- Align subordinate items under their parent

**Example:**
```cobol
       01 HOST-ACCOUNT-ROW.
          03 HV-ACCOUNT-EYECATCHER      PIC X(4).
          03 HV-ACCOUNT-KEY.
             05 HV-ACCOUNT-SORTCODE     PIC X(6).
             05 HV-ACCOUNT-ACC-NO       PIC X(8).
```

### 13.2 Column Usage

**Standard COBOL Columns:**
- Columns 1-6: Sequence numbers (optional, usually blank)
- Column 7: Indicator area (`*` for comments, `-` for continuation)
- Columns 8-11: Area A (Division, Section, Paragraph, 01/77 levels)
- Columns 12-72: Area B (Statements, subordinate data items)

**Example:**
```
123456789012345678901234567890...
       IDENTIFICATION DIVISION.        (Area A)
       PROGRAM-ID. UPDACC.             (Area A)
           MOVE X TO Y.                (Area B)
       01 DATA-ITEM.                   (Area A)
          03 SUB-ITEM    PIC X.        (Area B)
```

### 13.3 Alignment

**Data Declarations:**
```cobol
       01 WS-CICS-WORK-AREA.
          05 WS-CICS-RESP              PIC S9(8) COMP.
          05 WS-CICS-RESP2             PIC S9(8) COMP.
          05 WS-EIBRESP-DISPLAY        PIC S9(8) DISPLAY
                                  SIGN LEADING SEPARATE.
```

**PICTURE Clauses:**
- Align PICTURE clauses vertically when possible
- Use consistent spacing

### 13.4 Line Length

**Standard:**
- Maximum 72 characters (columns 8-72 for code)
- Break long statements across multiple lines
- Use continuation indicator (`-`) in column 7

**Example:**
```cobol
       STRING WS-TIME-NOW-GRP-HH DELIMITED BY SIZE,
             ':' DELIMITED BY SIZE,
              WS-TIME-NOW-GRP-MM DELIMITED BY SIZE,
              ':' DELIMITED BY SIZE,
              WS-TIME-NOW-GRP-SS DELIMITED BY SIZE
              INTO ABND-TIME
       END-STRING
```

### 13.5 Blank Lines

**Usage:**
- One blank line between sections
- One blank line between major logical blocks
- Two blank lines before major section headers

**Example:**
```cobol
       A999.
           EXIT.


       UPDATE-ACCOUNT-DB2 SECTION.
       UAD010.

           MOVE COMM-ACCNO TO DESIRED-ACC-NO.

           EXEC SQL
              [SQL statement]
           END-EXEC.

           IF SQLCODE NOT = 0
              [error handling]
           END-IF.

       UAD999.
           EXIT.
```

---

## Appendix A: Quick Reference

### A.1 Standard Program Template

```cobol
       CBL CICS('SP,EDF')
       CBL SQL
      ******************************************************************
      *                                                                *
      *  Copyright IBM Corp. 2023                                      *
      *                                                                *
      ******************************************************************
      ******************************************************************
      * [Program Description]
      *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. [PROGNAME].
       AUTHOR. [Author Name].

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  IBM-370.
       OBJECT-COMPUTER.  IBM-370.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       COPY SORTCODE.

      * Get the [TABLE] DB2 copybook
           EXEC SQL
              INCLUDE [TABLE]
           END-EXEC.

      * [TABLE] Host variables for DB2
       01 HOST-[TABLE]-ROW.
          03 HV-[TABLE]-[FIELD]         PIC X(n).

      * Pull in the SQL COMMAREA
        EXEC SQL
          INCLUDE SQLCA
        END-EXEC.

       01 SQLCODE-DISPLAY               PIC S9(8) DISPLAY
           SIGN LEADING SEPARATE.

       01 WS-CICS-WORK-AREA.
          05 WS-CICS-RESP               PIC S9(8) COMP.
          05 WS-CICS-RESP2              PIC S9(8) COMP.

       01 WS-ABEND-PGM                  PIC X(8) VALUE 'ABNDPROC'.

       01 ABNDINFO-REC.
           COPY ABNDINFO.

       LINKAGE SECTION.
       01 DFHCOMMAREA.
           COPY [COMMAREA].

       PROCEDURE DIVISION USING DFHCOMMAREA.
       PREMIERE SECTION.
       A010.

           [Main logic]

           PERFORM GET-ME-OUT-OF-HERE.

       A999.
           EXIT.


       GET-ME-OUT-OF-HERE SECTION.
       GMOOH010.

           EXEC CICS RETURN
           END-EXEC.

       GMOOH999.
           EXIT.
```

### A.2 Common Patterns Checklist

- [ ] Compiler directives at top
- [ ] Copyright header present
- [ ] Program description complete
- [ ] AUTHOR clause included
- [ ] SORTCODE copybook included
- [ ] Host variables use HV- prefix
- [ ] SQLCA included for DB2 programs
- [ ] CICS RESP/RESP2 checked
- [ ] SQLCODE checked after SQL statements
- [ ] Abend handling implemented
- [ ] GET-ME-OUT-OF-HERE section present
- [ ] All sections have exit paragraphs
- [ ] Comments explain business logic
- [ ] Copybooks used instead of duplicated structures

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-06-08 | Bob (Z Architect) | Initial version based on CBSA codebase analysis |

---

**End of Document**