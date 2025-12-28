# Issue: Czar Not Actually Autonomous

**Priority:** Critical
**Severity:** Core Feature Not Working
**Tags:** czar, autonomy, coordination, automation
**Status:** Observed in Production
**Created:** 2025-12-28

## Problem Statement

**User Feedback:** "The Czars aren't automagically doing anything, I have to jog the workers."

Despite having autonomous Czar coordination features, the Czar is **passive** rather than **proactive**. The human user must manually:
- Check worker status
- Nudge stuck workers
- Determine when Phase 1 is complete
- Launch Phase 2 workers
- Coordinate dependency merges

**Expected:** Czar does all of this automatically
**Actual:** Human does it manually

## Current State

### What Exists (But Doesn't Work Well)

1. **Autonomous Czar Scripts**
   - `czarina-core/czar-autonomous-v2.sh`
   - `czarina-core/czar-dependency-tracking.sh`
   - Created in v0.6.1/v0.6.2
   - Not effectively integrated

2. **Daemon Mode**
   - `czarina daemon start`
   - Runs in background
   - Logs to `.czarina/logs/daemon.log`
   - But what does it actually DO?

3. **Czar Identity Files**
   - Describe coordination responsibilities
   - List monitoring tasks
   - But no automated execution

### What's Missing

1. **No Automatic Worker Monitoring**
   - Czar doesn't periodically check worker status
   - Doesn't detect when workers are stuck
   - Doesn't auto-nudge workers

2. **No Phase Progression**
   - Czar doesn't detect Phase 1 completion
   - Doesn't automatically launch Phase 2 workers
   - Human must manually trigger

3. **No Dependency Coordination**
   - Czar doesn't track which workers have completed
   - Doesn't notify dependent workers to start
   - Human must manually coordinate

4. **No Proactive Communication**
   - Czar doesn't send status updates
   - Doesn't ask workers for progress reports
   - Doesn't coordinate cross-worker issues

## Evidence

**From Production Usage:**

- Czarina-on-Czarina: Human manually checked workers, launched Phase 2
- Czarina-on-Hopper: Human coordinated integration worker merges
- Czarina-on-SARK: Human nudged stuck workers multiple times
- v0.7.0 (current): Human will need to manually manage 9 workers

**Expected Autonomous Behavior:**

```
[Czar - 10 min after launch]
→ Checking worker status...
→ rules-integration: In progress, 50% complete
→ memory-core: Stuck, no commits yet - NUDGING
→ memory-search: In progress, 30% complete
→ cli-commands: Complete! ✅
→ Phase 1: 1/4 complete, 2 in-progress, 1 stuck

[Czar - Nudges memory-core]
→ "Hey memory-core, you've been idle for 10 min. Your first action is to create memories.md schema. Need help?"

[Czar - 2 hours later, Phase 1 complete]
→ Phase 1: All 4 workers complete! ✅
→ Launching Phase 2 workers with dependencies met...
→ config-schema: Dependencies met (rules-integration ✅, memory-core ✅) - LAUNCHING
```

**Actual Behavior:**

```
[Czar - after launch]
→ [Sits idle in tmux window]

[Human - checks manually]
→ tmux attach, checks each worker window
→ Notices memory-core stuck
→ Switches to memory-core window
→ Types message to nudge worker

[Human - 2 hours later]
→ Manually verifies Phase 1 complete
→ Manually determines which Phase 2 workers to launch
→ Manually launches config-schema
```

## Root Causes

### 1. Daemon Not Actually Autonomous

Current daemon implementation (v0.6.2):
- Starts a tmux window
- Runs... what exactly?
- Logs exist but unclear what's being monitored
- No evidence of proactive actions

### 2. Czar Agent is Passive

The Czar is a Claude Code instance that:
- Has access to coordination tools
- Has identity describing responsibilities
- **But doesn't run in a loop**
- **Doesn't have scheduled monitoring**
- Waits for human to interact

### 3. No Coordination Event Loop

Missing core orchestration loop:

```bash
while orchestration_active; do
  check_worker_status
  detect_stuck_workers
  nudge_if_needed
  check_phase_completion
  launch_dependent_workers
  sleep 300  # 5 minutes
done
```

### 4. Claude Agent Limitation

Claude Code is **interactive**, not **cron-like**:
- Designed for human-in-loop collaboration
- Doesn't have built-in scheduling
- Can't run autonomous monitoring loops
- This is a fundamental mismatch

## Proposed Solutions

### Solution 1: Bash-Based Autonomous Czar (Quick Win)

Create `czarina-core/autonomous-czar-daemon.sh`:

```bash
#!/bin/bash
# Runs in daemon tmux window
# Monitors workers, triggers actions

while true; do
  # Check worker status
  for worker in $(list_workers); do
    status=$(get_worker_status $worker)

    # Detect stuck workers
    if is_stuck $worker $status; then
      nudge_worker $worker
    fi

    # Detect completions
    if is_complete $worker $status; then
      mark_complete $worker
      launch_dependent_workers $worker
    fi
  done

  # Check phase completion
  if phase_complete; then
    transition_to_next_phase
  fi

  # Log status
  log_coordination_status

  # Wait 5 minutes
  sleep 300
done
```

