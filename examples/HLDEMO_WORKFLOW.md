# HLDemo: Multi-Phase Workflow Example

A real-world example of using Czarina to orchestrate a multi-phase project, demonstrating the complete workflow from initialization through multiple phases.

## Project Overview

**Project:** Virtual Book - Animal Quest
**Type:** Interactive virtual book application with multiple character perspectives
**Phases:** 3 phases of progressive enhancement
**Total Workers:** 17 workers across all phases
**Duration:** Multi-day development cycle

### Architecture

- **Frontend:** React + TypeScript + Vite
- **Styling:** TailwindCSS
- **State:** Zustand
- **Features:** 34 chapters, 7 characters, dark mode, multi-perspective narrative

---

## Phase 1: Story Foundation (v0.1.0)

**Objective:** Build the initial story application with character arcs and UI

### Workers (10)

| Worker | Role | Dependencies | Description |
|--------|------|--------------|-------------|
| `project-setup` | code | - | Initialize project structure, dependencies, build config |
| `character-cyrano` | code | project-setup | Develop Ramona's story arc (Keel-billed Toucan) |
| `character-lily` | code | project-setup | Develop Lily's story arc (Calico cat) |
| `character-archimedes` | code | project-setup | Develop Paul's story arc (Great Horned Owl) |
| `character-ramona` | code | project-setup | Develop Cyrano's story arc (Large black/white cat) |
| `character-paul` | code | project-setup | Develop Archimedes' story arc (Small black/white cat) |
| `character-frank` | code | project-setup | Develop Frank's story arc |
| `character-steve` | code | project-setup | Develop Steve's story arc |
| `story-integration` | integration | character-* | Integrate all character arcs and story elements |
| `ui-navigation` | code | project-setup, story-integration | Build UI for navigating perspectives |

### Results

- ✅ 34 chapters written across 7 characters
- ✅ React application with component architecture
- ✅ Character profiles and story arcs documented
- ✅ Navigation UI implemented
- ✅ All work merged to master branch

### Commands Used

```bash
# Initialize phase 1
czarina init phase-1-plan.md

# Launch workers
czarina launch

# Monitor progress
czarina status
tmux attach -t czarina-virtual_book___animal_quest

# Close phase when complete
czarina phase close
```

### Deliverables

- Source code in `src/` with components, data, types
- 34 chapter markdown files
- Character profile documentation
- Integration guides and README
- All branches merged: `cz1/feat/*` → `master`

---

## Phase 2: Mature Themes (v0.2.0)

**Objective:** Elevate the narrative to sophisticated adult themes, deepen character complexity, and enhance emotional resonance

### Workers (4)

| Worker | Role | Dependencies | Description |
|--------|------|--------------|-------------|
| `narrative-maturity` | code | - | Add mature themes: mortality, loss, philosophical inquiry |
| `character-relationships` | code | narrative-maturity | Develop complex adult dynamics and tensions |
| `thematic-depth` | code | narrative-maturity, character-relationships | Weave philosophical themes: consciousness, existence, free will |
| `integration-mature` | integration | All above | Integrate mature content with tonal consistency |

### Workflow Improvements Tested

This phase validated several v0.8.0 improvements:
- ✅ Phase display in `czarina status` and `czarina launch`
- ✅ Automatic phase field added to workers
- ✅ Dependencies parser handling bracket notation
- ✅ Enhanced error messages for missing config

### Commands Used

```bash
# Initialize phase 2
czarina init phase-2-plan.md

# Fix phase numbering (auto-detected and fixed)
czarina phase set 2

# Launch workers
czarina launch

# Close phase
czarina phase close
```

---

## Phase 3: Epic Fantasy (v0.3.0)

**Objective:** Transform the story into epic fantasy with terrestrial mammals, anthropomorphized characters, and grand adventure themes

### Workers (3)

| Worker | Role | Dependencies | Description |
|--------|------|--------------|-------------|
| `species-transformation` | code | - | Convert oceanic/avian characters to terrestrial mammals |
| `epic-worldbuilding` | code | species-transformation | Create fantasy world: geography, magic systems, cultures |
| `epic-integration` | integration | species-transformation, epic-worldbuilding | Integrate transformations into cohesive narrative |

### Phase Close Validation

Phase 3 closeout tested the improved `phase-close.sh` script:

```
1. Stopping tmux sessions...
   Stopping session: czarina-virtual_book___animal_quest
   Stopping session: czarina-virtual_book___animal_quest-mgmt
   ✅ Stopped 2 session(s)

2. Stopping daemon...
   No daemon session found

3. Archiving phase state...
   ✅ Phase data archived: .czarina/phases/phase-1-v0.3.0

4. Smart worktree cleanup...
   ✅ epic-integration: Clean (removing)
   ✅ epic-worldbuilding: Clean (removing)
   ✅ species-transformation: Clean (removing)
   📦 Removed 3 worktree(s), kept 0 with changes

5. Clearing phase artifacts...
   ✅ Config cleared
   ✅ Worker prompts cleared
   ✅ Status cleared
```

**All 5 steps completed successfully** - validating the robustness fix.

---

## Project Statistics

### Overall Metrics

- **Total Phases:** 3
- **Total Workers:** 17 (10 + 4 + 3)
- **Git Branches:** 17 feature branches + 1 master
- **Worktrees:** 17 temporary worktrees (auto-cleaned)
- **Output:** Full React application with 34 chapters

### Phase Archives

