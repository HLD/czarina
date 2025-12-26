# Autonomous Czar Loop

## Overview

The Autonomous Czar is a continuous monitoring and decision-making system that transforms the Czar from a passive coordinator to an active autonomous agent. It implements:

- **A3: Autonomous Czar Loop** - Continuous monitoring and decision-making
- **A4: Worker Health Monitoring** - Detect stuck, idle, and crashed workers
- **Structured Logging** - All decisions logged to both human-readable and machine-readable formats

## Architecture

### Components

1. **`czar-autonomous-v2.sh`** - Main autonomous loop script
2. **`logging.sh`** - Structured logging system (dependency)
3. **`update-worker-status.sh`** - Worker status tracking
4. **`config.json`** - Worker configuration and dependencies

### Monitoring Cycle

```
┌─────────────────────────────────────┐
│   Autonomous Czar Loop (30s)        │
│                                     │
│  1. Update worker-status.json       │
│  2. Detect worker issues:           │
│     • Crashed (session dead)        │
│     • Stuck (no activity 30+ min)   │
│     • Idle (completed/waiting)      │
│  3. Make decisions:                 │
│     • Alert on crashes              │
│     • Prompt stuck workers          │
│     • Check dependencies            │
│     • (Task 2: Assign new work)     │
│  4. Log all decisions               │
│  5. Sleep 30s, repeat               │
└─────────────────────────────────────┘
```

## Usage

### Starting the Autonomous Czar

```bash
# From the czarina project directory
cd /path/to/czarina
./czarina-core/czar-autonomous-v2.sh
```

### Environment Setup

The script requires:
- `config.json` in `.czarina/` or `.czarina-vX.Y.Z/` directory
- Logging system initialized (`logging.sh` sourced)
- Worker status tracking (`update-worker-status.sh` available)

Optional environment variables:
- `CZARINA_DIR` - Override czarina directory location (default: auto-detected)

### Output

The autonomous czar logs to multiple locations:

1. **`status/autonomous-decisions.log`** - Human-readable decision log
   ```
   [2025-12-26 10:00:00] [INFO] CZAR_START: Autonomous Czar started (interval=30s)
   [2025-12-26 10:01:00] [DETECT] STUCK_WORKER: Detected stuck worker: foundation (worker=foundation)
   [2025-12-26 10:01:00] [ACTION] PROMPT_STUCK_WORKER: Prompting stuck worker: foundation
   ```

2. **`logs/orchestration.log`** - Daemon/czar events with emojis
   ```
   [10:00:00] ℹ️  CZAR_START: Autonomous Czar started (interval=30s)
   [10:01:00] 👀 STUCK_WORKER: Detected stuck worker: foundation (worker=foundation)
   [10:01:00] ⚡ PROMPT_STUCK_WORKER: Prompting stuck worker: foundation
   ```

3. **`logs/events.jsonl`** - Machine-readable event stream
   ```json
   {"ts":"2025-12-26T10:00:00-05:00","source":"czar","event":"CZAR_START","metadata":{"interval":"30s"}}
   {"ts":"2025-12-26T10:01:00-05:00","source":"czar","event":"STUCK_WORKER","metadata":{"worker":"foundation"}}
   ```

## Worker Health States

### Status (from `worker-status.json`)

| Status    | Description                          | Czar Action                    |
|-----------|--------------------------------------|--------------------------------|
| `pending` | Not started yet                      | None                           |
| `working` | Active within last hour              | None                           |
| `idle`    | Completed or waiting for work        | (Task 2: Assign from hopper)   |

### Health (from `worker-status.json`)

| Health    | Description                          | Czar Action                    |
|-----------|--------------------------------------|--------------------------------|
| `healthy` | Active within last hour              | None                           |
| `slow`    | Active within last 2 hours           | Monitor                        |
| `stuck`   | No activity for 30+ minutes          | Prompt worker (with cooldown)  |
| `crashed` | Session not active                   | Alert immediately              |

## Decision Logic

### 1. Crashed Workers (Highest Priority)

```bash
# Detection
session_active == false AND status != "pending"

# Action
• Log alert with severity=high
• Notify human operator (requires attention)
```

### 2. Stuck Workers

```bash
# Detection
health == "stuck" AND session_active == true

# Actions
1. Check if blocked by dependencies
   • If yes: Log WORKER_BLOCKED, monitor dependencies
   • If no: Continue to step 2

2. Check prompt cooldown (1 hour)
   • If cooldown active: Skip
   • If cooldown expired: Prompt worker via tmux

# Prompt Message
⚠️  AUTONOMOUS CZAR: You appear to be stuck (no activity detected)
Please report your status:
  - Are you blocked by dependencies?
  - Do you need clarification on requirements?
  - Are you waiting for external resources?
  - Tag @czar if you need human intervention
```

### 3. Idle Workers

```bash
# Detection
status == "idle"

# Actions (Current)
• Log IDLE_WORKER detection
• Monitor for state changes

# Actions (Task 2 - Future)
• Check hopper for available tasks
• Assess task compatibility
• Auto-assign or suggest to human
```

### 4. Dependency Tracking (Basic)

```bash
# For each worker with dependencies
dependencies = config.workers[].dependencies

# Check dependency status
for dep in dependencies:
    dep_status = worker-status.json[dep].status

    if dep_status in ["pending", "unknown"]:
        • Log DEPENDENCY_NOT_READY
        • Mark worker as potentially blocked
```

## Event Types

### Czar Events