**Pros:**
- Pure bash, no AI needed
- Actually autonomous
- Can run 24/7
- Proven pattern

**Cons:**
- Not using AI for coordination decisions
- Heuristic-based (is_stuck logic)
- May miss nuanced situations

### Solution 2: Hybrid Approach (Best of Both)

Bash daemon + Claude Czar consultation:

```bash
# Daemon detects situations
if is_stuck $worker; then
  # Ask Claude Czar for advice
  advice=$(claude_czar "Worker $worker appears stuck. What should I do?")

  # Claude suggests action
  if [[ $advice == *"nudge"* ]]; then
    nudge_worker $worker "$advice"
  fi
fi
```

**Pros:**
- AI-powered decisions
- Autonomous execution
- Best of both worlds

**Cons:**
- More complex integration
- Requires Claude API calls
- Cost consideration

### Solution 3: Scheduled Claude Sessions (Middle Ground)

Cron-like Claude Code sessions:

```bash
# Every 15 minutes
while true; do
  # Launch temporary Claude session as Czar
  claude-code --cwd $REPO \
    --identity .czarina/workers/CZAR.md \
    --prompt "Check worker status and take coordinating actions" \
    --auto-exit

  sleep 900  # 15 min
done
```

**Pros:**
- Uses Claude for intelligence
- Automated scheduling
- Leverages existing Czar identity

**Cons:**
- Many short-lived sessions (wasteful)
- Context loss between sessions
- API cost

### Solution 4: Event-Driven Coordination (Long-term)

Workers emit events, Czar responds:

```bash
# Workers log events
worker_log "COMPLETED: Created symlink to agent-rules"

# Daemon watches logs, triggers Czar
on_event "COMPLETED" $worker; do
  mark_complete $worker
  check_dependencies
  launch_ready_workers
done
```

**Pros:**
- Reactive, not polling
- Efficient (only acts when needed)
- Scalable

**Cons:**
- Requires worker instrumentation
- More complex architecture
- Bigger refactor

## Recommended Approach

**Immediate (v0.7.1):**
- **Solution 1:** Implement bash-based autonomous Czar daemon
- Add to existing daemon infrastructure
- Focus on Phase transition automation
- Heuristic-based worker monitoring

**Short-term (v0.8.0):**
- **Solution 2:** Add Claude Czar consultation for complex decisions
- Hybrid: Daemon detects, Claude decides
- Worker nudging with AI-generated messages

**Long-term (v0.9.0):**
- **Solution 4:** Event-driven coordination architecture
- Workers emit structured events
- Czar responds to events automatically
- Full autonomy

## Implementation Plan (v0.7.1)

### 1. Autonomous Czar Daemon Script

```bash
# czarina-core/autonomous-czar-daemon.sh

# Monitor workers every 5 minutes
# Detect phase completion
# Launch Phase 2 when Phase 1 done
# Log all actions
```

### 2. Integration with Launch

```bash
# czarina launch
# After launching workers...
# Launch autonomous Czar daemon in mgmt session
```

### 3. Phase Transition Logic

```bash
check_phase_complete() {
  phase_workers=$(get_phase_workers $current_phase)

  for worker in $phase_workers; do
    if ! is_complete $worker; then
      return 1  # Phase not complete
    fi
  done

  return 0  # All workers complete
}

transition_phase() {
  log "Phase $current_phase complete! Transitioning..."
  current_phase=$((current_phase + 1))
  launch_phase_workers $current_phase
}
```

### 4. Worker Status Detection

```bash
is_stuck() {
  worker=$1

  # Check last commit time
  last_commit=$(git log -1 --format=%ct $worker_branch)
  now=$(date +%s)
  idle_time=$((now - last_commit))

  # If idle > 30 min, consider stuck
  if [ $idle_time -gt 1800 ]; then
    return 0  # Stuck
  fi

  return 1  # Not stuck
}
```

## Success Metrics

**User Experience:**
- User launches orchestration
- Czar handles everything automatically
- User only intervenes for critical decisions
- "Set it and forget it" experience

**Quantitative:**
- 0 manual worker nudges needed
- Automatic Phase 1 → Phase 2 transition
- 100% dependency coordination automated
- Czar actions logged every 5 minutes

**User Feedback:**
- "Czar actually coordinates now!"
- "I just check the dashboard occasionally"
- "Workers progressed automatically overnight"

## Related Issues

- Issue #1: Worker Onboarding Confusion (Czar should nudge)
- Enhancement: Event-driven Architecture
- Enhancement: Czar Intelligence (AI decisions)

---

**Status:** Critical - Blocks autonomous orchestration
**Assigned:** Should be high priority for v0.7.1
**Blocking:** All future orchestrations suffer without this
