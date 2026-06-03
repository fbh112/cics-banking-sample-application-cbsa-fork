---
name: cbsa-cobol-coding-standards
description: Enforces COBOL coding standards for CICS Banking Sample Application. Use when generating COBOL code, reviewing code, refactoring, or when user mentions "coding standards", "code conventions", "style guide", or "COBOL standards".
metadata:
  author: IBM CBSA Development Team
  version: 1.0.0
  enforcement-level: moderate
  target-languages: COBOL
---

# CICS Banking Sample Application - COBOL Coding Standards

Enforces coding standards and best practices for the CICS Banking Sample Application COBOL codebase.

## Instructions

### When to Apply This Skill

Use this skill when:

- Generating new COBOL code
- Reviewing existing COBOL code
- Refactoring COBOL programs
- Conducting code reviews
- User explicitly requests standards enforcement

### Step 1: Identify Context

Determine:

- Program type (BMS handler, business logic, utility)
- Database access type (DB2, VSAM, none)
- CICS integration requirements
- Whether it's new code or legacy code modification

### Step 2: Apply COBOL Standards

## 1. Naming Conventions

### Program Names

**Rule:** 8 characters maximum, uppercase, descriptive

**Pattern:**
- BMS handlers: `BNK1xxx` (e.g., `BNK1CAC`, `BNK1DAC`)
- Business logic: Descriptive names (e.g., `CREACC`, `UPDCUST`, `INQACC`)
- Utilities: Descriptive names (e.g., `ABNDPROC`, `GETCOMPY`)

**Examples:**

✅ **Good:**
```cobol
PROGRAM-ID. CREACC.
PROGRAM-ID. BNKMENU.
PROGRAM-ID. ABNDPROC.
```

❌ **Bad:**
```cobol
PROGRAM-ID. CA.
PROGRAM-ID. PROG1.
PROGRAM-ID. CREATEACCOUNTPROGRAM.
```

### Variable Names

**Rules:**
- Prefix with scope indicator: `WS-` (Working-Storage), `HV-` (Host Variables), `LS-` (Local-Storage)
- Use descriptive, hyphenated names
- Constants use level 77 or 78
- Group items clearly indicate hierarchy

**Examples:**

✅ **Good:**
```cobol
01 WS-CICS-WORK-AREA.
   03 WS-CICS-RESP              PIC S9(8) COMP VALUE 0.
   03 WS-CICS-RESP2             PIC S9(8) COMP VALUE 0.

01 HOST-ACCOUNT-ROW.
   03 HV-ACCOUNT-EYECATCHER     PIC X(4).
   03 HV-ACCOUNT-CUST-NO        PIC X(10).
   03 HV-ACCOUNT-SORTCODE       PIC X(6).

77 SYSIDERR-RETRY               PIC 999.
```

❌ **Bad:**
```cobol
01 WORK-AREA.
   03 RESP                      PIC S9(8) COMP.
   03 R2                        PIC S9(8) COMP.

01 ACCOUNT.
   03 EYE                       PIC X(4).
   03 CUST                      PIC X(10).
```

### Paragraph Names

**Rules:**
- Descriptive, action-oriented
- Use hyphens for readability
- Main sections: `PREMIERE SECTION`, `A010`, `A999`
- Exit paragraphs: `GET-ME-OUT-OF-HERE`, `A999`

**Examples:**

✅ **Good:**
```cobol
READ-ACCOUNT-DB2.
CUSTOMER-ACCOUNT-COUNT.
WRITE-PROCTRAN-DB2.
GET-ME-OUT-OF-HERE.
ABEND-HANDLING.
```

❌ **Bad:**
```cobol
PARA1.
PROCESS.
DO-IT.
EXIT-PGM.
```

### Level-88 Condition Names

**Rules:**
- Descriptive boolean conditions
- Use meaningful VALUE clauses
- Group related conditions

**Examples:**

✅ **Good:**
```cobol
01 FLAGS.
   03 SEND-FLAG                 PIC X.
      88 SEND-ERASE             VALUE '1'.
      88 SEND-DATAONLY          VALUE '2'.
      88 SEND-DATAONLY-ALARM    VALUE '3'.

01 DATA-STORE-TYPE              PIC X.
   88 DATASTORE-TYPE-DLI        VALUE '1'.
   88 DATASTORE-TYPE-DB2        VALUE '2'.
   88 DATASTORE-TYPE-VSAM       VALUE 'V'.
```

