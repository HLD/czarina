# Issue: Workers Can't Find Their Spot

**Priority:** High
**Severity:** Critical UX Issue
**Tags:** ux, worker-experience, onboarding
**Status:** Observed in Production
**Created:** 2025-12-28

## Problem Statement

**Observation:** "1 of each of those groups just couldn't find it's spot"

Across multiple Czarina orchestrations (Czarina-on-Czarina, Czarina-on-Hopper, Czarina-on-SARK), consistently **one worker per orchestration gets stuck/confused** and doesn't know what to do or where to start.

## Symptoms

- Worker launched successfully (tmux window, agent running)
- Worker reads their identity file
- Worker doesn't take initial action
- Human has to "jog" the worker to get started
- Happens consistently across different projects

## Root Cause Analysis

**Hypothesis 1: Unclear First Action**
- Worker identity files describe mission/objectives
- But don't explicitly say "YOUR FIRST ACTION IS..."
- Worker analyzes, thinks, but doesn't act

**Hypothesis 2: Analysis Paralysis**
- Too many objectives listed
- Worker tries to understand everything before acting
- Gets stuck in planning mode

**Hypothesis 3: Context Overload**
- Worker reads codebase, identity, references
- Too much information, unclear priority
- Doesn't know where to start

## Evidence

From v0.7.0 launch (current):
- 9 workers launched
- User reports needing to "jog" workers
- Pattern matches previous orchestrations

From production usage:
- Czarina-on-Czarina: 1 stuck worker
- Czarina-on-Hopper: 1 stuck worker
- Czarina-on-SARK: 1 stuck worker

**Consistent pattern:** Always ~1 worker per orchestration

## Proposed Solutions

### Solution 1: Explicit First Action (Quick Win)

Add to worker identity template:

```markdown
## 🚀 YOUR FIRST ACTION

**Step 1:** [Specific first action]
**Example:** Create symlink: `ln -s ~/Source/agent-rules/agent-rules ./czarina-core/agent-rules`

After completing this, proceed to Objective 2.
```

**Pros:** Easy to implement, clear guidance
**Cons:** Still requires good first action definition

### Solution 2: Onboarding Checklist

Add interactive checklist at start of identity:

```markdown
## Getting Started Checklist

Before you begin, confirm:
- [ ] I've read my mission and objectives
- [ ] I understand my first deliverable
- [ ] I know which files to modify/create
- [ ] I have no blocking dependencies

**Your first task:** [Specific action]
```

**Pros:** Forces worker to confirm understanding
**Cons:** Adds friction, may not solve core issue

### Solution 3: Auto-Start Action Hook

Czarina launcher could prompt worker with first action:

```bash
# After launching worker
echo "=== YOUR FIRST ACTION ==="
echo "Create symlink to agent-rules library"
echo "Command: ln -s ~/Source/agent-rules/agent-rules ./czarina-core/agent-rules"
echo "========================="
```

**Pros:** Impossible to miss, very explicit
**Cons:** Hardcoded per worker, less flexible

### Solution 4: Czar Kickstart (Best Long-term)

Czar automatically sends initial nudge to each worker after launch:

```
Czar → Worker 1: "Your first action is to create the symlink to agent-rules. Go!"
Czar → Worker 2: "Start by designing the memories.md schema. Go!"
```

**Pros:** Autonomous, Czar-coordinated, scales
**Cons:** Requires Czar enhancement (#2)

## Recommended Approach

**Immediate (v0.7.0):**
- Solution 1: Add explicit "YOUR FIRST ACTION" section to all worker identities
- Update worker identity template
- Test with current v0.7.0 workers

**Short-term (v0.7.1):**
- Solution 4: Czar sends kickstart message after launch
- Integrates with autonomous Czar enhancement

**Long-term (v0.8.0):**
- Worker identity schema validation
- Required fields: first_action, deliverable, success_criteria
- Automated quality checks

## Success Metrics

- 0 workers stuck per orchestration (down from 1)
- Workers take first action within 5 minutes of launch
- No human intervention needed to start workers
- User feedback: "Workers knew exactly what to do"

## Related Issues

- Issue #2: Czar Not Autonomous (blocking dependencies)
- Enhancement: Worker Identity Schema
- Enhancement: Czar Kickstart Messages

---

**Status:** Needs implementation
**Assigned:** TBD
**Priority:** High (affects all orchestrations)
