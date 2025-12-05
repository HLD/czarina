# Feature Request: Improved Session Layout and Auto-Launch

**Date:** 2025-12-05
**Status:** 📋 Planned
**Priority:** High
**Component:** launch-project.sh

## User Expectations

As a user launching czarina, I expect:

1. **Auto-start everything** - Daemon and dashboard should start automatically
2. **Simple window numbering** - Workers as "1, 2, 3..." not complex IDs
3. **Logical organization** - Czar in window 0, workers in predictable locations
4. **Management session** - Overflow workers + daemon + dashboard together

## Proposed Design

### Session 1 (Main): `czarina-{project}`
```
Window 0: Czar (orchestrator/coordinator)
Window 1: Worker 1
Window 2: Worker 2
Window 3: Worker 3
Window 4: Worker 4
Window 5: Worker 5
Window 6: Worker 6
Window 7: Worker 7
Window 8: Worker 8
Window 9: Worker 9
```

### Session 2 (Management): `czarina-{project}-mgmt`
```
Window 0: Worker 10
Window 1: Worker 11
Window 2: Worker 12
...
Window N-10: Worker N
Window N-9: Daemon (auto-started)
Window N-8: Dashboard (auto-started, live updating)
```

## Window Naming

**Current:** Complex descriptive IDs
```
backend-attention-service
sage-loop-integrator
backend-tier7-integration
```

**Proposed:** Simple numeric labels
```
worker1  (or "Engineer 1" if engineer role)
worker2
worker3
```

**Rationale:**
- Easier to remember and switch to
- Branch names can be descriptive (they drift anyway)
- Window names stay simple and predictable
- Ctrl+b 1, Ctrl+b 2, etc just works

## Auto-Launch Features

### 1. Daemon Auto-Start
```bash
# After creating all worker windows
tmux new-window -t "${MGMT_SESSION}" -n "daemon"
tmux send-keys -t "${MGMT_SESSION}:daemon" "cd ${PROJECT_ROOT}" C-m
tmux send-keys -t "${MGMT_SESSION}:daemon" "${ORCHESTRATOR_DIR}/czarina-core/daemon/start-daemon.sh ${CZARINA_DIR}" C-m
```

### 2. Dashboard Auto-Start
```bash
# After daemon
tmux new-window -t "${MGMT_SESSION}" -n "dashboard"
tmux send-keys -t "${MGMT_SESSION}:dashboard" "cd ${PROJECT_ROOT}" C-m
tmux send-keys -t "${MGMT_SESSION}:dashboard" "python3 ${ORCHESTRATOR_DIR}/czarina-core/dashboard-v2.py" C-m
```

### 3. Czar Auto-Load
Window 0 should automatically display the Czar prompt:
```bash
tmux send-keys -t "${MAIN_SESSION}:0" "cat ${CZARINA_DIR}/workers/CZAR.md" C-m
```

## Implementation Plan

### Phase 1: Simplify Window Names
- [ ] Change tmux window names to worker1, worker2, etc
- [ ] Keep descriptive info in the window content
- [ ] Update dashboard to handle new naming

### Phase 2: Auto-Launch Daemon
- [ ] Create daemon window in mgmt session
- [ ] Auto-start daemon script
- [ ] Remove manual `czarina daemon start` requirement

### Phase 3: Auto-Launch Dashboard
- [ ] Create dashboard window in mgmt session
- [ ] Auto-start dashboard-v2.py
- [ ] Make it run automatically (no user interaction needed)

### Phase 4: Czar Window Setup
- [ ] Ensure window 0 is "czar" not "orchestrator"
- [ ] Auto-display CZAR.md prompt
- [ ] Make it clear this is the coordination window

## Benefits

✅ **Zero Manual Steps** - launch and go, everything auto-starts
✅ **Predictable Layout** - Always know where workers are
✅ **Easy Navigation** - Ctrl+b 1, Ctrl+b 2, etc
✅ **Single Command** - `czarina launch` does everything
✅ **Better UX** - Matches user mental model

## Testing Checklist

- [ ] 11 workers: Session 1 (Czar + 9), Session 2 (2 + daemon + dashboard)
- [ ] 5 workers: Single session (Czar + 5 + daemon + dashboard)
- [ ] 20 workers: Session 1 (Czar + 9), Session 2 (11 + daemon + dashboard)
- [ ] Daemon auto-starts and runs
- [ ] Dashboard auto-starts and displays
- [ ] Czar prompt visible in window 0
- [ ] Simple window switching works

## Current Blockers

None - just needs implementation time

## Related Files

- `czarina-core/launch-project.sh` - Main launch logic
- `czarina-core/dashboard-v2.py` - Dashboard script
- `czarina-core/daemon/start-daemon.sh` - Daemon startup
- `.czarina/workers/CZAR.md` - Czar prompt

## Notes

- Current implementation creates sessions but doesn't auto-launch daemon/dashboard
- Worker naming is descriptive but unwieldy
- Czar window exists but not prominently featured
- This is purely UX improvement, doesn't change core functionality
