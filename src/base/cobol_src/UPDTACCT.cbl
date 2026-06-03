       PROCESS CICS,NODYNAM,NSYMBOL(NATIONAL),TRUNC(STD)
       CBL CICS('SP,EDF')
       CBL SQL
      ******************************************************************
      *                                                                *
      *  Copyright IBM Corp. 2023                                      *
      *                                                                *
      ******************************************************************
      ******************************************************************
      * This program provides a BMS-based interface for updating
      * bank account information using a pseudo-conversational pattern.
      *
      * The program displays account details on the UPDTAC map and
      * allows users to modify the account type, interest rate, and
      * overdraft limit. The program validates user input and links
      * to the UPDACC program to perform the actual database update.
      *
      * Pseudo-conversational flow:
      * 1. First invocation (EIBCALEN=0): Display empty map
      * 2. User enters account number and presses ENTER
      * 3. Program retrieves account data via INQACC and displays it
      * 4. User modifies fields and presses PF5 to update
      * 5. Program validates and updates via UPDACC
      *
      * Function Keys:
      * - ENTER: Retrieve account information
      * - PF3: Return to main menu
      * - PF5: Update account information
      * - PF12: Terminate session
      * - CLEAR: Clear screen and terminate
      *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. UPDTACCT.
       AUTHOR. Bob Premium for Z.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  IBM-370.
       OBJECT-COMPUTER.  IBM-370.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       COPY SORTCODE.

       01 WS-CICS-WORK-AREA.
          03 WS-CICS-RESP              PIC S9(8) COMP VALUE 0.
          03 WS-CICS-RESP2             PIC S9(8) COMP VALUE 0.

       01 WS-FAIL-INFO.
          03 FILLER                    PIC X(9)  VALUE 'UPDTACCT '.
          03 WS-CICS-FAIL-MSG          PIC X(70) VALUE SPACES.
          03 FILLER                    PIC X(6)  VALUE ' RESP='.
          03 WS-CICS-RESP-DISP         PIC 9(8)  VALUE 0.
          03 FILLER                    PIC X(7)  VALUE ' RESP2='.
          03 WS-CICS-RESP2-DISP        PIC 9(8)  VALUE 0.
          03 FILLER                    PIC X(15) VALUE SPACES.

       01 SWITCHES.
          03 VALID-DATA-SW             PIC X     VALUE 'Y'.
             88 VALID-DATA                       VALUE 'Y'.

       01 FLAGS.
          03 SEND-FLAG                 PIC X.
             88 SEND-ERASE                       VALUE '1'.
             88 SEND-DATAONLY                    VALUE '2'.
             88 SEND-DATAONLY-ALARM              VALUE '3'.

       01 END-OF-SESSION-MESSAGE       PIC X(13) VALUE 'Session Ended'.

       COPY UPDTACM.

       COPY DFHAID.

       01 WS-CONVERSION.
          03 WS-CONVERT-PICX           PIC X(14).
          03 WS-CONVERT-SPLIT REDEFINES WS-CONVERT-PICX.
             05 WS-CONVERT-SIGN        PIC X.
             05 WS-CONVERT-DEC         PIC X(10).
             05 WS-CONVERT-POINT       PIC X.
             05 WS-CONVERT-REMAIN      PIC XX.

       01 WS-CONVERTED-VAL1            PIC S9(10)V99.
       01 WS-CONVERTED-VAL2            PIC S9(10)V99.
       01 WS-CONVERTED-VAL3            PIC S9(10)V99.

       01 INT-RT-CONVERT.
          03 INT-RT-X                  PIC X(7).
          03 INT-RT-GROUP REDEFINES INT-RT-X.
             05 INT-RT-9               PIC 9(4)V99.

       01 WS-COMM-AREA.
          03 WS-COMM-EYE               PIC X(4).
          03 WS-COMM-CUSTNO            PIC X(10).
          03 WS-COMM-SCODE             PIC X(6).
          03 WS-COMM-ACCNO             PIC 9(8).
          03 WS-COMM-ACC-TYPE          PIC X(8).
          03 WS-COMM-INT-RATE          PIC 9(4)V99.
          03 WS-COMM-OPENED            PIC 9(8).
          03 WS-COMM-OVERDRAFT         PIC 9(8).
          03 WS-COMM-LAST-STMT-DT      PIC 9(8).
          03 WS-COMM-NEXT-STMT-DT      PIC 9(8).
          03 WS-COMM-AVAIL-BAL         PIC S9(10)V99.
          03 WS-COMM-ACTUAL-BAL        PIC S9(10)V99.
          03 WS-COMM-SUCCESS           PIC X.

       01 COMPANY-NAME-FULL            PIC X(32).

       01 INTRTI-COMP-1                COMP-1.

       01 INTRT-PIC9                   PIC 9(4)V99.

       01 WS-NUM-COUNT-POINT           PIC 9.
       01 WS-NUM-COUNT-TOTAL           PIC 9.

       01 AVAILABLE-BALANCE-DISPLAY    PIC +9(10).99.
       01 ACTUAL-BALANCE-DISPLAY       PIC +9(10).99.

       01 WS-U-TIME                    PIC S9(15) COMP-3.
       01 WS-ORIG-DATE                 PIC X(10).
       01 WS-ORIG-DATE-GRP REDEFINES WS-ORIG-DATE.
          03 WS-ORIG-DATE-DD           PIC 99.
          03 FILLER                    PIC X.
          03 WS-ORIG-DATE-MM           PIC 99.
          03 FILLER                    PIC X.
          03 WS-ORIG-DATE-YYYY         PIC 9999.

       01 WS-ORIG-DATE-GRP-X.
          03 WS-ORIG-DATE-DD-X         PIC XX.
          03 FILLER                    PIC X         VALUE '.'.
          03 WS-ORIG-DATE-MM-X         PIC XX.
          03 FILLER                    PIC X         VALUE '.'.
          03 WS-ORIG-DATE-YYYY-X       PIC X(4).

       01 WS-TIME-DATA.
          03 WS-TIME-NOW               PIC 9(6).
          03 WS-TIME-NOW-GRP REDEFINES WS-TIME-NOW.
             05 WS-TIME-NOW-GRP-HH     PIC 99.
             05 WS-TIME-NOW-GRP-MM     PIC 99.
             05 WS-TIME-NOW-GRP-SS     PIC 99.

       01 WS-ABEND-PGM                 PIC X(8)      VALUE 'ABNDPROC'.

       01 ABNDINFO-REC.
           COPY ABNDINFO.

      *
      * INQACC COMMAREA for account inquiry
      *
       01 INQACC-COMMAREA.
           COPY INQACC.

      *
      * UPDACC COMMAREA for account update
      *
       01 UPDACC-COMMAREA.
           COPY UPDACC.

       LINKAGE SECTION.
       01 DFHCOMMAREA.
          03 COMM-EYE                  PIC X(4).
          03 COMM-CUSTNO               PIC X(10).
          03 COMM-SCODE                PIC X(6).
          03 COMM-ACCNO                PIC 9(8).
          03 COMM-ACC-TYPE             PIC X(8).
          03 COMM-INT-RATE             PIC 9(4)V99.
          03 COMM-OPENED               PIC 9(8).
          03 COMM-OVERDRAFT            PIC 9(8).
          03 COMM-LAST-STMT-DT         PIC 9(8).
          03 COMM-NEXT-STMT-DT         PIC 9(8).
          03 COMM-AVAIL-BAL            PIC S9(10)V99.
          03 COMM-ACTUAL-BAL           PIC S9(10)V99.
          03 COMM-SUCCESS              PIC X.

       PROCEDURE DIVISION.
       PREMIERE SECTION.
       A010.

           EVALUATE TRUE
      *
      *       Is it the first time through? If so, send the map
      *       with erased (empty) data fields.
      *
              WHEN EIBCALEN = ZERO
                 MOVE LOW-VALUE TO UPDTACO
                 MOVE -1 TO ACCNOL
                 SET SEND-ERASE TO TRUE
                 INITIALIZE WS-COMM-AREA
                 PERFORM SEND-MAP

      *
      *       If a PA key is pressed, just carry on
      *
              WHEN EIBAID = DFHPA1 OR DFHPA2 OR DFHPA3
                 CONTINUE

      *
      *       When Pf3 is pressed, return to the main menu
      *
              WHEN EIBAID = DFHPF3
                 EXEC CICS RETURN
                    TRANSID('OMEN')
                    IMMEDIATE
                    RESP(WS-CICS-RESP)
                    RESP2(WS-CICS-RESP2)
                 END-EXEC

      *
      *       If the aid or Pf12 is pressed, then send a termination
      *       message.
      *
              WHEN EIBAID = DFHAID OR DFHPF12
                 PERFORM SEND-TERMINATION-MSG
                 EXEC CICS
                    RETURN
                 END-EXEC

      *
      *       When CLEAR is pressed
      *
              WHEN EIBAID = DFHCLEAR
                EXEC CICS SEND CONTROL
                   ERASE
                   FREEKB
                END-EXEC

                EXEC CICS RETURN
                END-EXEC

      *
      *       When enter is pressed then process the content
      *
              WHEN EIBAID = DFHENTER
                 PERFORM PROCESS-MAP

      *
      *       When Pf5 is pressed then process the content
      *
              WHEN EIBAID = DFHPF5
                 PERFORM PROCESS-MAP

      *
      *       When anything else happens, send the invalid key message
      *
              WHEN OTHER
                 MOVE LOW-VALUES TO UPDTACO
                 MOVE 'Invalid key pressed.' TO MESSAGEO
                 MOVE -1 TO ACCNOL
                 SET SEND-DATAONLY-ALARM TO TRUE
                 PERFORM SEND-MAP

           END-EVALUATE.

      *
      *    If it is not the first time through, set the return
      *    information accordingly.
      *
      *
           IF EIBCALEN NOT = ZERO
              MOVE COMM-EYE            TO WS-COMM-EYE
              MOVE COMM-CUSTNO         TO WS-COMM-CUSTNO
              MOVE COMM-SCODE          TO WS-COMM-SCODE
              MOVE COMM-ACCNO          TO WS-COMM-ACCNO
              MOVE COMM-ACC-TYPE       TO WS-COMM-ACC-TYPE
              MOVE COMM-INT-RATE       TO WS-COMM-INT-RATE
              MOVE COMM-OPENED         TO WS-COMM-OPENED
              MOVE COMM-OVERDRAFT      TO WS-COMM-OVERDRAFT
              MOVE COMM-LAST-STMT-DT   TO WS-COMM-LAST-STMT-DT
              MOVE COMM-NEXT-STMT-DT   TO WS-COMM-NEXT-STMT-DT
              MOVE COMM-AVAIL-BAL      TO WS-COMM-AVAIL-BAL
              MOVE COMM-ACTUAL-BAL     TO WS-COMM-ACTUAL-BAL
           END-IF.

           EXEC CICS
              RETURN TRANSID('OUAT')
              COMMAREA(WS-COMM-AREA)
              LENGTH(99)
              RESP(WS-CICS-RESP)
              RESP2(WS-CICS-RESP2)
           END-EXEC.

           IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
      *
      *       Preserve the RESP and RESP2, then set up the
      *       standard ABEND info before getting the applid,
      *       date/time etc. and linking to the Abend Handler
      *       program.
      *
              INITIALIZE ABNDINFO-REC
              MOVE EIBRESP    TO ABND-RESPCODE
              MOVE EIBRESP2   TO ABND-RESP2CODE
      *
      *       Get supplemental information
      *
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
                     WS-TIME-NOW-GRP-SS DELIMITED BY SIZE
                     INTO ABND-TIME
              END-STRING

              MOVE WS-U-TIME   TO ABND-UTIME-KEY
              MOVE 'HBNK'      TO ABND-CODE

              EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
              END-EXEC

              MOVE ZEROS      TO ABND-SQLCODE

              STRING 'A010 - RETURN TRANSID(OUAT) FAIL.'
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

              INITIALIZE WS-FAIL-INFO
              MOVE 'UPDTACCT - A010 - RETURN TRANSID(OUAT) FAIL' TO
                 WS-CICS-FAIL-MSG
              MOVE WS-CICS-RESP  TO WS-CICS-RESP-DISP
              MOVE WS-CICS-RESP2 TO WS-CICS-RESP2-DISP
              PERFORM ABEND-THIS-TASK
           END-IF.

       A999.
           EXIT.


       PROCESS-MAP SECTION.
       PM010.
      *
      *    Retrieve the data from the map
      *
           PERFORM RECEIVE-MAP.
           MOVE 'Y' TO VALID-DATA-SW.
      *
      *    If enter was pressed, validate the received data
      *
           IF EIBAID = DFHENTER
              PERFORM EDIT-DATA
      *
      *       If the data passes validation go on to
      *       get the account
      *
              IF VALID-DATA
                 PERFORM INQ-ACC-DATA
              END-IF

           END-IF.

      *
      *    If Pf5 was pressed, validate the received data
      *
           IF EIBAID = DFHPF5
              PERFORM VALIDATE-DATA

      *
      *       If the data passes validation go on to
      *       update the account
      *
              IF VALID-DATA
                 PERFORM UPD-ACC-DATA
              END-IF

           END-IF.

           SET SEND-DATAONLY-ALARM TO TRUE.
      *
      *    Output the data to the screen
      *
           PERFORM SEND-MAP.

       PM999.
           EXIT.


       RECEIVE-MAP SECTION.
       RM010.
      *
      *    Retrieve the data
      *
           EXEC CICS
              RECEIVE MAP('UPDTAC')
              MAPSET('UPDTACM')
              INTO(UPDTACI)
              RESP(WS-CICS-RESP)
              RESP2(WS-CICS-RESP2)
           END-EXEC.

           IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
      *
      *       Preserve the RESP and RESP2, then set up the
      *       standard ABEND info before getting the applid,
      *       date/time etc. and linking to the Abend Handler
      *       program.
      *
              INITIALIZE ABNDINFO-REC
              MOVE EIBRESP    TO ABND-RESPCODE
              MOVE EIBRESP2   TO ABND-RESP2CODE
      *
      *       Get supplemental information
      *
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
                     WS-TIME-NOW-GRP-SS DELIMITED BY SIZE
                     INTO ABND-TIME
              END-STRING

              MOVE WS-U-TIME   TO ABND-UTIME-KEY
              MOVE 'HBNK'      TO ABND-CODE

              EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
              END-EXEC

              MOVE ZEROS      TO ABND-SQLCODE

              STRING 'RM010 - RECEIVE MAP FAIL.'
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


              INITIALIZE WS-FAIL-INFO
              MOVE 'UPDTACCT - RM010 - RECEIVE MAP FAIL ' TO
                 WS-CICS-FAIL-MSG
              MOVE WS-CICS-RESP  TO WS-CICS-RESP-DISP
              MOVE WS-CICS-RESP2 TO WS-CICS-RESP2-DISP
              PERFORM ABEND-THIS-TASK
           END-IF.

       RM999.
           EXIT.


       EDIT-DATA SECTION.
       ED010.
      *
      *    Perform validation on the account number
      *
           IF ACCNOI = SPACES OR LOW-VALUES
              MOVE 'N' TO VALID-DATA-SW
              MOVE 'Please enter an account number.' TO MESSAGEO
              MOVE -1 TO ACCNOL
           END-IF.

       ED999.
           EXIT.


       VALIDATE-DATA SECTION.
       VD010.
      *
      *    Validate the account type
      *
           IF ACTYPEI = SPACES OR LOW-VALUES
              MOVE 'N' TO VALID-DATA-SW
              MOVE 'Account type is required.' TO MESSAGEO
              MOVE -1 TO ACTYPEL
              GO TO VD999
           END-IF.

      *
      *    Validate the interest rate
      *
           IF INTRTI = SPACES OR LOW-VALUES
              MOVE 'N' TO VALID-DATA-SW
              MOVE 'Interest rate is required.' TO MESSAGEO
              MOVE -1 TO INTRTL
              GO TO VD999
           END-IF.

      *
      *    Validate the overdraft limit
      *
           IF OVERDRI = SPACES OR LOW-VALUES
              MOVE 'N' TO VALID-DATA-SW
              MOVE 'Overdraft limit is required.' TO MESSAGEO
              MOVE -1 TO OVERDRL
              GO TO VD999
           END-IF.

       VD999.
           EXIT.


       INQ-ACC-DATA SECTION.
       IAD010.
      *
      *    Initialize the INQACC commarea
      *
           INITIALIZE INQACC-COMMAREA.

           MOVE SORTCODE TO INQACC-SCODE IN INQACC-COMMAREA.
           MOVE ACCNOI TO INQACC-ACCNO IN INQACC-COMMAREA.

      *
      *    Link to INQACC to retrieve account information
      *
           EXEC CICS LINK PROGRAM('INQACC  ')
                     COMMAREA(INQACC-COMMAREA)
                     RESP(WS-CICS-RESP)
                     RESP2(WS-CICS-RESP2)
           END-EXEC.

           IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
              MOVE 'Error retrieving account information.' TO MESSAGEO
              MOVE -1 TO ACCNOL
              GO TO IAD999
           END-IF.

      *
      *    Check if the inquiry was successful
      *
           IF INQACC-SUCCESS IN INQACC-COMMAREA = 'N'
              MOVE 'Account not found.' TO MESSAGEO
              MOVE -1 TO ACCNOL
              GO TO IAD999
           END-IF.

      *
      *    Move the retrieved data to the working storage area
      *
           MOVE INQACC-EYE IN INQACC-COMMAREA
              TO WS-COMM-EYE.
           MOVE INQACC-CUSTNO IN INQACC-COMMAREA
              TO WS-COMM-CUSTNO.
           MOVE INQACC-SCODE IN INQACC-COMMAREA
              TO WS-COMM-SCODE.
           MOVE INQACC-ACCNO IN INQACC-COMMAREA
              TO WS-COMM-ACCNO.
           MOVE INQACC-ACC-TYPE IN INQACC-COMMAREA
              TO WS-COMM-ACC-TYPE.
           MOVE INQACC-INT-RATE IN INQACC-COMMAREA
              TO WS-COMM-INT-RATE.
           MOVE INQACC-OPENED IN INQACC-COMMAREA
              TO WS-COMM-OPENED.
           MOVE INQACC-OVERDRAFT IN INQACC-COMMAREA
              TO WS-COMM-OVERDRAFT.
           MOVE INQACC-LAST-STMT-DT IN INQACC-COMMAREA
              TO WS-COMM-LAST-STMT-DT.
           MOVE INQACC-NEXT-STMT-DT IN INQACC-COMMAREA
              TO WS-COMM-NEXT-STMT-DT.
           MOVE INQACC-AVAIL-BAL IN INQACC-COMMAREA
              TO WS-COMM-AVAIL-BAL.
           MOVE INQACC-ACTUAL-BAL IN INQACC-COMMAREA
              TO WS-COMM-ACTUAL-BAL.

      *
      *    Display the account information on the map
      *
           MOVE WS-COMM-CUSTNO TO CUSTNOO.
           MOVE WS-COMM-SCODE TO SORTCO.
           MOVE WS-COMM-ACCNO TO ACCNO2O.
           MOVE WS-COMM-ACC-TYPE TO ACTYPEO.

      *
      *    Format and display the interest rate
      *
           MOVE WS-COMM-INT-RATE TO INTRT-PIC9.
           MOVE INTRT-PIC9 TO INTRTI-COMP-1.
           MOVE INTRTI-COMP-1 TO INTRTIO.

      *
      *    Format and display the opened date
      *
           MOVE WS-COMM-OPENED TO WS-ORIG-DATE.
           MOVE WS-ORIG-DATE-DD TO OPENDDO.
           MOVE WS-ORIG-DATE-MM TO OPENMMO.
           MOVE WS-ORIG-DATE-YYYY TO OPENYYO.

      *
      *    Display the overdraft limit
      *
           MOVE WS-COMM-OVERDRAFT TO OVERDRO.

      *
      *    Format and display the last statement date
      *
           MOVE WS-COMM-LAST-STMT-DT TO WS-ORIG-DATE.
           MOVE WS-ORIG-DATE-DD TO LSTMTDDO.
           MOVE WS-ORIG-DATE-MM TO LSTMTMMO.
           MOVE WS-ORIG-DATE-YYYY TO LSTMTYYO.

      *
      *    Format and display the next statement date
      *
           MOVE WS-COMM-NEXT-STMT-DT TO WS-ORIG-DATE.
           MOVE WS-ORIG-DATE-DD TO NSTMTDDO.
           MOVE WS-ORIG-DATE-MM TO NSTMTMMO.
           MOVE WS-ORIG-DATE-YYYY TO NSTMTYYO.

      *
      *    Format and display the available balance
      *
           MOVE WS-COMM-AVAIL-BAL TO AVAILABLE-BALANCE-DISPLAY.
           MOVE AVAILABLE-BALANCE-DISPLAY TO AVBALO.

      *
      *    Format and display the actual balance
      *
           MOVE WS-COMM-ACTUAL-BAL TO ACTUAL-BALANCE-DISPLAY.
           MOVE ACTUAL-BALANCE-DISPLAY TO ACTBALO.

           MOVE 'Account retrieved. Modify fields and press PF5 to upd
      -    'ate.' TO MESSAGEO.

       IAD999.
           EXIT.


       UPD-ACC-DATA SECTION.
       UAD010.
      *
      *    Initialize the UPDACC commarea
      *
           INITIALIZE UPDACC-COMMAREA.

      *
      *    Move the data from the map to the UPDACC commarea
      *
           MOVE WS-COMM-EYE TO COMM-EYE IN UPDACC-COMMAREA.
           MOVE WS-COMM-CUSTNO TO COMM-CUSTNO IN UPDACC-COMMAREA.
           MOVE WS-COMM-SCODE TO COMM-SCODE IN UPDACC-COMMAREA.
           MOVE WS-COMM-ACCNO TO COMM-ACCNO IN UPDACC-COMMAREA.

      *
      *    Get the updated values from the map
      *
           MOVE ACTYPEI TO COMM-ACC-TYPE IN UPDACC-COMMAREA.

      *
      *    Convert the interest rate from the map
      *
           MOVE INTRTI TO INT-RT-X.
           MOVE INT-RT-9 TO COMM-INT-RATE IN UPDACC-COMMAREA.

      *
      *    Convert the overdraft limit from the map
      *
           MOVE OVERDRI TO COMM-OVERDRAFT IN UPDACC-COMMAREA.

      *
      *    Link to UPDACC to update the account
      *
           EXEC CICS LINK PROGRAM('UPDACC  ')
                     COMMAREA(UPDACC-COMMAREA)
                     RESP(WS-CICS-RESP)
                     RESP2(WS-CICS-RESP2)
           END-EXEC.

           IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
              MOVE 'Error updating account information.' TO MESSAGEO
              MOVE -1 TO ACTYPEL
              GO TO UAD999
           END-IF.

      *
      *    Check if the update was successful
      *
           IF COMM-SUCCESS IN UPDACC-COMMAREA = 'N'
              MOVE 'Account update failed.' TO MESSAGEO
              MOVE -1 TO ACTYPEL
              GO TO UAD999
           END-IF.

      *
      *    Update was successful
      *
           MOVE 'Account updated successfully.' TO MESSAGEO.

      *
      *    Refresh the display with updated data
      *
           MOVE COMM-AVAIL-BAL IN UPDACC-COMMAREA
              TO WS-COMM-AVAIL-BAL.
           MOVE COMM-ACTUAL-BAL IN UPDACC-COMMAREA
              TO WS-COMM-ACTUAL-BAL.

           MOVE WS-COMM-AVAIL-BAL TO AVAILABLE-BALANCE-DISPLAY.
           MOVE AVAILABLE-BALANCE-DISPLAY TO AVBALO.

           MOVE WS-COMM-ACTUAL-BAL TO ACTUAL-BALANCE-DISPLAY.
           MOVE ACTUAL-BALANCE-DISPLAY TO ACTBALO.

       UAD999.
           EXIT.


       SEND-MAP SECTION.
       SM010.
      *
      *    Get the company name
      *
           EXEC CICS LINK PROGRAM('GETCOMPY')
                     COMMAREA(COMPANY-NAME-FULL)
                     LENGTH(32)
           END-EXEC.

           MOVE COMPANY-NAME-FULL TO COMPANYO.

           IF SEND-ERASE
              EXEC CICS SEND MAP('UPDTAC')
                        MAPSET('UPDTACM')
                        FROM(UPDTACO)
                        ERASE
                        CURSOR
                        RESP(WS-CICS-RESP)
                        RESP2(WS-CICS-RESP2)
              END-EXEC
           END-IF.

           IF SEND-DATAONLY
              EXEC CICS SEND MAP('UPDTAC')
                        MAPSET('UPDTACM')
                        FROM(UPDTACO)
                        DATAONLY
                        CURSOR
                        RESP(WS-CICS-RESP)
                        RESP2(WS-CICS-RESP2)
              END-EXEC
           END-IF.

           IF SEND-DATAONLY-ALARM
              EXEC CICS SEND MAP('UPDTAC')
                        MAPSET('UPDTACM')
                        FROM(UPDTACO)
                        DATAONLY
                        ALARM
                        CURSOR
                        RESP(WS-CICS-RESP)
                        RESP2(WS-CICS-RESP2)
              END-EXEC
           END-IF.

           IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
      *
      *       Preserve the RESP and RESP2, then set up the
      *       standard ABEND info before getting the applid,
      *       date/time etc. and linking to the Abend Handler
      *       program.
      *
              INITIALIZE ABNDINFO-REC
              MOVE EIBRESP    TO ABND-RESPCODE
              MOVE EIBRESP2   TO ABND-RESP2CODE
      *
      *       Get supplemental information
      *
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
                     WS-TIME-NOW-GRP-SS DELIMITED BY SIZE
                     INTO ABND-TIME
              END-STRING

              MOVE WS-U-TIME   TO ABND-UTIME-KEY
              MOVE 'HBNK'      TO ABND-CODE

              EXEC CICS ASSIGN PROGRAM(ABND-PROGRAM)
              END-EXEC

              MOVE ZEROS      TO ABND-SQLCODE

              STRING 'SM010 - SEND MAP FAIL.'
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

              INITIALIZE WS-FAIL-INFO
              MOVE 'UPDTACCT - SM010 - SEND MAP FAIL' TO
                 WS-CICS-FAIL-MSG
              MOVE WS-CICS-RESP  TO WS-CICS-RESP-DISP
              MOVE WS-CICS-RESP2 TO WS-CICS-RESP2-DISP
              PERFORM ABEND-THIS-TASK
           END-IF.

       SM999.
           EXIT.


       SEND-TERMINATION-MSG SECTION.
       STM010.
      *
      *    Send the termination message
      *
           EXEC CICS SEND TEXT
                     FROM(END-OF-SESSION-MESSAGE)
                     LENGTH(13)
                     ERASE
                     FREEKB
                     RESP(WS-CICS-RESP)
                     RESP2(WS-CICS-RESP2)
           END-EXEC.

       STM999.
           EXIT.


       ABEND-THIS-TASK SECTION.
       ATT010.

           EXEC CICS ABEND
              ABCODE('HBNK')
           END-EXEC.

       ATT999.
           EXIT.


       POPULATE-TIME-DATE SECTION.
       PTD010.

           EXEC CICS ASKTIME
              ABSTIME(WS-U-TIME)
           END-EXEC.

           EXEC CICS FORMATTIME
                     ABSTIME(WS-U-TIME)
                     DDMMYYYY(WS-ORIG-DATE)
                     TIME(WS-TIME-NOW)
                     DATESEP
           END-EXEC.

       PTD999.
           EXIT.

      *> Made with Bob