All phases preserved in `.czarina/phases/`:
- `phase-1-v0.1.0/` - Story foundation (10 workers)
- `phase-2-v0.2.0/` - Mature themes (4 workers)
- `phase-3-v0.3.0/` - Epic fantasy (3 workers)

Each archive contains:
- `config.json` - Phase configuration snapshot
- `PHASE_SUMMARY.md` - Completion summary
- `workers/` - Worker identity files
- `logs/` - Activity logs
- `status/` - Worker status snapshots

### Git Repository State

```bash
# All work preserved on branches
git branch | grep cz1  # Phase 1 branches
git branch | grep cz2  # Phase 2 branches
git branch | grep cz3  # Phase 3 branches

# All work merged to master
git log --oneline master | head -20
```

---

## Key Workflow Patterns

### 1. Phase Initialization

```bash
# Create plan file (markdown)
cat > phase-N-plan.md <<EOF
# Project Name vX.Y.Z Implementation Plan

## Project
**Version:** X.Y.Z
**Phase:** N
**Objective:** Brief description

## Workers
### Worker 1: worker-id
- **Role:** code|integration
- **Agent:** claude
- **Dependencies:** []
- **Mission:** What this worker does
- **Tasks:** List of tasks
EOF

# Initialize from plan
czarina init phase-N-plan.md

# Verify configuration
czarina status
```

### 2. Phase Execution

```bash
# Launch all workers
czarina launch

# Attach to main session (Czar + workers)
tmux attach -t czarina-<project-slug>

# Monitor specific worker
# Ctrl+b <number>  (window 1 = worker 1, etc.)

# Detach without killing
# Ctrl+b d
```

### 3. Phase Completion

```bash
# Check status
czarina status

# Review worker branches
git branch | grep cz<N>

# Close phase (archives everything)
czarina phase close

# Verify cleanup
czarina status  # Should show "No active phase"
ls -la .czarina/phases/  # See archived phase
```

### 4. Phase Transition

```bash
# From end of phase N to start of phase N+1:
czarina phase close           # Archive phase N
czarina init phase-N+1-plan.md   # Initialize phase N+1
czarina launch                # Start new workers
```

---

## Lessons Learned

### What Worked Well

1. **Plan Files** - Markdown format made phase planning clear and version-controlled
2. **Phase Isolation** - Each phase had clean worker separation and dependencies
3. **Git Branches** - Worker branches preserved all work independently
4. **Phase Archives** - Complete history retention for future reference
5. **Worktree Cleanup** - Automatic cleanup prevented repository clutter

### Improvements Validated

These v0.8.0 improvements were tested and validated:

1. **Better Error Messages** - No Python tracebacks, clear guidance
2. **Phase Display** - Always knew current version/phase at a glance
3. **Auto-fix Features** - Branch naming auto-corrected by `czarina phase set`
4. **Robust Phase Close** - All 5 cleanup steps completed reliably
5. **Dependency Parsing** - Bracket notation `[worker1, worker2]` handled correctly

---

## Configuration Examples

### Minimal Phase Plan

```markdown
# My Project v1.0.0

## Project
**Version:** 1.0.0
**Phase:** 1

## Workers

### Worker 1: `setup`
- **Role:** code
- **Agent:** claude
- **Dependencies:** []
- **Mission:** Initialize project
```

### Phase 2 with Dependencies

```markdown
# My Project v2.0.0

## Project
**Version:** 2.0.0
**Phase:** 2

## Workers

### Worker 1: `feature-a`
- **Role:** code
- **Agent:** claude
- **Dependencies:** []
- **Mission:** Implement feature A

### Worker 2: `feature-b`
- **Role:** code
- **Agent:** claude
- **Dependencies:** [feature-a]
- **Mission:** Build on feature A

### Worker 3: `integration`
- **Role:** integration
- **Agent:** claude
- **Dependencies:** [feature-a, feature-b]
- **Mission:** Integrate both features
```

---

## Tips for Multi-Phase Projects

1. **Plan Ahead** - Write all phase plans before starting
2. **Keep Plans Simple** - 3-6 workers per phase is ideal
3. **Use Dependencies** - Define clear worker ordering
4. **Archive Regularly** - `czarina phase close` after each phase
5. **Monitor Progress** - Use tmux to watch workers in real-time
6. **Trust the Process** - Let workers complete autonomously
7. **Review Before Closing** - Check git branches before phase close

---

## Troubleshooting

### Phase Close Didn't Complete

If phase close stops early, manually complete cleanup:

```bash
# Remove workers directory
rm -rf .czarina/workers

# Remove worktrees
git worktree remove .czarina/worktrees/<worker-name> --force

# Remove config
rm .czarina/config.json

# Then proceed with next phase
czarina init next-phase-plan.md
```

(This issue was fixed in v0.8.0)

### Workers Not Launching

Check config has phase field:

```bash
jq '.workers[0].phase' .czarina/config.json
```

Should match project phase. If missing, add manually or re-init.

### Session Already Exists

```bash
# List sessions
tmux list-sessions

# Kill specific session
tmux kill-session -t czarina-<slug>

# Or use closeout
czarina closeout
```

---

## Conclusion

The HLDemo project demonstrates Czarina's ability to orchestrate complex multi-phase development workflows with:

- **17 autonomous workers** across 3 phases
- **Clean phase separation** with complete archival
- **Git workflow integration** via branches and worktrees
- **Real production output** (34-chapter interactive book app)

This workflow pattern scales to projects of any size and complexity.
