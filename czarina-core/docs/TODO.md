# Czarina - TODO List

This document tracks improvements and fixes needed for the Czarina orchestration framework.

## High Priority

### Fix Tmux Window Numbering for Human Readability
**Issue:** Currently, worker windows are numbered starting from 0, which is confusing for humans:
- Window 0: engineer1
- Window 1: engineer2
- Window 2: engineer3
- etc.

**Expected Behavior:** Engineers should map to their human-intuitive numbers:
- Window 0: monitoring/dashboard/control panel
- Window 1: engineer1
- Window 2: engineer2
- Window 3: engineer3
- etc.

**Impact:** Low technical impact, high human usability impact. Users expect Ctrl+b then "1" to go to Engineer 1, not Engineer 2.

**Files to Update:**
- `projects/sark-v2-orchestration/launch-session.sh` - Main launch script
- `czarina-core/launch-claude-workers.sh` - If still in use
- Any other launch scripts that create tmux windows

**Solution:**
1. Create window 0 as a "control" or "monitor" window first
2. Then create engineer1 on window 1, engineer2 on window 2, etc.
3. Alternative: Create monitoring/dashboard window, then use `tmux move-window` to reorder

**Example Fix:**
```bash
# Create session with monitoring window first (window 0)
tmux new-session -d -s "$SESSION_NAME" -n "monitor" -c "$SARK_DIR"

# Set up monitoring/control panel on window 0
tmux send-keys -t "$SESSION_NAME:monitor" "# Control Panel / Monitoring" C-m

# Now create engineer windows starting at 1
tmux new-window -t "$SESSION_NAME:1" -n "engineer1" -c "$SARK_DIR"
# engineer1 setup...

tmux new-window -t "$SESSION_NAME:2" -n "engineer2" -c "$SARK_DIR"
# engineer2 setup...
# etc.
```

**Assigned To:** _Unassigned_
**Priority:** Medium
**Effort:** 30 minutes

---

## Medium Priority

_(Add future items here)_

---

## Low Priority

_(Add future items here)_

---

## Completed

_(Move completed items here with completion date)_

---

## Notes for Contributors

- This TODO list is for framework improvements, not project-specific tasks
- Please update the file when you complete items (move to "Completed" section)
- Add new items in the appropriate priority section
- Include enough context for someone unfamiliar with the issue to understand and fix it
