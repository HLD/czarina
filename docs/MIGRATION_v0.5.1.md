# Migration Guide: v0.5.0 → v0.5.1

## Overview

v0.5.1 is a **patch release** that completes two enhancements discovered during v0.5.0 dogfooding:
- Enhancement #10: Auto-Launch Agent System
- Enhancement #11: Daemon Quiet Mode

**No breaking changes** - fully backwards compatible with v0.5.0.

## What's New

### 1. Auto-Launch Agents (Enhancement #10)

**Before (v0.5.0):**
```bash
czarina launch
# Then manually:
# - Switch to each tmux window
# - Start agent (claude/aider)
# - Paste worker instructions
# - Enable auto-approval
```

**After (v0.5.1):**
```bash
czarina launch  # Done! Agents auto-start with instructions
```

**Configuration:**
```bash
# Disable auto-launch if needed (not yet implemented)
# czarina launch --no-auto-launch

# Disable auto-approval (not yet implemented)
# czarina launch --no-auto-approve
```

**How it works:**
1. Add `agent` field to worker config:
   ```json
   {
     "workers": [
       {
         "id": "backend",
         "agent": "claude",     // or "aider", "cursor"
         "branch": "feat/backend",
         "description": "Backend API development"
       }
     ]
   }
   ```

2. Launch project:
   ```bash
   czarina launch
   ```

3. Agents auto-start with:
   - Instructions pre-loaded from `.czarina/workers/<worker-id>.md`
   - `WORKER_IDENTITY.md` created with context
   - Auto-approval configured (Claude & Aider)

**Files created:**
- `.czarina/worktrees/<worker>/.claude/settings.local.json` (Claude)
- `.czarina/worktrees/<worker>/.aider-init` (Aider)
- `.czarina/worktrees/<worker>/WORKER_IDENTITY.md` (All agents)

### 2. Daemon Quiet Mode (Enhancement #11)

**Before (v0.5.0):**
- Daemon outputs every 2 minutes regardless of activity
- Blank lines spam when idle
- Text scrolls off screen

**After (v0.5.1):**
- Daemon only outputs when workers have activity (<5 min)
- Silent iterations when idle
- Clean, elegant output

**Configuration:**
```bash
# Disable quiet mode (legacy behavior)
export DAEMON_ALWAYS_OUTPUT=true
czarina daemon start

# Custom activity threshold (default: 5 minutes)
export DAEMON_ACTIVITY_THRESHOLD=600  # 10 minutes
czarina daemon start
```

**How it works:**
- Daemon checks for recent git commits or log file updates
- If activity detected (<5 min ago): Normal output
- If no activity: Silent iteration (still runs checks, just no output)

## Upgrade Steps

### Step 1: Update Czarina

```bash
cd /path/to/czarina
git fetch origin
git checkout v0.5.1
```

### Step 2: Test New Features (Optional)

**Test auto-launch:**
```bash
# Add agent types to existing config
jq '.workers[0].agent = "claude"' .czarina/config.json > /tmp/config.json
mv /tmp/config.json .czarina/config.json

# Launch project
czarina launch

# Verify:
# - Claude starts automatically in worker window
# - WORKER_IDENTITY.md exists in worktree
# - .claude/settings.local.json created
```

**Test daemon quiet mode:**
```bash
# Start daemon
czarina daemon start

# Wait 5+ minutes with no worker activity
# Verify daemon doesn't spam output

# Make a commit in a worker branch
git commit -m "test" --allow-empty

# Verify daemon outputs in next iteration
```

### Step 3: Update Config (Optional)

Add agent types to worker definitions:

```json
{
  "workers": [
    {
      "id": "my-worker",
      "agent": "claude",  // or "aider", "cursor", null
      "branch": "feat/my-feature",
      "description": "Feature description",
      "dependencies": []
    }
  ]
}
```

**Supported agent types:**
- `"claude"` - Claude Code CLI
- `"aider"` - Aider CLI
- `"cursor"` - Cursor (manual launch, GUI app)
- `null` or omit - No auto-launch (manual start)

## New Documentation

- [czarina-core/docs/AUTO_LAUNCH.md](../czarina-core/docs/AUTO_LAUNCH.md) - Auto-launch system guide
- [czarina-core/docs/DAEMON.md](../czarina-core/docs/DAEMON.md) - Daemon quiet mode guide

## Backwards Compatibility

**100% compatible** with v0.5.0:
- Existing configs work without changes
- Agent types are optional (defaults to manual startup)
- Daemon quiet mode can be disabled
- No API or CLI changes (only additions)

**If you don't add `agent` field:**
- Workers launch as before (manual agent start)
- Everything works exactly like v0.5.0

**If you don't like quiet mode:**
```bash
export DAEMON_ALWAYS_OUTPUT=true
```

