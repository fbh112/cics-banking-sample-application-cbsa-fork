# UPDTACCT - Update Account BMS Program

## Overview

UPDTACCT is a CICS COBOL program that provides a BMS-based interface for updating bank account information using a pseudo-conversational pattern. It allows users to modify account type, interest rate, and overdraft limit fields.

## Program Details

- **Program ID**: UPDTACCT
- **Transaction ID**: OUAT
- **BMS Map**: UPDTAC (Mapset: UPDTACM)
- **Author**: Bob Premium for Z
- **Created**: 2026-06-02

## Architecture

### Pseudo-Conversational Flow

1. **First Invocation** (EIBCALEN=0): Display empty map with cursor positioned at account number field
2. **Account Inquiry**: User enters account number and presses ENTER
   - Program links to INQACC to retrieve account data
   - Account details are displayed on the map
3. **Account Update**: User modifies fields and presses PF5
   - Program validates input data
   - Program links to UPDACC to update the database
   - Success/failure message is displayed

### Program Dependencies

- **INQACC**: Account inquiry program (retrieves account data)
- **UPDACC**: Account update program (performs database update)
- **GETCOMPY**: Utility to retrieve company name
- **ABNDPROC**: Abend handler program

### Copybooks Used

- **SORTCODE**: Bank sort code definition
- **UPDTACM**: BMS map copybook (generated from UPDTACM.bms)
- **DFHAID**: CICS attention identifier definitions
- **ABNDINFO**: Abend information structure
- **INQACC**: INQACC program COMMAREA structure
- **UPDACC**: UPDACC program COMMAREA structure

## Function Keys

| Key | Function |
|-----|----------|
| ENTER | Retrieve account information for the entered account number |
| PF3 | Return to main menu (OMEN transaction) |
| PF5 | Update account with modified information |
| PF12 | Terminate session |
| CLEAR | Clear screen and terminate |
| PA1/PA2/PA3 | Ignored (no action) |

## Screen Fields

### Input Fields

- **ACCOUNT NUMBER**: 8-digit numeric account number (required for inquiry)
- **Account Type**: 8-character account type (modifiable)
- **Interest Rate**: 7-character numeric rate in format 9999.99 (modifiable)
- **Overdraft limit**: 8-digit numeric overdraft limit (modifiable)

### Display-Only Fields

- **Customer Number**: 10-character customer identifier
- **Sort Code**: 6-digit bank branch sort code
- **Account Number**: 8-digit account number (repeated for confirmation)
- **Account Opened**: Date in DD/MM/YYYY format
- **Last statement**: Date in DD/MM/YYYY format
- **Next statement**: Date in DD/MM/YYYY format
- **Available Bal**: Available balance with sign and decimal
- **Actual Balance**: Actual balance with sign and decimal

## Validation Rules

### Account Inquiry (ENTER key)
- Account number must not be spaces or low-values
- Account must exist in the database

### Account Update (PF5 key)
- Account type is required (cannot be spaces or low-values)
- Interest rate is required (cannot be spaces or low-values)
- Overdraft limit is required (cannot be spaces or low-values)

## Error Handling

The program implements comprehensive error handling:

1. **CICS Response Checking**: All CICS commands include RESP and RESP2 checking
2. **Abend Handling**: Links to ABNDPROC for centralized error logging
3. **User Messages**: Clear error messages displayed in the MESSAGE field
4. **Cursor Positioning**: Cursor positioned at the field causing the error

## COMMAREA Structure

The program maintains state across pseudo-conversational interactions using a 99-byte COMMAREA:

```cobol
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
```

## Coding Standards Compliance

The program follows CBSA COBOL coding standards:

✅ **Naming Conventions**
- Program name: 8 characters (UPDTACCT)
- Variables use proper prefixes (WS-, HV-, etc.)
- Paragraph names are descriptive and action-oriented

✅ **Code Structure**
- Standard program layout with proper divisions
- WORKING-STORAGE organized: copybooks, work areas, constants
- Proper use of LINKAGE SECTION for COMMAREA

✅ **Error Handling**
- All CICS commands include RESP checking
- Abend handling configured
- Comprehensive error messages

✅ **Documentation**
- Complete program header with copyright and purpose
- Inline comments explaining business logic
- Clear section and paragraph documentation

✅ **CICS Integration**
- Proper BMS map handling (SEND/RECEIVE)
- Pseudo-conversational pattern correctly implemented
- COMMAREA properly managed across invocations

