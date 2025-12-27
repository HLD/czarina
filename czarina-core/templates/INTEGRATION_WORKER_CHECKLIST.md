# Integration Worker Checklist

**CRITICAL:** As an integration worker with `role: "integration"`, you are responsible for merging dependency worker branches before finalizing your work. This checklist ensures proper coordination.

## ⚠️ Pre-Push Requirements

Before pushing to GitHub, you **MUST** complete this checklist:

### 1. Wait for Dependencies to Complete

- [ ] All workers listed in `dependencies` have completed their work
- [ ] All workers listed in `merges` have pushed their branches
- [ ] Reviewed completion signals from dependency workers

**How to check:**
```bash
# Check if dependency branches exist and have recent commits
git fetch origin
git branch -a | grep <dependency-worker-branch>
git log origin/<dependency-branch> --oneline -10
```

### 2. Review Dependency Worker Deliverables

For each dependency worker:

- [ ] Read their completion summary/report
- [ ] Review their commit history
- [ ] Understand what they delivered
- [ ] Note any integration concerns

**Recommended:**
```bash
# Switch to dependency worker branch and review
git checkout <dependency-branch>
cat INTEGRATION_SUMMARY.md  # Or equivalent completion doc
git log --oneline -20
git diff main...<dependency-branch>  # See all changes
```

### 3. Merge Dependency Branches

⚠️ **CRITICAL STEP** - The pre-push hook will block if you skip this!

For each worker in your `merges` list:

- [ ] Fetch latest changes: `git fetch origin`
- [ ] Switch to your integration branch: `git checkout <your-branch>`
- [ ] Merge dependency branch: `git merge origin/<dependency-branch>`
- [ ] Resolve any conflicts
- [ ] Test that merged code works
- [ ] Commit the merge

**Example workflow:**
```bash
# From your integration branch
git fetch origin

# Merge first dependency
git merge origin/feat/worker1
# Resolve conflicts if any
git add .
git commit -m "chore: Merge worker1 deliverables"

# Merge second dependency
git merge origin/feat/worker2
# Resolve conflicts if any
git add .
git commit -m "chore: Merge worker2 deliverables"

# Verify all merges
git log --oneline --graph -20
```

### 4. Integration Testing

After merging all dependencies:

- [ ] Run project tests
- [ ] Verify no conflicts in merged code
- [ ] Test key functionality
- [ ] Update integration documentation

### 5. Document Integration

- [ ] Create/update INTEGRATION_SUMMARY.md
- [ ] List what was merged from each worker
- [ ] Note any conflicts and how they were resolved
- [ ] Document integration decisions

### 6. Final Verification

Before pushing:

- [ ] All dependency branches merged (verified by pre-push hook)
- [ ] No merge conflicts remaining
- [ ] Tests pass
- [ ] Integration summary complete
- [ ] Ready for Czar review

## Pre-Push Hook

The pre-push hook will automatically verify that all branches listed in your `merges` config are actually merged. If not, it will **block the push** with a message like:

```
❌ PUSH BLOCKED: Missing dependency merges

As an integration worker, you must merge dependency branches before pushing.

Required actions:
   1. Merge worker1 branch:
      git merge feat/worker1
   2. Merge worker2 branch:
      git merge feat/worker2
   3. Resolve any conflicts
   4. Try pushing again
```

## Common Mistakes to Avoid

❌ **Don't push before dependencies finish** - This creates incomplete integration
❌ **Don't skip merging dependency branches** - Pre-push hook will block this
❌ **Don't merge without reviewing** - Understand what you're integrating
❌ **Don't ignore conflicts** - Resolve them properly
❌ **Don't skip testing** - Merged code might break

## Integration Worker Config Example

Your config should look like this:

```json
{
  "id": "release",
  "role": "integration",
  "branch": "release/v0.6.1",
  "dependencies": ["integration", "testing"],
  "merges": ["integration", "testing"],
  "description": "Integration worker - merges all deliverables"
}
```

**Key fields:**
- `role: "integration"` - Marks this as integration worker
- `dependencies` - Workers you depend on completing
- `merges` - Branches you MUST merge before pushing (enforced by hook)

## Success Criteria

Integration complete when:

✅ All dependency workers have finished and pushed
✅ All dependency branches merged into your branch
✅ No merge conflicts
✅ Tests pass
✅ Integration summary documented
✅ Pre-push hook validation passes
✅ Czar has reviewed and approved

## Questions?

If unclear about:
- When dependencies are complete → Ask Czar
- How to resolve conflicts → Coordinate with dependency workers
- What to include in integration → Review dependency worker deliverables

**The Czar is responsible for coordinating handoffs. Signal when you're ready for dependency branches.**
