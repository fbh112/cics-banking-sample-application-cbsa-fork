# Repository Fork Migration Plan

## Overview
This document outlines the plan to fork the CICS Banking Sample Application repository and migrate local changes to the forked repository.

## Current State

### Original Repository
- **URL**: `https://github.com/cicsdev/cics-banking-sample-application-cbsa.git`
- **Current Branch**: `main`
- **Local Directory**: `/Users/tingwu/git/cics-banking-sample-application-cbsa`

### Target Fork
- **GitHub Username**: `fbh112`
- **Fork Name**: `cics-banking-sample-application-cbsa-fork`
- **Fork URL**: `https://github.com/fbh112/cics-banking-sample-application-cbsa-fork.git`

### Local Changes to Migrate

#### Modified Files
1. `.gitignore` - Added `.bobz/` exclusion for Bob Z Extension
2. `doc/images/Architecture/Base_cobol_CBSA_architecture_diagram.jpg` - Updated diagram
3. `doc/images/Architecture/CarbonReactUI_CBSA_architecture_diagram.jpg` - Updated diagram
4. `doc/images/Architecture/Payment_and_Customer_Services_UI_CBSA_architecture_diagram.jpg` - Updated diagram
5. `doc/images/Architecture/Payment_and_Customer_Services_UI_CBSA_architecture_diagram2.jpg` - Updated diagram

#### New Files
1. `.bob/skills/cbsa-cobol-coding-standards/` - Complete skill directory with COBOL coding standards
2. `.bob/skills/cobol-code-generator/` - Complete skill directory with code generator
3. `src/base/cobol_src/UPDTACCT.cbl` - New COBOL program for account updates
4. `src/base/bms_src/UPDTACM.bms` - New BMS map for UPDTACCT program
5. `src/base/cobol_src/INQCUSPH.cbl` - New COBOL program for customer inquiry
6. `docs/UPDTACCT_README.md` - Documentation for UPDTACCT program
7. `zapp.yaml` - Z Open Editor configuration

## Execution Plan

### Step 1: Create GitHub Fork
**Method**: GitHub CLI (gh)

```bash
gh repo fork cicsdev/cics-banking-sample-application-cbsa \
  --fork-name cics-banking-sample-application-cbsa-fork \
  --clone=false
```

**Alternative**: Manual fork via GitHub web interface
1. Navigate to: https://github.com/cicsdev/cics-banking-sample-application-cbsa
2. Click "Fork" button
3. Set repository name: `cics-banking-sample-application-cbsa-fork`
4. Click "Create fork"

### Step 2: Add Fork as Remote

```bash
git remote add fork https://github.com/fbh112/cics-banking-sample-application-cbsa-fork.git
```

### Step 3: Create Feature Branch and Commit Changes

```bash
# Create and switch to new branch
git checkout -b feature/custom-enhancements

# Stage all changes
git add .

# Commit with descriptive message
git commit -m "Add custom enhancements: UPDTACCT program, Bob skills, and updated documentation

- Added UPDTACCT COBOL program for account updates with BMS map
- Added INQCUSPH COBOL program for customer inquiry
- Created Bob Z Extension skills for COBOL coding standards and code generation
- Updated architecture diagrams
- Added UPDTACCT documentation
- Configured Z Open Editor with zapp.yaml
- Updated .gitignore for Bob Z Extension files"
```

### Step 4: Push to Fork

```bash
# Push feature branch to fork
git push fork feature/custom-enhancements

# Optionally, push main branch as well
git push fork main
```

### Step 5: Verify Migration

```bash
# List all remotes
git remote -v

# Check branch tracking
git branch -vv

# Verify push was successful
git log fork/feature/custom-enhancements --oneline -5
```

### Step 6 (Optional): Reconfigure Default Remote

If you want to make the fork your primary remote:

```bash
# Rename original remote to 'upstream'
git remote rename origin upstream

# Rename fork to 'origin'
git remote rename fork origin

# Update branch tracking
git branch --set-upstream-to=origin/feature/custom-enhancements
```

## Post-Migration Verification Checklist

- [ ] Fork exists at: https://github.com/fbh112/cics-banking-sample-application-cbsa-fork
- [ ] Feature branch `feature/custom-enhancements` is visible in fork
- [ ] All modified files are present in the fork
- [ ] All new files are present in the fork
- [ ] Commit history is preserved
- [ ] Remote configuration is correct (`git remote -v`)
- [ ] Local branch tracks fork remote (if configured)

## Rollback Plan

If issues occur during migration:

1. **Remove fork remote**: `git remote remove fork`
2. **Delete local branch**: `git branch -D feature/custom-enhancements`
3. **Return to main**: `git checkout main`
4. **Verify original state**: `git status`

Local changes remain safe in the working directory and can be re-committed.

## Next Steps After Migration

1. **Create Pull Request** (if contributing back to original):
   - From: `fbh112/cics-banking-sample-application-cbsa-fork:feature/custom-enhancements`
   - To: `cicsdev/cics-banking-sample-application-cbsa:main`

2. **Continue Development**:
   - Work on fork: `git push fork feature/custom-enhancements`
   - Sync with upstream: `git fetch upstream && git merge upstream/main`

3. **Documentation**:
   - Update README in fork with customization details
   - Document any deployment differences

## Notes

- All operations are non-destructive to local repository
- Original remote (`origin`) remains intact unless explicitly renamed
- Changes are isolated in feature branch for easy management
- Fork maintains full git history from original repository

## Execution Date
To be executed: 2026-06-03

## Executed By
User: tingwu (GitHub: fbh112)