## 2. Code Structure and Organization

### Program Structure

**Standard Layout:**

```cobol
       CBL CICS('SP,EDF')
       CBL SQL
      ******************************************************************
      * Copyright and description header
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROGNAME.
       AUTHOR. Author Name.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.  IBM-370.
       OBJECT-COMPUTER.  IBM-370.

       INPUT-OUTPUT SECTION.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       [Copybooks first]
       COPY SORTCODE.
       
       [SQL includes]
       EXEC SQL
          INCLUDE ACCDB2
       END-EXEC.
       
       [Host variables]
       [Work areas]
       [Constants]

       LOCAL-STORAGE SECTION.
       [Thread-safe variables]

       LINKAGE SECTION.
       01 DFHCOMMAREA.
           COPY COMMAREA-NAME.

       PROCEDURE DIVISION USING DFHCOMMAREA.
       PREMIERE SECTION.
       A010.
           [Main logic]
       A999.
           EXIT.
```

### WORKING-STORAGE Organization

**Order:**
1. Copybooks (COPY statements)
2. SQL includes (EXEC SQL INCLUDE)
3. Host variables for DB2
4. CICS work areas
5. Program-specific work areas
6. Constants (level 77/78)
7. Abend handling structures

**Example:**

```cobol
WORKING-STORAGE SECTION.

COPY SORTCODE.

EXEC SQL
   INCLUDE ACCDB2
END-EXEC.

01 HOST-ACCOUNT-ROW.
   03 HV-ACCOUNT-EYECATCHER     PIC X(4).
   [...]

01 WS-CICS-WORK-AREA.
   03 WS-CICS-RESP              PIC S9(8) COMP.
   03 WS-CICS-RESP2             PIC S9(8) COMP.

01 WS-U-TIME                    PIC S9(15) COMP-3.
01 WS-ORIG-DATE                 PIC X(10).

77 SYSIDERR-RETRY               PIC 999.

01 WS-ABEND-PGM                 PIC X(8) VALUE 'ABNDPROC'.
01 ABNDINFO-REC.
    COPY ABNDINFO.
```

## 3. Documentation Standards

### Program Header

**Mandatory Elements:**
- Copyright notice
- Program purpose
- Author
- Input/output description
- Special notes (if applicable)

**Example:**

```cobol
      ******************************************************************
      *                                                                *
      *  Copyright IBM Corp. 2023                                      *
      *                                                                *
      ******************************************************************
      ******************************************************************
      * This program takes account information from the BMS
      * application (cust no, name, address and DOB) and then enqueues
      * the Named Counter for ACCOUNT, increments the counter and takes
      * the new account number, & attempt to update the ACCOUNT
      * datastore on DB2. If that is successful, write a rec to
      * the PROCTRAN datastore. Then, if all of that works, DEQUEUE
      * the named counter and return the ACCOUNT number.
      *
      * If for any reason the write to the ACCOUNT or PROCTRAN
      * datastore is unsuccessful, then we need to decrement the Named
      * Counter (restoring it to the start position) and DEQUEUE the
      * Named Counter.
      ******************************************************************
```

### Inline Comments

**Rules:**
- Use `*` in column 7 for full-line comments
- Explain complex logic, not obvious code
- Document business rules
- Explain error handling decisions

**Examples:**

✅ **Good:**
```cobol
      *
      *    We need to validate that the supplied CUSTOMER actually
      *    exists by linking to INQCUST.
      *
       MOVE COMM-CUSTNO IN DFHCOMMAREA TO INQCUST-CUSTNO.

      *
      *    If the link failed for some reason, or the link to INQCUST
      *    indicated that customer information could not be
      *    successfully retrieved then set fail flags and finished.
      *
       IF EIBRESP IS NOT EQUAL TO DFHRESP(NORMAL)
       OR INQCUST-INQ-SUCCESS IS NOT EQUAL TO 'Y'
```

