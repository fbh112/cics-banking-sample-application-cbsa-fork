---
name: cobol-code-generator
description: Generates COBOL code following CBSA coding standards with automatic syntax verification and auto-fix using Z Open Editor. Use when user asks to "generate COBOL code", "create COBOL program", "write COBOL", or mentions "syntax verification", "auto-fix syntax", "verify COBOL syntax", "Z Open Editor validation", "COBOL code generator".
metadata:
  author: IBM CBSA Development Team
  version: 1.0.0
  target-languages: COBOL
  requires-skills: cbsa-cobol-coding-standards
  tools: Z Open Editor
---

# COBOL Code Generator with Standards Enforcement

Generates COBOL code (complete programs or code sections) following CBSA coding standards with automatic syntax verification and auto-fix capabilities using Z Open Editor.

## Prerequisites

Before using this skill, ensure:

- Z Open Editor extension is installed and active in VS Code
- Access to `.bob/skills/cbsa-cobol-coding-standards/SKILL.md` for standards reference
- Understanding of the code generation requirements (program type, functionality)
- Target file location determined (for complete programs)

## Instructions

### Step 1: Activate Coding Standards

**MANDATORY FIRST STEP:**

Before generating any COBOL code, activate the CBSA coding standards skill:

```
use_skill: cbsa-cobol-coding-standards
```

This loads the coding standards that will be applied during code generation.

**Standards to Apply:**

- Naming conventions (program names, variables, paragraphs)
- Code structure and organization
- Documentation standards
- Error handling patterns
- DB2 integration standards
- CICS integration standards
- Data type standards

### Step 2: Gather Requirements

**Determine Code Generation Scope:**

**For Complete Programs:**

Ask the user:
- Program purpose and functionality
- Program type (BMS handler, business logic, utility)
- Database access requirements (DB2, VSAM, none)
- CICS integration requirements
- Input/output specifications
- Error handling requirements

**For Code Sections:**

Ask the user:
- Section type (paragraph, data structure, SQL statement)
- Purpose and functionality
- Integration context (where it will be used)
- Required variables or dependencies

**Example Questions:**

1. "What is the primary purpose of this COBOL program/section?"
2. "Does it need to access DB2 databases? If yes, which tables?"
3. "Does it need CICS integration? If yes, which commands?"
4. "What are the input parameters and expected outputs?"
5. "Are there specific error handling requirements?"

### Step 3: Generate COBOL Code

**Code Generation Process:**

1. **Apply Standards from Step 1**
   - Use naming conventions from cbsa-cobol-coding-standards
   - Follow structure patterns from standards
   - Include mandatory documentation headers

2. **Generate Code Structure**

**For Complete Programs:**

```cobol
       CBL CICS('SP,EDF')
       CBL SQL
      ******************************************************************
      * Copyright IBM Corp. 2023                                       *
      ******************************************************************
      ******************************************************************
      * [Program Purpose Description]
      *
      * [Input/Output Description]
      *
      * [Special Notes]
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
       FILE SECTION.

       WORKING-STORAGE SECTION.
       [Copybooks]
       [SQL includes]
       [Host variables]
       [Work areas]
       [Constants]

       LOCAL-STORAGE SECTION.
       [Thread-safe variables]

       LINKAGE SECTION.
       01 DFHCOMMAREA.
           COPY [COMMAREA-NAME].

       PROCEDURE DIVISION USING DFHCOMMAREA.
       PREMIERE SECTION.
       A010.
           [Main logic]
       A999.
           EXIT.
```

**For Code Sections:**

Generate the specific section following standards:
- Paragraphs: Descriptive names, proper structure
- Data structures: Proper level numbers, prefixes
- SQL statements: Host variables, error checking

3. **Include Error Handling**

Always include:
- CICS response code checking
- DB2 SQLCODE checking
- Abend handling setup
- Named Counter pattern (if applicable)

4. **Add Documentation**

Include:
- Program/section header comments
- Inline comments for complex logic
- Business rule explanations

### Step 4: Write Generated Code to File

**For Complete Programs:**

Use `write_to_file` tool to create the new COBOL program:

```xml
<write_to_file>
<path>src/base/cobol_src/[PROGNAME].cbl</path>
<content>
[Generated COBOL code]
<line_count>[total lines]</line_count>
</write_to_file>
```

**For Code Sections:**

Use `insert_content` or `apply_diff` to add the section to an existing file.

### Step 5: Automatic Syntax Verification

**CRITICAL: After writing code, immediately verify syntax using Z Open Editor**

**Verification Process:**

1. **Open the file in VS Code** (if not already open)
   - Z Open Editor will automatically parse the COBOL syntax
   - Syntax errors will appear in the Problems panel

2. **Check for Syntax Errors**

Use `execute_command` to check for problems:

```xml
<execute_command>
<command>code --list-extensions | grep -i "cobol"</command>
</execute_command>
```

