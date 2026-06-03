# CBSA COBOL Coding Standards Skill

This skill enforces COBOL coding standards for the CICS Banking Sample Application (CBSA) project.

## Overview

The coding standards in this skill were derived by analyzing the existing CBSA COBOL codebase, extracting patterns, conventions, and best practices used throughout the application.

## Skill Contents

- **SKILL.md** - Main skill file with comprehensive coding standards
- **references/code-examples.md** - Additional code examples and anti-patterns

## Standards Coverage

This skill covers:

1. **Naming Conventions**
   - Program names (8 characters, descriptive)
   - Variable names (prefixed: WS-, HV-, LS-)
   - Paragraph names (action-oriented, hyphenated)
   - Level-88 condition names

2. **Code Structure**
   - Standard program layout
   - WORKING-STORAGE organization
   - Copybook usage patterns
   - PROCEDURE DIVISION structure

3. **Documentation**
   - Program headers (copyright, purpose, author)
   - Inline comments (business logic, not obvious code)
   - Complex logic explanation

4. **Error Handling**
   - CICS RESP checking (mandatory)
   - DB2 SQLCODE checking (mandatory)
   - Abend handling setup
   - Named Counter pattern (critical)

5. **DB2 Integration**
   - Host variable naming and types
   - SQL includes and SQLCA
   - Cursor declarations and usage
   - INSERT/UPDATE/SELECT patterns

6. **CICS Integration**
   - Program linking with RESP
   - COMMAREA usage
   - BMS map handling
   - Resource management (ENQ/DEQ)

7. **Data Types**
   - Numeric fields (COMP, COMP-3)
   - Date handling with REDEFINES
   - Eyecatcher fields with level-88

8. **Performance & Security**
   - I/O optimization
   - Resource management
   - Input validation
   - No hardcoded credentials

## Enforcement Level

**Moderate** - Critical violations must be fixed, recommended improvements should be addressed when practical.

### Critical Violations (Must Fix)
- Missing RESP checking on CICS commands
- Missing SQLCODE checking on DB2 operations
- Incorrect Named Counter pattern
- Hardcoded credentials
- Missing abend handling

### Recommended Improvements (Should Fix)
- Non-standard variable naming
- Missing or inadequate comments
- Inconsistent copybook usage
- Suboptimal data types

### Advisory (Nice to Have)
- Additional documentation
- More descriptive names
- Performance optimizations

## Usage

### Activating the Skill

The skill activates automatically when you:
- Generate new COBOL code
- Review existing COBOL code
- Refactor COBOL programs
- Mention "coding standards", "code conventions", or "COBOL standards"

### Explicit Activation

You can also explicitly reference the skill:
- "Apply CBSA COBOL coding standards"
- "Review this code using COBOL standards"
- "Generate COBOL code following standards"

## Key Patterns

### Named Counter Pattern (Critical)

This is the most critical pattern in the codebase. When using Named Counters:

1. ENQ the resource
2. Increment the counter
3. Attempt DB2 write
4. **If DB2 write fails: DECREMENT counter before DEQUEUE**
5. DEQUEUE the resource

See `CREACC.cbl` for reference implementation.

### Error Handling Pattern

Always check return codes:

```cobol
EXEC CICS [COMMAND]
          RESP(WS-CICS-RESP)
END-EXEC.

IF WS-CICS-RESP NOT = DFHRESP(NORMAL)
   [Handle error]
END-IF.
```

### DB2 Pattern

Always check SQLCODE:

```cobol
EXEC SQL
   [SQL STATEMENT]
END-EXEC.

IF SQLCODE NOT = 0
   [Handle error]
END-IF.
```

## Source Analysis

Standards were derived from analyzing these key programs:

- **CREACC.cbl** - Account creation with Named Counter pattern
- **BNKMENU.cbl** - BMS handler and menu navigation
- **INQACC.cbl** - DB2 cursor usage and inquiry logic
- **UPDCUST.cbl** - Customer update with VSAM
- **DBCRFUN.cbl** - Debit/credit functions
- **ABNDPROC.cbl** - Centralized abend handling
- **GETCOMPY.cbl** - Simple utility program

Plus copybooks:
- **ACCOUNT.cpy** - Account data structure
- **CUSTOMER.cpy** - Customer data structure
- **ABNDINFO.cpy** - Abend information structure

## Maintenance

This skill should be updated when:
- New coding patterns are established
- Standards evolve
- New best practices are identified
- Critical issues are discovered

Version control this skill directory alongside your codebase.

## References

- Main skill: `SKILL.md`
- Code examples: `references/code-examples.md`
- Source programs: `src/base/cobol_src/`
- Copybooks: `src/base/cobol_copy/`
- Project guidance: `AGENTS.md`

## Version History

- **v1.0.0** (2026-06-02) - Initial release
  - Derived from CBSA codebase analysis
  - Covers all major coding areas
  - Moderate enforcement level
  - Comprehensive examples and anti-patterns

## Support

For questions or updates to these standards, consult:
- The development team
- AGENTS.md for project-specific guidance
- Source code examples in the codebase