❌ **Bad:**
```cobol
      * Move customer number
       MOVE COMM-CUSTNO TO INQCUST-CUSTNO.
      
      * Check response
       IF EIBRESP NOT = DFHRESP(NORMAL)
```

## 4. Error Handling Patterns

### CICS Response Code Checking

**Mandatory Pattern:**

```cobol
01 WS-CICS-WORK-AREA.
   03 WS-CICS-RESP              PIC S9(8) COMP VALUE 0.
   03 WS-CICS-RESP2             PIC S9(8) COMP VALUE 0.

EXEC CICS LINK PROGRAM('INQCUST ')
          COMMAREA(INQCUST-COMMAREA)
          RESP(WS-CICS-RESP)
END-EXEC.

IF WS-CICS-RESP IS NOT EQUAL TO DFHRESP(NORMAL)
   [Handle error]
END-IF
```

**Critical:** Always use `RESP(WS-CICS-RESP)` and check response codes

### Abend Handling

**Standard Pattern:**

```cobol
01 WS-ABEND-PGM                 PIC X(8) VALUE 'ABNDPROC'.

01 ABNDINFO-REC.
    COPY ABNDINFO.

EXEC CICS HANDLE
   ABEND LABEL(ABEND-HANDLING)
END-EXEC.

[...]

ABEND-HANDLING.
    [Populate ABNDINFO-REC]
    EXEC CICS LINK PROGRAM(WS-ABEND-PGM)
              COMMAREA(ABNDINFO-REC)
    END-EXEC.
```

### DB2 Error Handling

**Pattern:**

```cobol
EXEC SQL
   [SQL statement]
END-EXEC.

IF SQLCODE NOT = 0
   MOVE SQLCODE TO WS-SQLCODE-DISP
   [Handle error - log, abend, or return failure]
END-IF
```

### Named Counter Pattern (Critical)

**Rule:** If DB2 write fails after ENQ/increment, MUST decrement before DEQUEUE

```cobol
EXEC CICS ENQ RESOURCE(NCS-ACC-NO-NAME)
          LENGTH(16)
          RESP(WS-CICS-RESP)
END-EXEC.

[Increment counter]

EXEC SQL
   INSERT INTO ACCOUNT [...]
END-EXEC.

IF SQLCODE NOT = 0
   * CRITICAL: Decrement counter to restore state
   SUBTRACT 1 FROM NCS-ACC-NO-VALUE
   EXEC CICS DEQ RESOURCE(NCS-ACC-NO-NAME)
             LENGTH(16)
   END-EXEC
   [Handle failure]
END-IF.

EXEC CICS DEQ RESOURCE(NCS-ACC-NO-NAME)
          LENGTH(16)
END-EXEC.
```

## 5. DB2 Integration Standards

### Host Variable Naming

**Pattern:** `HV-` prefix + descriptive name matching DB2 column

```cobol
01 HOST-ACCOUNT-ROW.
   03 HV-ACCOUNT-EYECATCHER     PIC X(4).
   03 HV-ACCOUNT-CUST-NO        PIC X(10).
   03 HV-ACCOUNT-SORTCODE       PIC X(6).
   03 HV-ACCOUNT-ACC-NO         PIC X(8).
```

### SQL Includes

**Standard Pattern:**

```cobol
EXEC SQL
   INCLUDE ACCDB2
END-EXEC.

EXEC SQL
   INCLUDE SQLCA
END-EXEC.
```

### Cursor Declarations

**Pattern:**

```cobol
EXEC SQL DECLARE ACC-CURSOR CURSOR FOR
   SELECT ACCOUNT_EYECATCHER,
          ACCOUNT_CUSTOMER_NUMBER,
          ACCOUNT_SORTCODE,
          ACCOUNT_NUMBER,
          [...]
          FROM ACCOUNT
          WHERE ACCOUNT_SORTCODE = :HV-ACCOUNT-SORTCODE
            AND ACCOUNT_NUMBER = :HV-ACCOUNT-ACC-NO
          FOR FETCH ONLY
END-EXEC.
```

### SQL Operations

**Standard Pattern:**