✅ **Data Types**
- Appropriate use of COMP for binary fields
- Proper numeric field definitions with V for decimal
- Correct date field handling with REDEFINES

## Installation

### 1. Compile BMS Map

```jcl
//MAPCOMP  EXEC PGM=DFHMSD,PARM='TYPE=DSECT,MODE=INOUT,LANG=COBOL'
//STEPLIB  DD DSN=CICS.SDFHLOAD,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSPUNCH DD DSN=&&MAPSET,DISP=(,PASS),UNIT=SYSDA,
//            SPACE=(TRK,(1,1)),DCB=(RECFM=FB,LRECL=80,BLKSIZE=400)
//SYSIN    DD DSN=YOUR.BMS.SOURCE(UPDTACM),DISP=SHR
```

### 2. Compile COBOL Program

```jcl
//CBLCOMP  EXEC PGM=IGYCRCTL,PARM='LIB,CICS,SQL'
//STEPLIB  DD DSN=IGY.SIGYCOMP,DISP=SHR
//SYSLIB   DD DSN=YOUR.COPYBOOK.LIB,DISP=SHR
//         DD DSN=CICS.SDFHCOB,DISP=SHR
//SYSIN    DD DSN=YOUR.COBOL.SOURCE(UPDTACCT),DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DSN=&&LOADSET,DISP=(,PASS)
```

### 3. Define CICS Resources

```cics
CEDA DEFINE PROGRAM(UPDTACCT) GROUP(CBSAGRP)
     LANGUAGE(COBOL)
     RELOAD(NO)
     RESIDENT(NO)
     USAGE(NORMAL)
     USELPACOPY(NO)
     STATUS(ENABLED)

CEDA DEFINE TRANSACTION(OUAT) GROUP(CBSAGRP)
     PROGRAM(UPDTACCT)
     TWASIZE(0)
     PROFILE(DFHCICSA)
     STATUS(ENABLED)
     TASKDATALOC(ANY)
     TASKDATAKEY(USER)

CEDA DEFINE MAPSET(UPDTACM) GROUP(CBSAGRP)
     STATUS(ENABLED)

CEDA INSTALL GROUP(CBSAGRP)
```

## Usage Example

### Scenario: Update Account Interest Rate

1. **Start Transaction**
   ```
   OUAT
   ```

2. **Enter Account Number**
   ```
   ACCOUNT NUMBER: 12345678
   [Press ENTER]
   ```

3. **View Account Details**
   ```
   Customer Number: 0000000001
   Sort Code      : 123456
   Account Number : 12345678
   Account Type   : SAVING
   Interest Rate  : 0325.00
   Account Opened : 01/01/2023
   Overdraft limit: 00001000
   Last statement : 01/05/2023
   Next statement : 01/06/2023
   Available Bal  : +0000001500.00
   Actual Balance : +0000001500.00
   ```

4. **Modify Interest Rate**
   ```
   Interest Rate  : 0350.00
   [Press PF5]
   ```

5. **Confirmation**
   ```
   MESSAGE: Account updated successfully.
   ```

## Troubleshooting

### Common Issues

1. **"Account not found" message**
   - Verify the account number exists in the database
   - Check that the sort code matches the account

2. **"Account update failed" message**
   - Check UPDACC program logs
   - Verify database connectivity
   - Ensure account type is valid

3. **Map display errors**
   - Verify UPDTACM mapset is installed in CICS
   - Check that BMS map was compiled successfully

4. **Abend HBNK**
   - Check ABNDPROC logs for detailed error information
   - Verify all required programs are available
   - Check CICS region logs

## Related Programs

- **BNK1UAC**: Original update account BMS handler (similar functionality)
- **UPDACC**: Backend update logic program
- **INQACC**: Account inquiry program
- **BNKMENU**: Main menu program (OMEN transaction)

## Maintenance Notes

- The program uses the same COMMAREA structure as UPDACC for consistency
- Interest rate conversion uses COMP-1 for proper decimal handling
- Balance fields use signed packed decimal (S9(10)V99) for accuracy
- Date fields use REDEFINES pattern for component access

## Version History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | 2026-06-02 | Bob Premium for Z | Initial creation with pseudo-conversational pattern |

## References

- CBSA Architecture Guide: `doc/CBSA_Architecture_guide.md`
- BMS User Guide: `etc/usage/base/doc/CBSA_BMS_User_Guide.md`
- COBOL Coding Standards: `.bob/skills/cbsa-cobol-coding-standards/SKILL.md`