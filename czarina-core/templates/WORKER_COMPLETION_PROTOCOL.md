# Worker Completion Protocol

This document defines the standard protocol for workers to follow when completing their assigned tasks in a czarina orchestration.

## Overview

Proper completion signaling ensures:
- Czar knows when workers are done
- Dependent workers know when to start
- Integration workers know what to merge
- Clear handoff of deliverables

## Completion Checklist

### 1. Complete All Assigned Tasks

Before signaling completion:

- [ ] All tasks from worker instructions completed
- [ ] All deliverables created
- [ ] All success criteria met
- [ ] Code tested and working
- [ ] No TODO comments or incomplete work

### 2. Document Your Work

Create a completion summary:

- [ ] Create `COMPLETION_SUMMARY.md` or similar in your worktree
- [ ] List what was delivered
- [ ] Document any deviations from plan
- [ ] Note integration concerns or dependencies
- [ ] Include metrics (LOC, files changed, etc.)

**Template:**
```markdown
# [Worker ID] Completion Summary

## Deliverables

- [x] Feature 1 implemented
- [x] Tests added
- [x] Documentation updated

## Changes

- Modified: src/file1.py, src/file2.py
- Added: tests/test_feature.py
- Lines: +250, -50

## Integration Notes

- Depends on: worker-2 completing their API changes
- Breaking changes: None
- Migration needed: No

## Known Issues

- None

## Ready for Integration

This work is complete and ready to be merged by the integration worker.
```

### 3. Clean Up Git State

Ensure clean git history:

- [ ] All changes committed
- [ ] No uncommitted files
- [ ] No merge conflicts
- [ ] Commit messages are clear
- [ ] Branch is up to date with main (rebase if needed)

**Commands:**
```bash
# Check for uncommitted changes
git status

# Commit any remaining work
git add .
git commit -m "chore: Final cleanup for worker completion"

# Rebase on main (optional but recommended)
git fetch origin
git rebase origin/main

# Verify clean state
git status
```

### 4. Push to Remote

**CRITICAL:** Only push when actually complete!

- [ ] All work completed and tested
- [ ] Completion summary created
- [ ] Git state clean
- [ ] Dependencies satisfied (if any)

**For non-integration workers:**
```bash
# Push your branch
git push origin <your-branch>

# If rebased, may need force push
git push --force-with-lease origin <your-branch>
```

**For integration workers:**
- See [INTEGRATION_WORKER_CHECKLIST.md](./INTEGRATION_WORKER_CHECKLIST.md)
- Must merge dependency branches BEFORE pushing
- Pre-push hook will enforce this

### 5. Signal Completion to Czar

After pushing, notify the Czar:

**In tmux:**
1. Switch to Czar window: `Ctrl+b 0`
2. Leave a message or signal completion

**Via comment in worktree:**
Create a signal file:
```bash
echo "WORKER COMPLETE: $(date)" > .WORKER_COMPLETE
```

**Via GitHub (if using github mode):**
- Comment on tracking issue
- Update project board
- Tag Czar in comment

### 6. Wait for Coordination

Do not start new work without Czar approval:

- [ ] Wait for Czar acknowledgment
- [ ] If dependent workers exist, wait for their review
- [ ] If this is final work, wait for integration/release

## Common Scenarios

### Scenario 1: Worker Completes, No Dependencies

**Example:** Worker 1 has no dependencies

1. Complete all tasks
2. Create completion summary
3. Push branch to remote
4. Signal Czar
5. Done - wait for integration

### Scenario 2: Worker Completes, Has Dependents

**Example:** Worker 1 finishes, Worker 2 depends on them

1. Complete all tasks
2. Create **detailed** completion summary (Worker 2 needs this!)
3. Push branch to remote
4. Signal Czar: "Worker 1 complete, ready for Worker 2"
5. Czar notifies Worker 2
6. Worker 2 reviews completion summary
7. Worker 2 begins work

### Scenario 3: Integration Worker Completes

**Example:** Release worker merges all dependency branches

1. Wait for ALL dependency workers to push
2. Review each dependency's completion summary
3. Merge each dependency branch (enforced by pre-push hook)
4. Resolve conflicts
5. Test integrated code
6. Create integration summary
7. Push omnibus branch
8. Signal Czar for final review

### Scenario 4: Worker Blocked by Dependency

**Example:** Worker 2 can't finish because Worker 1 isn't done

1. Complete as much work as possible
2. Document the blocker
3. Create partial completion summary
4. Push work-in-progress branch
5. Signal Czar: "Worker 2 blocked by Worker 1 - waiting"
6. Czar coordinates with Worker 1
7. When unblocked, complete remaining work
8. Push final version
9. Signal final completion

## Validation Commands

### Check Your Dependencies
```bash
# From project root
czarina deps check <your-worker-id>
```

This shows:
- Which dependencies are complete
- Which branches are available
- If you're ready to proceed

### Validate You Can Proceed
```bash
# From project root
czarina deps validate <your-worker-id>
```

This validates:
- All dependencies have pushed
- You're clear to complete your work

### Check Integration Requirements
```bash
# For integration workers only
czarina deps check <your-worker-id>
```

This shows:
- Which branches you need to merge
- Which are already merged
- What's missing

## Anti-Patterns (Don't Do This!)

❌ **Pushing before work is complete** - Causes coordination failures
❌ **Not creating completion summary** - Dependents don't know what you delivered
❌ **Pushing without testing** - Breaks integration
❌ **Integration workers pushing without merging** - Pre-push hook blocks this, but don't try!
❌ **Not signaling Czar** - Coordination breaks down
❌ **Starting new work without approval** - Scope creep

## Pre-Push Hook

The pre-push hook automatically validates:

**For all workers:**
- Branch exists in config
- Worker is properly configured

**For integration workers:**
- All branches in `merges` are actually merged
- Blocks push if dependencies not merged
- Shows clear error with remediation steps

If the pre-push hook blocks you, it means you're missing required steps. **Do not override the hook** - fix the underlying issue.

## Summary

The completion protocol ensures:

1. ✅ Work is actually complete before signaling
2. ✅ Dependents have clear deliverables to work with
3. ✅ Integration workers can safely merge
4. ✅ Czar can coordinate handoffs
5. ✅ No premature pushes to GitHub

Follow this protocol every time, and orchestration will run smoothly!

## Quick Reference

**Standard completion:**
1. Finish all tasks
2. Create completion summary
3. Clean git state
4. `czarina deps check <worker-id>` ← Validate dependencies
5. `git push origin <branch>`
6. Signal Czar
7. Wait for acknowledgment

**Integration worker completion:**
1. Wait for ALL dependencies to push
2. Review completion summaries
3. `czarina deps check <worker-id>` ← Shows merge status
4. `git merge <dependency-branch>` (for each dependency)
5. Resolve conflicts, test
6. Create integration summary
7. `git push origin <omnibus-branch>` ← Pre-push hook validates merges
8. Signal Czar
9. Wait for final review
