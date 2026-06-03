# COBOL Code Generator Skill

## Overview

This skill generates COBOL code following CBSA coding standards with automatic syntax verification and auto-fix using Z Open Editor.

## Features

- **Standards-Compliant Code Generation**: Automatically applies CBSA COBOL coding standards
- **Complete Programs**: Generate full COBOL programs from requirements
- **Code Sections**: Generate specific paragraphs, data structures, or SQL statements
- **Automatic Syntax Verification**: Uses Z Open Editor to detect syntax errors
- **Auto-Fix**: Automatically corrects syntax errors found during verification
- **Quality Assurance**: Validates generated code against coding standards checklist

## Prerequisites

- Z Open Editor extension installed in VS Code
- Access to cbsa-cobol-coding-standards skill
- Understanding of COBOL programming concepts

## Usage

### Activation Triggers

The skill activates when you mention:
- "generate COBOL code"
- "create COBOL program"
- "write COBOL"
- "syntax verification"
- "auto-fix syntax"
- "verify COBOL syntax"
- "Z Open Editor validation"
- "COBOL code generator"

### Example Requests

**Generate Complete Program:**
```
Generate a COBOL program to inquire customer details by customer number
```

**Generate Code Section:**
```
Create a paragraph to validate account number format
```

**Generate Data Structure:**
```
Generate a WORKING-STORAGE structure for holding customer information
```

## Workflow

1. **Activate Standards**: Loads cbsa-cobol-coding-standards skill
2. **Gather Requirements**: Asks clarifying questions about functionality
3. **Generate Code**: Creates COBOL code following standards
4. **Write to File**: Saves generated code to appropriate location
5. **Verify Syntax**: Z Open Editor automatically checks for errors
6. **Auto-Fix Errors**: Automatically corrects any syntax issues found
7. **Final Validation**: Ensures code meets all quality standards

## Integration

This skill works with:
- **cbsa-cobol-coding-standards**: Enforces coding conventions
- **Z Open Editor**: Provides syntax verification
- **Z Code Mode**: Primary mode for mainframe development

## File Structure

```
.bob/skills/cobol-code-generator/
├── SKILL.md          # Main skill instructions
├── README.md         # This file
└── references/       # Additional documentation (if needed)
```

## Maintenance

- Update skill when coding standards evolve
- Add new patterns as they emerge
- Version control all changes
- Communicate updates to team

## Support

For issues or questions:
1. Review the SKILL.md file for detailed instructions
2. Check cbsa-cobol-coding-standards for standards reference
3. Consult existing COBOL programs in src/base/cobol_src/

## Version

- **Version**: 1.0.0
- **Author**: IBM CBSA Development Team
- **Last Updated**: 2026-06-02