```cobol
EXEC SQL
   INSERT INTO ACCOUNT
      (ACCOUNT_EYECATCHER,
       ACCOUNT_CUSTOMER_NUMBER,
       ACCOUNT_SORTCODE,
       ACCOUNT_NUMBER,
       [...])
   VALUES
      (:HV-ACCOUNT-EYECATCHER,
       :HV-ACCOUNT-CUST-NO,
       :HV-ACCOUNT-SORTCODE,
       :HV-ACCOUNT-ACC-NO,
       [...])
END-EXEC.

IF SQLCODE NOT = 0
   [Handle error]
END-IF.
```

## 6. CICS Integration Standards

### Program Linking

**Pattern:**

```cobol
EXEC CICS LINK PROGRAM('PROGNAME')
          COMMAREA(COMMAREA-NAME)
          RESP(WS-CICS-RESP)
END-EXEC.

IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
   [Handle error]
END-IF.
```

### COMMAREA Usage

**Pattern:**

```cobol
LINKAGE SECTION.
01 DFHCOMMAREA.
    COPY COMMAREA-COPYBOOK.

PROCEDURE DIVISION USING DFHCOMMAREA.
```

### BMS Map Handling

**Pattern:**

```cobol
COPY BNK1MAI.
COPY DFHAID.

EXEC CICS SEND MAP('BNK1MA')
          MAPSET('BNK1MAI')
          FROM(BNK1MAO)
          ERASE
          RESP(WS-CICS-RESP)
END-EXEC.

EXEC CICS RECEIVE MAP('BNK1MA')
          MAPSET('BNK1MAI')
          INTO(BNK1MAI)
          RESP(WS-CICS-RESP)
END-EXEC.
```

## 7. Data Type Standards

### Numeric Fields

**Rules:**
- Use COMP for binary integers
- Use COMP-3 for packed decimal
- Specify SIGN for signed fields
- Use V for implied decimal point

**Examples:**

```cobol
03 WS-CICS-RESP              PIC S9(8) COMP.
03 HV-ACCOUNT-INT-RATE       PIC S9(4)V99 COMP-3.
03 HV-ACCOUNT-AVAIL-BAL      PIC S9(10)V99 COMP-3.
03 WS-U-TIME                 PIC S9(15) COMP-3.
```

### Date Fields

**Pattern:** Use REDEFINES for date parsing

```cobol
01 WS-ORIG-DATE                 PIC X(10).
01 WS-ORIG-DATE-GRP REDEFINES WS-ORIG-DATE.
   03 WS-ORIG-DATE-DD           PIC 99.
   03 FILLER                    PIC X.
   03 WS-ORIG-DATE-MM           PIC 99.
   03 FILLER                    PIC X.
   03 WS-ORIG-DATE-YYYY         PIC 9999.
```

### Eyecatcher Fields

**Pattern:** 4-character identifier with level-88 condition

```cobol
05 ACCOUNT-EYE-CATCHER          PIC X(4).
   88 ACCOUNT-EYECATCHER-VALUE  VALUE 'ACCT'.

05 CUSTOMER-EYECATCHER          PIC X(4).
   88 CUSTOMER-EYECATCHER-VALUE VALUE 'CUST'.
```

## 8. Copybook Standards

### Copybook Usage

**Rules:**
- Use COPY for shared data structures
- Place copybooks at start of WORKING-STORAGE
- Use REPLACING for name conflicts

**Examples:**

```cobol
COPY SORTCODE.
COPY ACCOUNT.
COPY CUSTOMER.
COPY ABNDINFO.

COPY INQACCCU REPLACING ==NUMBER-OF-ACCOUNTS.==
BY ==NUMBER-OF-ACCOUNTS IN INQACCCU-COMMAREA.==.
```

### Copybook Structure

**Pattern:** Start at level 03 for flexibility

```cobol
      ******************************************************************
      *  Copyright IBM Corp. 2023                                      *
      ******************************************************************
           03 ACCOUNT-DATA.
              05 ACCOUNT-EYE-CATCHER        PIC X(4).
              05 ACCOUNT-CUST-NO            PIC 9(10).
              05 ACCOUNT-KEY.
                 07 ACCOUNT-SORT-CODE       PIC 9(6).
                 07 ACCOUNT-NUMBER          PIC 9(8).
```

## 9. Performance Best Practices

### Minimize I/O Operations

- Batch DB2 operations where possible
- Use cursors efficiently
- Close cursors when done

