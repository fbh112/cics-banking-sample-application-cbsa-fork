       CBL CICS('SP,EDF')
       CBL SQL
      ******************************************************************
      *                                                                *
      *  Copyright IBM Corp. 2023                                      *
      *                                                                *
      ******************************************************************
      ******************************************************************
      * This program finds a customer's account information using
      * their phone number as the search key.
      *
      * Input:  Phone number via COMMAREA
      * Output: Customer details and associated account numbers
      *
      * The program searches the CUSTOMER table for a matching phone
      * number and returns the customer information along with a list
      * of their account numbers.
      *
      * If no matching customer is found, returns appropriate error
      * code. If multiple customers have the same phone number,
      * returns the first match found.
      *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. INQCUSPH.
       AUTHOR. CBSA Development Team.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  IBM-370.
       OBJECT-COMPUTER.  IBM-370.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.

       COPY SORTCODE.

       EXEC SQL
           INCLUDE SQLCA
       END-EXEC.

       01 HOST-CUSTOMER-ROW.
          03 HV-CUSTOMER-EYECATCHER     PIC X(4).
          03 HV-CUSTOMER-SORTCODE       PIC 9(6).
          03 HV-CUSTOMER-NUMBER         PIC 9(10).
          03 HV-CUSTOMER-NAME           PIC X(60).
          03 HV-CUSTOMER-ADDRESS        PIC X(160).
          03 HV-CUSTOMER-DOB            PIC 9(8).
          03 HV-CUSTOMER-PHONE          PIC X(15).

       01 HOST-ACCOUNT-ROW.
          03 HV-ACCOUNT-SORTCODE        PIC 9(6).
          03 HV-ACCOUNT-NUMBER          PIC 9(8).
          03 HV-ACCOUNT-TYPE            PIC X(8).
          03 HV-ACCOUNT-BALANCE         PIC S9(10)V99 COMP-3.

       01 WS-CICS-WORK-AREA.
          03 WS-CICS-RESP              PIC S9(8) COMP VALUE 0.
          03 WS-CICS-RESP2             PIC S9(8) COMP VALUE 0.

       01 WS-SQLCODE-DISP              PIC S9(9) DISPLAY.

       01 WS-ACCOUNT-COUNT             PIC 9(3) COMP VALUE 0.
       01 WS-ACCOUNT-INDEX             PIC 9(3) COMP VALUE 0.

       01 WS-ABEND-PGM                 PIC X(8) VALUE 'ABNDPROC'.
       01 ABNDINFO-REC.
           COPY ABNDINFO.

       LINKAGE SECTION.
       01 DFHCOMMAREA.
          03 COMM-PHONE-NUMBER          PIC X(15).
          03 COMM-SUCCESS               PIC X.
             88 COMM-SUCCESS-YES        VALUE 'Y'.
             88 COMM-SUCCESS-NO         VALUE 'N'.
          03 COMM-FAIL-CODE             PIC X.
             88 COMM-PHONE-INVALID      VALUE '1'.
             88 COMM-CUSTOMER-NOT-FOUND VALUE '2'.
             88 COMM-DB-ERROR           VALUE '9'.
          03 COMM-CUSTOMER-INFO.
             05 COMM-CUST-NUMBER        PIC 9(10).
             05 COMM-CUST-NAME          PIC X(60).
             05 COMM-CUST-ADDRESS       PIC X(160).
             05 COMM-CUST-DOB           PIC 9(8).
          03 COMM-ACCOUNT-COUNT         PIC 9(3).
          03 COMM-ACCOUNT-LIST OCCURS 10 TIMES.
             05 COMM-ACCOUNT-SORTCODE   PIC 9(6).
             05 COMM-ACCOUNT-NUMBER     PIC 9(8).
             05 COMM-ACCOUNT-TYPE       PIC X(8).
             05 COMM-ACCOUNT-BALANCE    PIC S9(10)V99 COMP-3.

       PROCEDURE DIVISION USING DFHCOMMAREA.
       PREMIERE SECTION.
       A010.

           EXEC CICS HANDLE
              ABEND LABEL(ABEND-HANDLING)
           END-EXEC.

      *
      *    Initialize response flags
      *
           MOVE 'N' TO COMM-SUCCESS.
           MOVE SPACES TO COMM-FAIL-CODE.
           MOVE ZEROS TO COMM-ACCOUNT-COUNT.

      *
      *    Validate input phone number
      *
           IF COMM-PHONE-NUMBER = SPACES OR LOW-VALUES
              SET COMM-PHONE-INVALID TO TRUE
              PERFORM GET-ME-OUT-OF-HERE
           END-IF.

      *
      *    Search for customer by phone number
      *
           PERFORM FIND-CUSTOMER-BY-PHONE.

           IF COMM-SUCCESS-YES
      *
      *       Customer found - retrieve their accounts
      *
              PERFORM RETRIEVE-CUSTOMER-ACCOUNTS
           END-IF.

           PERFORM GET-ME-OUT-OF-HERE.

       FIND-CUSTOMER-BY-PHONE.
      *
      *    Query DB2 CUSTOMER table for matching phone number
      *    Note: In production, CUSTOMER table would need a
      *    CUSTOMER_PHONE column added via ALTER TABLE
      *
           MOVE COMM-PHONE-NUMBER TO HV-CUSTOMER-PHONE.

           EXEC SQL
              SELECT CUSTOMER_EYECATCHER,
                     CUSTOMER_SORTCODE,
                     CUSTOMER_NUMBER,
                     CUSTOMER_NAME,
                     CUSTOMER_ADDRESS,
                     CUSTOMER_DATE_OF_BIRTH,
                     CUSTOMER_PHONE
              INTO :HV-CUSTOMER-EYECATCHER,
                   :HV-CUSTOMER-SORTCODE,
                   :HV-CUSTOMER-NUMBER,
                   :HV-CUSTOMER-NAME,
                   :HV-CUSTOMER-ADDRESS,
                   :HV-CUSTOMER-DOB,
                   :HV-CUSTOMER-PHONE
              FROM CUSTOMER
              WHERE CUSTOMER_PHONE = :HV-CUSTOMER-PHONE
              FETCH FIRST 1 ROW ONLY
           END-EXEC.

           EVALUATE SQLCODE
              WHEN 0
      *
      *          Customer found - populate COMMAREA
      *
                 SET COMM-SUCCESS-YES TO TRUE
                 MOVE HV-CUSTOMER-NUMBER TO COMM-CUST-NUMBER
                 MOVE HV-CUSTOMER-NAME TO COMM-CUST-NAME
                 MOVE HV-CUSTOMER-ADDRESS TO COMM-CUST-ADDRESS
                 MOVE HV-CUSTOMER-DOB TO COMM-CUST-DOB

              WHEN 100
      *
      *          No customer found with this phone number
      *
                 SET COMM-CUSTOMER-NOT-FOUND TO TRUE

              WHEN OTHER
      *
      *          Database error occurred
      *
                 MOVE SQLCODE TO WS-SQLCODE-DISP
                 SET COMM-DB-ERROR TO TRUE
           END-EVALUATE.

       RETRIEVE-CUSTOMER-ACCOUNTS.
      *
      *    Retrieve all accounts for the customer
      *    using a cursor to handle multiple accounts
      *
           EXEC SQL
              DECLARE CUSTACCT-CURSOR CURSOR FOR
              SELECT ACCOUNT_SORTCODE,
                     ACCOUNT_NUMBER,
                     ACCOUNT_TYPE,
                     ACCOUNT_AVAILABLE_BALANCE
              FROM ACCOUNT
              WHERE ACCOUNT_CUSTOMER_NUMBER = :HV-CUSTOMER-NUMBER
              ORDER BY ACCOUNT_NUMBER
              FOR FETCH ONLY
           END-EXEC.

           EXEC SQL
              OPEN CUSTACCT-CURSOR
           END-EXEC.

           IF SQLCODE NOT = 0
              MOVE SQLCODE TO WS-SQLCODE-DISP
              SET COMM-DB-ERROR TO TRUE
              GO TO RETRIEVE-CUST-ACCOUNTS-EXIT
           END-IF.

           MOVE 0 TO WS-ACCOUNT-COUNT.

           PERFORM FETCH-ACCOUNT-ROW
              UNTIL SQLCODE NOT = 0
                 OR WS-ACCOUNT-COUNT >= 10.

           EXEC SQL
              CLOSE CUSTACCT-CURSOR
           END-EXEC.

           MOVE WS-ACCOUNT-COUNT TO COMM-ACCOUNT-COUNT.

       RETRIEVE-CUST-ACCOUNTS-EXIT.
           EXIT.

       FETCH-ACCOUNT-ROW.
      *
      *    Fetch next account row from cursor
      *
           EXEC SQL
              FETCH CUSTACCT-CURSOR
              INTO :HV-ACCOUNT-SORTCODE,
                   :HV-ACCOUNT-NUMBER,
                   :HV-ACCOUNT-TYPE,
                   :HV-ACCOUNT-BALANCE
           END-EXEC.

           IF SQLCODE = 0
              ADD 1 TO WS-ACCOUNT-COUNT
              MOVE WS-ACCOUNT-COUNT TO WS-ACCOUNT-INDEX
              MOVE HV-ACCOUNT-SORTCODE
                 TO COMM-ACCOUNT-SORTCODE(WS-ACCOUNT-INDEX)
              MOVE HV-ACCOUNT-NUMBER
                 TO COMM-ACCOUNT-NUMBER(WS-ACCOUNT-INDEX)
              MOVE HV-ACCOUNT-TYPE
                 TO COMM-ACCOUNT-TYPE(WS-ACCOUNT-INDEX)
              MOVE HV-ACCOUNT-BALANCE
                 TO COMM-ACCOUNT-BALANCE(WS-ACCOUNT-INDEX)
           END-IF.

       GET-ME-OUT-OF-HERE.
           EXEC CICS RETURN
           END-EXEC.

       ABEND-HANDLING.
           MOVE EIBRESP TO ABND-RESPCODE.
           MOVE EIBRESP2 TO ABND-RESP2CODE.
           EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
                     COMMAREA(ABNDINFO-REC)
           END-EXEC.
           EXEC CICS RETURN
           END-EXEC.

      *> Made with Bob
