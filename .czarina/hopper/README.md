# Project Hopper

This is the **project-level hopper** - a backlog of enhancement ideas, feature requests, and improvements for czarina.

## What is the Hopper?

The hopper is a two-level work queue system:

1. **Project Hopper** (`.czarina/hopper/`) - Long-term backlog
   - Enhancement ideas discovered during dogfooding
   - Feature requests
   - Technical debt items
   - Nice-to-have improvements

2. **Phase Hopper** (`.czarina-vX.Y.Z/phase-hopper/`) - Current phase scope
   - Items pulled from project hopper for current work
   - Active tasks being worked on
   - Completed items

## How to Use

### Adding Items

Create a markdown file describing the enhancement:

```bash
# Create new enhancement file
vim .czarina/hopper/enhancement-your-idea.md
```

Use this template structure:
```markdown
# Enhancement: Your Idea Title

**Priority:** High/Medium/Low
**Complexity:** High/Medium/Low
**Tags:** feature, bugfix, tooling, etc.
**Status:** Backlog/In Progress/Done

## Summary
Brief description...

## Proposal
What should be implemented...

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
```

### Hopper Commands

```bash
# List all items in project hopper
czarina hopper list

# Pull item from project hopper to phase hopper
czarina hopper pull enhancement-your-idea.md

# Defer item from phase back to project hopper
czarina hopper defer enhancement-your-idea.md

# Assign hopper item to worker
czarina hopper assign enhancement-your-idea.md worker-id
```

### Priority Queue

Items are prioritized by:
1. **Priority** field (High > Medium > Low)
2. **Complexity** field (Low > Medium > High for quick wins)
3. **Dependencies** (blocked items pushed down)

## Czar Monitoring

The autonomous Czar can monitor the hopper and:
- Suggest items for idle workers
- Auto-pull items based on priority
- Track progress across phase boundaries

## Examples

See `examples/` directory for sample enhancement files.

## Workflow

```
Project Hopper (long-term)
     ↓ (pull for phase)
Phase Hopper (current scope)
     ↓ (assign to worker)
Worker (implements)
     ↓ (complete & merge)
Done (archived)
```

---

**Created:** 2025-12-26 during czarina v0.6.0 development