3. **Identify Syntax Issues**

Common syntax errors to check:
- Missing periods at end of sentences
- Incorrect column alignment (columns 7, 8-11, 12-72)
- Invalid COBOL keywords or syntax
- Mismatched parentheses or quotes
- Invalid data type declarations
- Missing END-IF, END-PERFORM, END-EXEC statements

### Step 6: Auto-Fix Syntax Errors

**MANDATORY: If syntax errors are found, automatically fix them**

**Auto-Fix Strategy:**

1. **Read the file with errors**

```xml
<read_file>
<args>
  <file>
    <path>src/base/cobol_src/[PROGNAME].cbl</path>
  </file>
</args>
</read_file>
```

2. **Analyze Error Messages**

Common fixes:
- **Missing period**: Add period at end of sentence
- **Column alignment**: Adjust spacing to proper columns
- **Invalid keyword**: Correct spelling or syntax
- **Missing END statement**: Add appropriate END-IF, END-PERFORM, etc.
- **Data type error**: Correct PIC clause or COMP usage

3. **Apply Fixes Using apply_diff**

```xml
<apply_diff>
<path>src/base/cobol_src/[PROGNAME].cbl</path>
<diff>
<<<<<<< SEARCH
:start_line:[line number]
-------
[Incorrect code]
=======
[Corrected code]
>>>>>>> REPLACE
</diff>
</apply_diff>
```

4. **Verify Fixes**

After applying fixes:
- Z Open Editor will re-parse the file
- Check if errors are resolved
- Repeat fix process if needed

5. **Iterate Until Clean**

Continue fixing until:
- No syntax errors remain in Problems panel
- All COBOL syntax is valid
- Code follows CBSA standards

### Step 7: Final Validation

**Validation Checklist:**

- [ ] No syntax errors in Z Open Editor
- [ ] Program name follows 8-character convention
- [ ] Variables use proper prefixes (WS-, HV-, LS-)
- [ ] Paragraph names are descriptive
- [ ] Program header includes copyright and purpose
- [ ] CICS commands include RESP checking
- [ ] DB2 operations check SQLCODE
- [ ] Error handling implemented
- [ ] Code follows CBSA coding standards
- [ ] Documentation is complete

**If validation fails:**
- Return to Step 6 to fix remaining issues
- Re-verify after fixes

**If validation passes:**
- Inform user that code generation is complete
- Provide summary of generated code
- Offer to explain any section if needed

## Common Scenarios

### Scenario 1: Generate Complete COBOL Program

**Context:** User needs a new COBOL program for account inquiry

**Steps:**

1. Activate cbsa-cobol-coding-standards skill
2. Gather requirements:
   - Purpose: Inquire account details
   - DB2 access: ACCOUNT table
   - CICS: LINK to other programs
   - Input: Account number via COMMAREA
   - Output: Account details in COMMAREA
3. Generate program structure following standards
4. Write to `src/base/cobol_src/INQACC2.cbl`
5. Z Open Editor automatically checks syntax
6. Auto-fix any syntax errors found
7. Validate final code

**Expected Result:** Complete, syntactically correct COBOL program following CBSA standards

### Scenario 2: Generate Code Section (Paragraph)

**Context:** User needs a new paragraph for customer validation

**Steps:**

1. Activate cbsa-cobol-coding-standards skill
2. Gather requirements:
   - Purpose: Validate customer exists
   - Action: LINK to INQCUST program
   - Error handling: Check RESP code
3. Generate paragraph following naming conventions
4. Insert into existing program using insert_content
5. Z Open Editor checks syntax in context
6. Auto-fix any syntax errors
7. Validate integration with existing code

**Expected Result:** New paragraph integrated into existing program, syntactically correct

### Scenario 3: Generate Data Structure

**Context:** User needs a new WORKING-STORAGE data structure

**Steps:**

1. Activate cbsa-cobol-coding-standards skill
2. Gather requirements:
   - Purpose: Hold customer information
   - Fields: Customer number, name, address
   - Prefix: WS- for working storage
3. Generate data structure following standards
4. Insert into WORKING-STORAGE SECTION
5. Z Open Editor validates data declarations
6. Auto-fix any PIC clause or level number errors
7. Validate structure

**Expected Result:** Properly formatted data structure in WORKING-STORAGE

## Troubleshooting

### Issue: Z Open Editor Not Detecting Syntax Errors

**Symptoms:**
- No syntax errors shown in Problems panel
- Code appears to have obvious syntax issues

**Cause:** Z Open Editor may not be active or configured properly

**Solution:**

1. Verify Z Open Editor extension is installed:
   ```bash
   code --list-extensions | grep -i "cobol"
   ```
2. Check if file is recognized as COBOL (check language mode in status bar)
3. Reload VS Code window if needed
4. Manually trigger syntax check by saving the file