## Known Limitations

**Still deferred to v0.6.0:**
- Enhancement #12: Czar in main terminal (not tmux)
- `--no-auto-launch` flag (planned, not implemented)
- `--no-auto-approve` flag (planned, not implemented)

**Current limitations:**
- Cursor auto-launch requires manual start (GUI app)
- Agent types must be `claude`, `aider`, `cursor`, or `null`
- Auto-launch only works with `launch-project-v2.sh` (default)

## Troubleshooting

### Auto-launch not working?

```bash
# Check agent-launcher.sh exists
ls czarina-core/agent-launcher.sh

# Check config has agent types
jq '.workers[].agent' .czarina/config.json

# Check for syntax errors
bash -n czarina-core/agent-launcher.sh

# Test agent-launcher directly
./czarina-core/agent-launcher.sh launch test-worker 1 claude test-session
```

### Daemon still spamming output?

```bash
# Verify daemon.sh has activity detection
grep "daemon_has_recent_activity" czarina-core/daemon/czar-daemon.sh

# Check if quiet mode is disabled
echo $DAEMON_ALWAYS_OUTPUT  # Should be empty or "false"

# Check daemon version
head -20 czarina-core/daemon/czar-daemon.sh | grep "daemon_has_recent_activity"
```

### Claude not starting automatically?

```bash
# Verify Claude is installed
which claude

# Check settings file was created
cat .czarina/worktrees/<worker>/.claude/settings.local.json

# Check for errors in tmux pane
tmux attach -t czarina-project
# Switch to worker window (Ctrl+b <number>)
```

### Aider not starting automatically?

```bash
# Verify Aider is installed
which aider

# Check init file was created
cat .czarina/worktrees/<worker>/.aider-init

# Check for errors in tmux pane
tmux attach -t czarina-project
# Switch to worker window (Ctrl+b <number>)
```

## Migration Checklist

- [ ] Update czarina to v0.5.1
- [ ] Read [AUTO_LAUNCH.md](../czarina-core/docs/AUTO_LAUNCH.md) documentation
- [ ] Read [DAEMON.md](../czarina-core/docs/DAEMON.md) documentation
- [ ] (Optional) Add `agent` fields to worker configs
- [ ] (Optional) Test auto-launch with `czarina launch`
- [ ] (Optional) Test daemon quiet mode
- [ ] (Optional) Configure `DAEMON_ACTIVITY_THRESHOLD` if needed
- [ ] Review [CHANGELOG.md](../CHANGELOG.md) for full details

## Examples

### Example 1: Migrate Existing Project to Auto-Launch

**Before (v0.5.0 config):**
```json
{
  "project": {
    "name": "My Project",
    "slug": "my-project",
    "repository": "/home/user/projects/my-project"
  },
  "workers": [
    {
      "id": "backend",
      "branch": "feat/backend",
      "description": "Backend API"
    },
    {
      "id": "frontend",
      "branch": "feat/frontend",
      "description": "Frontend UI"
    }
  ]
}
```

**After (v0.5.1 config with auto-launch):**
```json
{
  "project": {
    "name": "My Project",
    "slug": "my-project",
    "repository": "/home/user/projects/my-project"
  },
  "workers": [
    {
      "id": "backend",
      "agent": "claude",  // Added
      "branch": "feat/backend",
      "description": "Backend API"
    },
    {
      "id": "frontend",
      "agent": "aider",  // Added
      "branch": "feat/frontend",
      "description": "Frontend UI"
    }
  ]
}
```

**Result:**
- `backend` worker: Claude auto-starts with instructions
- `frontend` worker: Aider auto-starts with instructions

### Example 2: Daemon Quiet Mode Configuration

**Scenario:** Large project with infrequent commits

```bash
# Set longer activity threshold (15 minutes)
export DAEMON_ACTIVITY_THRESHOLD=900

# Start daemon
czarina daemon start

# Daemon will only output if workers have activity in last 15 minutes
```

**Scenario:** Want legacy behavior (always output)

```bash
# Disable quiet mode
export DAEMON_ALWAYS_OUTPUT=true

# Start daemon
czarina daemon start

# Daemon outputs every iteration like v0.5.0
```

## Questions?

See the v0.5.1 release notes: https://github.com/apathy-ca/czarina/releases/tag/v0.5.1

**Documentation:**
- [AUTO_LAUNCH.md](../czarina-core/docs/AUTO_LAUNCH.md) - Auto-launch system
- [DAEMON.md](../czarina-core/docs/DAEMON.md) - Daemon quiet mode
- [CHANGELOG.md](../CHANGELOG.md) - Full changelog

**Issues:**
- Report bugs: https://github.com/apathy-ca/czarina/issues
- Ask questions: https://github.com/apathy-ca/czarina/discussions
