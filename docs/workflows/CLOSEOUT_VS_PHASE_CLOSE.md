# Closeout vs Phase Close

**TL;DR:** Both preserve records. Use `phase close` for sequential phases, `closeout` for final project completion.

---

## Both Are Non-Destructive ✅

**IMPORTANT:** Neither command deletes your work or history!

Both commands:
- ✅ Archive all state and logs
- ✅ Generate detailed reports
- ✅ Preserve `.czarina/` directory
- ✅ Keep config.json and worker prompts
- ✅ Stop sessions and daemon
- ✅ Clean up worktrees

The **only difference** is semantic meaning and archive location.

---

## When to Use Each

### Use `czarina phase close`

**Scenario:** Running **sequential phases** on the same project

**Example:**
```bash
# Phase 1: v1.2.0 Gateway implementation
czarina analyze docs/v1.2.0/plan.md --interactive --init
czarina launch
# ... work happens ...
czarina phase close

# Phase 2: v1.3.0 Security features
czarina analyze docs/v1.3.0/plan.md --interactive --init
czarina launch
# ... work happens ...
czarina phase close

# Phase 3: v1.4.0 Performance
czarina analyze docs/v1.4.0/plan.md --interactive --init
czarina launch
```

**Archives to:** `.czarina/phases/phase-TIMESTAMP/`

**Use when:**
- Multiple phases of development planned
- Same codebase, different worker groups
- Want to track phase progression over time

---

### Use `czarina closeout`

**Scenario:** **Final completion** of orchestrated project

**Example:**
```bash
# Project complete
czarina launch
# ... all work done, all PRs merged ...
czarina closeout
```

**Archives to:** `.czarina/archive/TIMESTAMP/`

**Use when:**
- Project orchestration is complete
- All workers done, all features merged
- Transitioning to manual maintenance
- Want to preserve historical record

---

## What Gets Archived

### Phase Close Archives

**Location:** `.czarina/phases/phase-2025-12-09_14-30-00/`

**Contents:**
```
.czarina/phases/phase-2025-12-09_14-30-00/
├── PHASE_SUMMARY.md          # Phase description, workers, next steps
├── config.json               # Config snapshot
├── workers/                  # Worker prompt snapshots
│   ├── worker1.md
│   ├── worker2.md
│   └── ...
└── status/                   # Worker status (if exists)
    └── ...
```

**Summary includes:**
- Workers in this phase
- Branches used
- Next steps for next phase

---

### Closeout Archives

**Location:** `.czarina/archive/2025-12-09_14-30-00/`

**Contents:**
```
.czarina/archive/2025-12-09_14-30-00/
├── CLOSEOUT_REPORT.md        # Final report with git status, workers, etc.
└── status/                   # Worker status (if exists)
    └── ...
```

**Report includes:**
- Sessions stopped
- Daemon status
- Worktree cleanup status
- Git status
- All workers and their descriptions
- Next steps (if restarting)

---

## After Either Command

Both leave you with:

```
.czarina/
├── config.json              # ✅ Preserved
├── workers/                 # ✅ Preserved
│   ├── CZAR.md
│   ├── worker1.md
│   └── ...
├── phases/                  # ✅ Phase archives
│   └── phase-TIMESTAMP/
├── archive/                 # ✅ Closeout archives
│   └── TIMESTAMP/
├── status/                  # ❌ Cleared (empty)
└── worktrees/               # ❌ Removed (optional)
```

**You can always `czarina launch` again!**

---

## Comparison Table

| Feature | `phase close` | `closeout` |
|---------|---------------|------------|
| **Stop sessions** | ✅ Yes | ✅ Yes |
| **Stop daemon** | ✅ Yes | ✅ Yes |
| **Archive state** | ✅ Yes | ✅ Yes |
| **Archive location** | `.czarina/phases/` | `.czarina/archive/` |
| **Remove worktrees** | ✅ Yes | ✅ Yes (asks first) |
| **Keep .czarina/** | ✅ Yes | ✅ Yes |
| **Keep config** | ✅ Yes | ✅ Yes |
| **Clear status** | ✅ Yes | ✅ Yes |
| **Semantic meaning** | "Phase complete" | "Project complete" |
| **Next action** | Start next phase | Done (or restart) |

---

## Examples

### Multi-Phase Project (Use phase close)

```bash
# SARK v1.2.0
czarina analyze docs/v1.2.0/plan.md --interactive --init
czarina launch
# ... 2 weeks of work ...
czarina phase close
# Archived to: .czarina/phases/phase-2025-12-09_14-00-00/

# SARK v1.3.0
czarina analyze docs/v1.3.0/plan.md --interactive --init
czarina launch
# ... 3 weeks of work ...
czarina phase close
# Archived to: .czarina/phases/phase-2025-12-23_10-00-00/

# SARK v1.4.0
czarina analyze docs/v1.4.0/plan.md --interactive --init
czarina launch
# ... 2 weeks of work ...
czarina closeout  # Final completion
# Archived to: .czarina/archive/2026-01-13_15-00-00/
```

**Result:** Complete history in `.czarina/phases/` and `.czarina/archive/`

---

### Single-Phase Project (Use closeout)

```bash
czarina analyze docs/plan.md --interactive --init
czarina launch
# ... work complete ...
czarina closeout
# Archived to: .czarina/archive/2025-12-09_16-00-00/
```

**Result:** Clean completion with archived history

---

## Viewing Historical Records

```bash
# List all phases
ls -la .czarina/phases/

# View phase summary
cat .czarina/phases/phase-2025-12-09_14-30-00/PHASE_SUMMARY.md

# View closeout report
cat .czarina/archive/2025-12-09_16-00-00/CLOSEOUT_REPORT.md

# See what workers were in a phase
cat .czarina/phases/phase-2025-12-09_14-30-00/config.json | jq '.workers'
```

---

## Key Insight

**Neither command is destructive!**

Both preserve:
- Complete configuration
- Worker prompts
- Status archives
- Detailed reports

The `.czarina/` directory is **never deleted** - it contains your orchestration history and can be relaunched at any time.

---

**Version:** v0.4.0
**Status:** ✅ Both commands preserve complete records