### Use Appropriate Data Types

- COMP for counters and indexes
- COMP-3 for financial calculations
- Avoid unnecessary conversions

### Resource Management

- ENQ/DEQ resources properly
- Release resources in error paths
- Use LOCAL-STORAGE for thread safety

## 10. Security Best Practices

### Input Validation

**Rule:** Validate all external inputs

```cobol
IF WS-USER-INPUT = SPACES OR LOW-VALUES
   MOVE 'N' TO COMM-SUCCESS
   MOVE '1' TO COMM-FAIL-CODE
   PERFORM GET-ME-OUT-OF-HERE
END-IF.
```

### Credential Management

**Rule:** Never hardcode credentials - use environment variables or external configuration

❌ **Bad:**
```cobol
01 DB-PASSWORD     PIC X(20) VALUE 'password123'.
```

✅ **Good:**
```cobol
01 DB-PASSWORD     PIC X(20).
ACCEPT DB-PASSWORD FROM ENVIRONMENT 'DB_PASSWORD'.
```

## Review Checklist

When reviewing or generating COBOL code, verify:

- [ ] Program name follows 8-character convention
- [ ] Variables use proper prefixes (WS-, HV-, LS-)
- [ ] Paragraph names are descriptive and action-oriented
- [ ] Program header includes copyright and purpose
- [ ] CICS commands include RESP checking
- [ ] DB2 operations check SQLCODE
- [ ] Named Counter pattern followed correctly (ENQ/increment/DEQ with error handling)
- [ ] Copybooks used for shared structures
- [ ] Host variables properly named and typed
- [ ] Error handling implemented for all external calls
- [ ] Abend handling configured
- [ ] Level-88 conditions used for boolean flags
- [ ] Date fields use REDEFINES pattern
- [ ] Numeric fields use appropriate COMP types
- [ ] No hardcoded credentials or sensitive data

## Enforcement Level: Moderate

### Critical Violations (Must Fix)

- Missing RESP checking on CICS commands
- Missing SQLCODE checking on DB2 operations
- Incorrect Named Counter pattern (missing decrement on error)
- Hardcoded credentials
- Missing abend handling
- Invalid program name length

### Recommended Improvements (Should Fix)

- Non-standard variable naming
- Missing or inadequate comments
- Inconsistent copybook usage
- Suboptimal data types
- Missing level-88 conditions

### Advisory (Nice to Have)

- Additional inline documentation
- More descriptive paragraph names
- Consistent formatting
- Performance optimizations

## Troubleshooting

### Issue: Legacy Code Doesn't Meet Standards

**Solution:**
- Apply standards to new code only
- Refactor legacy code incrementally when modifying
- Document deviations in legacy code
- Prioritize critical issues (error handling, security)

### Issue: Named Counter Pattern Violation

**Cause:** Missing decrement before DEQUEUE on error

**Solution:**
- Always decrement counter if DB2 write fails after increment
- Test error paths thoroughly
- Review CREACC.cbl for reference implementation

### Issue: Missing RESP Checking

**Cause:** CICS command without RESP parameter

**Solution:**
- Add RESP(WS-CICS-RESP) to all CICS commands
- Check WS-CICS-RESP against DFHRESP(NORMAL)
- Handle non-normal responses appropriately

## References

For detailed examples, see:

- `references/code-examples.md` - Additional code patterns
- `src/base/cobol_src/CREACC.cbl` - Named Counter reference implementation
- `src/base/cobol_src/BNKMENU.cbl` - BMS handler example
- `src/base/cobol_src/INQACC.cbl` - DB2 cursor example
- `src/base/cobol_src/ABNDPROC.cbl` - Abend handling example

## Notes

- These standards are derived from the CICS Banking Sample Application codebase
- Standards apply to new code generation primarily (moderate enforcement)
- Legacy code should be updated incrementally when modified
- Critical patterns (Named Counter, error handling) must always be followed
- Consult AGENTS.md for additional project-specific guidance

---

**Usage:** Reference this skill by saying "Apply CBSA COBOL coding standards" or "Review this code using COBOL standards" or "Generate COBOL code following standards".

**Maintenance:** Update this skill as standards evolve. Version control changes and communicate updates to the team.