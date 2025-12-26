# Migration Guide: v0.5.1 → v0.6.0

## Overview

v0.6.0 is a **minor release** that adds professional closeout reporting capabilities:
- Enhancement #17: Comprehensive Closeout Reports
- Logging auto-initialization

**No breaking changes** - fully backwards compatible with v0.5.1.

## What's New

### 1. Comprehensive Closeout Reports (Enhancement #17)

**Before (v0.5.1):**
```bash
czarina closeout
# Generated basic CLOSEOUT_REPORT.md with minimal info:
# - Sessions stopped
# - Daemon status
# - Worker list
```

**After (v0.6.0):**
```bash
czarina closeout
# Generates comprehensive reports with:
# - Worker summaries and branch information
# - Detailed commit history per worker
# - Files changed analysis
# - Orchestration duration tracking
# - Auto-archive to .czarina/phases/
```

**What's in the new reports:**

1. **CLOSEOUT.md** - Full detailed report:
   - Executive summary with key metrics table
   - Worker summaries with branches and activity
   - Commit history per worker
   - Files changed by worker and overall
   - Git statistics and repository state
   - Configuration archive
   - Duration metrics (hours/minutes)

2. **PHASE_SUMMARY.md** - Quick reference:
   - High-level stats
   - Archive contents
   - Links to detailed report

**Archive structure:**
```
.czarina/
├── archive/
│   └── 2025-12-26_14-30-00/
│       ├── CLOSEOUT.md          # Full report
│       └── status/               # Logs backup
└── phases/
    └── phase-1-v0.6.0/
        ├── CLOSEOUT.md          # Full report (copy)
        ├── PHASE_SUMMARY.md     # Quick summary
        ├── config.json          # Configuration
        └── logs/                # Logs backup
```

**Key metrics included:**
- Total commits across all workers
- Files changed count
- Lines added/removed
- Orchestration duration
- Start and end timestamps
- Worker count and activity

### 2. Logging Auto-Initialization

**Before (v0.5.1):**
- Logging system required manual setup
- Log directories created on first log write

**After (v0.6.0):**
```bash
czarina launch
# Logging system automatically initialized:
# - .czarina/logs/ directory created
# - orchestration-start.timestamp recorded
# - Ready for worker logs and events
```

**Benefits:**
- Zero manual setup
- Duration tracking works immediately
- Consistent logging structure

## Upgrade Steps

### Step 1: Update Czarina

```bash
cd /path/to/czarina
git fetch origin
git checkout v0.6.0
```

### Step 2: Test Closeout Reports (Optional)

```bash
# Run a test orchestration
czarina launch
# ... do some work ...

# Generate closeout report
czarina closeout

# Verify reports were generated
ls .czarina/archive/*/CLOSEOUT.md
ls .czarina/phases/phase-1-*/CLOSEOUT.md
ls .czarina/phases/phase-1-*/PHASE_SUMMARY.md
```

### Step 3: Review Report Content

```bash
# View the comprehensive report
cat .czarina/archive/*/CLOSEOUT.md

# View the quick summary
cat .czarina/phases/phase-1-*/PHASE_SUMMARY.md
```

## New Template System

The closeout system uses a template:

**Template location:**
```
czarina-core/templates/CLOSEOUT.md
```

**Placeholders available:**
- `{PROJECT_NAME}` - Project name
- `{VERSION}` - Current version/tag
- `{DURATION}` - Orchestration duration
- `{WORKER_COUNT}` - Number of workers
- `{TOTAL_COMMITS}` - Total commit count
- `{FILES_CHANGED}` - Files modified count
- `{LINES_ADDED}` - Lines added
- `{LINES_REMOVED}` - Lines removed
- And many more...

**Customization:**
You can customize the template to fit your needs. The script will automatically populate all placeholders when generating reports.

## Backwards Compatibility

**100% compatible** with v0.5.1:
- Existing closeout workflow unchanged
- Enhanced reports generated automatically
- No config changes required
- Fallback to basic report if template missing

**What stays the same:**
- `czarina closeout` command
- Tmux session cleanup
- Worktree removal options
- Archive directory structure

**What's enhanced:**
- Report content (much richer)
- Archive organization (phases directory)
- Duration tracking (automatic)

## Phase Archives

The new phase archive system organizes closeout data for long-term reference:

**Purpose:**
- Historical record of each orchestration phase
- Easy comparison between versions
- Project documentation and audit trail