| Event Type              | Description                              | Level  |
|-------------------------|------------------------------------------|--------|
| `CZAR_START`            | Autonomous czar started                  | INFO   |
| `CZAR_STOP`             | Autonomous czar stopped                  | INFO   |
| `STATUS_SUMMARY`        | Periodic status summary (every 5 min)    | INFO   |
| `STUCK_WORKER`          | Detected stuck worker                    | DETECT |
| `IDLE_WORKER`           | Detected idle worker                     | DETECT |
| `WORKER_CRASHED`        | Worker session crashed                   | ALERT  |
| `PROMPT_STUCK_WORKER`   | Sent prompt to stuck worker              | ACTION |
| `DEPENDENCY_NOT_READY`  | Worker dependency not ready              | DETECT |
| `WORKER_BLOCKED`        | Worker blocked by dependencies           | INFO   |
| `COOLDOWN_ACTIVE`       | Stuck worker in prompt cooldown          | INFO   |
| `SESSION_NOT_FOUND`     | Worker tmux session not found            | ERROR  |
| `NO_WORKERS`            | No workers in configuration              | ERROR  |

## Configuration

### Check Interval

Default: 30 seconds

```bash
# In czar-autonomous-v2.sh
CHECK_INTERVAL=30  # seconds between checks
```

Rationale: Frequent enough to catch issues quickly, infrequent enough to avoid spam.

### Stuck Worker Prompt Cooldown

Default: 3600 seconds (1 hour)

```bash
STUCK_PROMPT_COOLDOWN=3600  # seconds before re-prompting
```

Rationale: Avoid annoying workers with repeated prompts if they're genuinely working on something complex.

### Status Summary Interval

Default: Every 10 iterations (5 minutes)

```bash
STATUS_SUMMARY_INTERVAL=10  # iterations between summaries
```

Rationale: Provides regular heartbeat without cluttering logs.

## Integration Points

### With Logging System

```bash
# Source logging functions
source "${SCRIPT_DIR}/logging.sh"

# Initialize
czarina_log_init

# Log decision
czarina_log_event "czar" "EVENT_TYPE" key=value
czarina_log_daemon "🤖" "EVENT_TYPE" "Description" key=value
```

### With Worker Status

```bash
# Update status
./update-worker-status.sh

# Read status
jq -r '.workers["worker-id"].status' worker-status.json
jq -r '.workers["worker-id"].health' worker-status.json
```

### With Dependencies (config.json)

```bash
# Get dependencies
jq -r '.workers[] | select(.id == "worker-id") | .dependencies[]' config.json

# Check if dependency ready
dep_status=$(jq -r '.workers["dep-id"].status' worker-status.json)
```

### With Tmux Sessions

```bash
# Get session name from config
project_slug=$(jq -r '.project.slug' config.json)
session="czarina-${project_slug}:${worker_id}"

# Send prompt
tmux send-keys -t "$session" "message" C-m
```

## Future Enhancements (Task 2 & 3)

### Task 2: Hopper Monitoring

- Monitor project hopper for new items
- Assess tasks (auto-include, auto-defer, ask-human)
- Monitor phase hopper for idle worker assignments
- Auto-assign compatible tasks to idle workers

### Task 3: Advanced Dependency Tracking

- Track task dependencies (not just worker dependencies)
- Detect circular dependencies
- Suggest integration order
- Auto-merge when dependencies complete

## Testing

### Manual Testing

```bash
# 1. Start autonomous czar
./czarina-core/czar-autonomous-v2.sh

# 2. In another terminal, watch logs
tail -f .czarina/status/autonomous-decisions.log
tail -f .czarina/logs/orchestration.log

# 3. Simulate scenarios:
# - Leave a worker idle (no commits for 10+ minutes)
# - Stop a worker's tmux session
# - Check dependency blocking
```

### Validating Decisions

```bash
# View all decisions
cat .czarina/status/autonomous-decisions.log

# View recent events
tail -20 .czarina/logs/events.jsonl | jq

# Check worker status
cat .czarina/status/worker-status.json | jq

# Verify prompt sent to worker
tmux capture-pane -p -t czarina-project:worker-id | tail -20
```

## Troubleshooting

### Czar won't start

```bash
# Check config exists
ls -la .czarina/config.json

# Check logging system
source czarina-core/logging.sh
czarina_log_init
```

### Workers not detected

```bash
# Verify worker status update works
./czarina-core/update-worker-status.sh
cat .czarina/status/worker-status.json

# Check jq is installed
which jq
```

### Prompts not sent to workers

```bash
# Check tmux session exists
tmux list-sessions | grep czarina

# Check session naming
cat .czarina/config.json | jq -r '.project.slug'

# Manually test prompt
tmux send-keys -t "czarina-project:worker-id" "test" C-m
```

## Performance Considerations

### Resource Usage

- **CPU**: Minimal (mostly sleeping, jq parsing)
- **Memory**: ~10-20MB (bash + jq processes)
- **Disk**: Log files grow over time (consider rotation)

### Scalability

- Tested with: 5-10 workers
- Expected to handle: 20+ workers
- Bottleneck: `update-worker-status.sh` (git operations per worker)

### Log Rotation

Consider rotating logs for long-running projects:

```bash
# Rotate decisions log (keep last 1000 lines)
tail -1000 .czarina/status/autonomous-decisions.log > /tmp/decisions.tmp
mv /tmp/decisions.tmp .czarina/status/autonomous-decisions.log
```

## References

- **IMPROVEMENT_PLAN A3**: Autonomous Czar Loop
- **IMPROVEMENT_PLAN A4**: Worker Health Monitoring
- **IMPROVEMENT_PLAN A2**: Structured Logging Integration
- **Enhancement #14**: Hopper Monitoring (Task 2)
- **IMPROVEMENT_PLAN B4**: Dependency Tracking (Task 3)

## See Also

- `docs/LOGGING.md` - Logging system documentation
- `docs/WORKER_STATUS.md` - Worker status tracking
- `docs/CZAR_COORDINATION.md` - (Task 3) Overall coordination strategy