### Issue: Auto-Fix Creates New Syntax Errors

**Symptoms:**
- After applying fix, new syntax errors appear
- Errors cascade to other lines

**Cause:** Fix was applied incorrectly or affected surrounding code

**Solution:**

1. Read the entire file to understand context
2. Analyze the relationship between fixed line and surrounding code
3. Apply more comprehensive fix using apply_diff with larger context
4. Verify fix doesn't break other statements
5. Test incrementally - fix one error at a time

### Issue: Generated Code Doesn't Follow Standards

**Symptoms:**
- Variable names don't use proper prefixes
- Paragraph names are not descriptive
- Missing documentation

**Cause:** cbsa-cobol-coding-standards skill not activated or not applied

**Solution:**

1. Verify Step 1 was completed (activate standards skill)
2. Re-read the coding standards
3. Regenerate code applying standards explicitly
4. Use apply_diff to fix non-compliant sections
5. Validate against standards checklist

### Issue: Cannot Write to Target File

**Symptoms:**
- write_to_file fails
- Permission denied or file locked

**Cause:** File may be open in editor or permissions issue

**Solution:**

1. Check if file is already open in VS Code
2. Close the file if open
3. Verify write permissions on target directory
4. Try alternative path if needed
5. Use insert_content if file exists and should be modified

### Issue: Syntax Errors in Complex SQL Statements

**Symptoms:**
- SQL EXEC blocks show syntax errors
- Host variable references incorrect

**Cause:** SQL syntax or host variable naming issues

**Solution:**

1. Verify SQL syntax follows DB2 standards
2. Check host variable names use HV- prefix
3. Ensure EXEC SQL and END-EXEC are properly placed
4. Validate SQL statement structure
5. Test SQL separately if possible

## Best Practices

### Do's

1. **Always Activate Standards First** - Never generate code without loading cbsa-cobol-coding-standards
2. **Gather Complete Requirements** - Ask clarifying questions before generating code
3. **Generate Incrementally** - For complex programs, generate section by section
4. **Verify Immediately** - Check syntax after each code generation
5. **Auto-Fix Promptly** - Fix syntax errors as soon as they're detected
6. **Document Thoroughly** - Include comprehensive comments and headers
7. **Follow Patterns** - Use existing programs as reference (CREACC.cbl, INQACC.cbl)
8. **Test Error Paths** - Ensure error handling is complete
9. **Validate Against Standards** - Use the standards checklist
10. **Iterate Until Perfect** - Don't stop until code is syntactically correct and standards-compliant

### Don'ts

1. **Don't Skip Standards Activation** - This is mandatory for quality code
2. **Don't Generate Without Requirements** - Understand what's needed first
3. **Don't Ignore Syntax Errors** - Fix all errors before completing
4. **Don't Hardcode Values** - Use constants or copybooks
5. **Don't Skip Error Handling** - Always include RESP and SQLCODE checks
6. **Don't Forget Documentation** - Headers and comments are required
7. **Don't Violate Naming Conventions** - Follow the established patterns
8. **Don't Create Monolithic Code** - Break into logical paragraphs
9. **Don't Skip Validation** - Always complete the validation checklist
10. **Don't Assume Syntax is Correct** - Always verify with Z Open Editor

## References

For detailed information, see:

- `.bob/skills/cbsa-cobol-coding-standards/SKILL.md` - Complete coding standards
- `.bob/skills/cbsa-cobol-coding-standards/references/code-examples.md` - Additional patterns
- `src/base/cobol_src/CREACC.cbl` - Reference implementation for account creation
- `src/base/cobol_src/INQACC.cbl` - Reference implementation for account inquiry
- `src/base/cobol_src/BNKMENU.cbl` - Reference implementation for BMS handling

## Notes

- This skill REQUIRES the cbsa-cobol-coding-standards skill to be activated first
- Z Open Editor must be installed and active for syntax verification
- Auto-fix is mandatory - do not leave syntax errors unresolved
- Generated code must pass all validation checks before completion
- For complex programs, consider generating incrementally (section by section)
- Always test error handling paths
- Keep generated code maintainable and well-documented

## Integration with Z Code Mode

This skill integrates with Z Code mode workflows:

- **Code Generation**: Primary use case for creating new COBOL programs
- **Standards Enforcement**: Works with cbsa-cobol-coding-standards skill
- **Syntax Verification**: Leverages Z Open Editor for real-time validation
- **Auto-Fix**: Automatically corrects syntax errors
- **Quality Assurance**: Ensures generated code meets CBSA standards

---

**Usage:** Reference this skill by saying "Generate COBOL code for [purpose]" or "Create a COBOL program to [functionality]" or "Use cobol-code-generator to help with this task."

**Maintenance:** Update this skill as coding standards evolve or new patterns emerge. Version control changes and communicate updates to the team.