**Structure:**
```bash
.czarina/phases/
├── phase-1-v0.5.0/
│   ├── CLOSEOUT.md
│   ├── PHASE_SUMMARY.md
│   ├── config.json
│   └── logs/
├── phase-1-v0.6.0/
│   ├── CLOSEOUT.md
│   ├── PHASE_SUMMARY.md
│   ├── config.json
│   └── logs/
└── phase-1-v1.0.0/
    ├── CLOSEOUT.md
    ├── PHASE_SUMMARY.md
    ├── config.json
    └── logs/
```

**Naming convention:**
- `phase-1-{version}` - Uses current git tag or v0.0.0

## Troubleshooting

### Closeout reports not generating?

```bash
# Check template exists
ls czarina-core/templates/CLOSEOUT.md

# Check closeout script syntax
bash -n czarina-core/closeout-project.sh

# Run closeout with verbose output
bash -x czarina-core/closeout-project.sh .czarina
```

### Duration shows "Unknown"?

```bash
# Check if timestamp file exists
ls .czarina/status/orchestration-start.timestamp

# If missing, launch again to create it
czarina closeout
czarina launch
```

### Reports missing worker information?

```bash
# Verify workers have branches
git branch -a | grep feat

# Check config.json has worker definitions
jq '.workers' .czarina/config.json
```

### Template placeholders not replaced?

```bash
# Check if sed is available
which sed

# Verify template file is readable
cat czarina-core/templates/CLOSEOUT.md

# Check for special characters in project name
jq '.project.name' .czarina/config.json
```

## Migration Checklist

- [ ] Update czarina to v0.6.0
- [ ] Review new CLOSEOUT.md template
- [ ] Test closeout report generation
- [ ] Verify phase archives are created
- [ ] Check duration tracking works
- [ ] Review worker summaries in reports
- [ ] Confirm commit history is accurate
- [ ] Review [CHANGELOG.md](../CHANGELOG.md) for full details

## Examples

### Example 1: Generated Closeout Report

**Sample metrics table:**
```
| Metric | Value |
|--------|-------|
| Workers Active | 4 |
| Total Commits | 47 |
| Files Changed | 23 |
| Lines Added | 1,245 |
| Lines Removed | 387 |
| Duration | 3h 42m |
```

**Sample worker summary:**
```markdown
### Worker: backend

**Branches:**
- `feat/backend-api`

Commits: 15

Files changed:
- src/api/routes.py
- src/api/models.py
- tests/test_api.py
```

### Example 2: Phase Archive Usage

**Scenario:** Comparing orchestrations across versions

```bash
# List all phases
ls .czarina/phases/

# Compare worker activity between phases
diff .czarina/phases/phase-1-v0.5.0/CLOSEOUT.md \
     .czarina/phases/phase-1-v0.6.0/CLOSEOUT.md

# Review specific phase
cat .czarina/phases/phase-1-v0.6.0/PHASE_SUMMARY.md
```

### Example 3: Custom Template

**Scenario:** Add custom sections to closeout report

```bash
# Edit template
nano czarina-core/templates/CLOSEOUT.md

# Add custom section:
## Custom Metrics

- Build time: {BUILD_TIME}
- Test coverage: {TEST_COVERAGE}
- ...

# Modify closeout-project.sh to populate custom placeholders
nano czarina-core/closeout-project.sh
```

## New Documentation

This release includes enhanced closeout documentation:

- Comprehensive CLOSEOUT.md reports with all metrics
- PHASE_SUMMARY.md for quick reference
- Template system for customization

## Known Limitations

**Current limitations:**
- Duration requires orchestration-start.timestamp (created on launch)
- Git statistics based on `main` branch comparison
- Worker branch detection uses pattern matching
- Template uses sed for placeholder replacement (may have issues with special chars)

**Fallback behavior:**
- If template not found: Generates basic report
- If timestamp missing: Duration shows "Unknown"
- If worker branches not found: Shows "No branches found"

## Questions?

See the v0.6.0 release notes: https://github.com/apathy-ca/czarina/releases/tag/v0.6.0

**Documentation:**
- [CHANGELOG.md](../CHANGELOG.md) - Full changelog
- [CLOSEOUT template](../czarina-core/templates/CLOSEOUT.md) - Report template

**Issues:**
- Report bugs: https://github.com/apathy-ca/czarina/issues
- Ask questions: https://github.com/apathy-ca/czarina/discussions
