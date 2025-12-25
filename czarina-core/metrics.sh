#!/bin/bash
# Activity Metrics Calculation
# Real-time metrics for worker progress tracking
# Part of Czarina v0.5.0 - Autonomous Orchestration

set -uo pipefail

# Configuration
CZARINA_DIR="${1:-.czarina}"
WORKER_ID="${2:-}"
CONFIG_FILE="${CZARINA_DIR}/config.json"

# Validate config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    exit 1
fi

# Check for required tools
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed"
    exit 1
fi

# Load project configuration
PROJECT_ROOT=$(jq -r '.project.repository' "$CONFIG_FILE")
WORKER_COUNT=$(jq '.workers | length' "$CONFIG_FILE")

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FILES CHANGED METRIC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Count files changed in a worker's branch
metrics_files_changed() {
    local worker_id=$1
    local worker_branch=$(jq -r ".workers[] | select(.id == \"$worker_id\") | .branch" "$CONFIG_FILE")

    if [ "$worker_branch" = "null" ] || [ -z "$worker_branch" ]; then
        echo "0"
        return
    fi

    cd "$PROJECT_ROOT" 2>/dev/null || {
        echo "0"
        return
    }

    # Check if branch exists
    if ! git rev-parse --verify "$worker_branch" >/dev/null 2>&1; then
        echo "0"
        return
    fi

    # Count files changed compared to main
    local files=$(git diff --name-only main..."$worker_branch" 2>/dev/null | wc -l || echo "0")
    echo "$files"
}

# Get files changed in worktree (unstaged/uncommitted changes)
metrics_files_changed_worktree() {
    local worker_id=$1
    local worktree_path="${PROJECT_ROOT}/.czarina/worktrees/${worker_id}"

    if [ ! -d "$worktree_path" ]; then
        echo "0"
        return
    fi

    cd "$worktree_path" 2>/dev/null || {
        echo "0"
        return
    }

    # Count unstaged + staged changes
    local files=$(git status --short 2>/dev/null | wc -l || echo "0")
    echo "$files"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TASKS COMPLETED METRIC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Count tasks completed (from log events)
metrics_tasks_completed() {
    local worker_id=$1
    local worker_log="${CZARINA_DIR}/logs/${worker_id}.log"

    if [ ! -f "$worker_log" ]; then
        echo "0"
        return
    fi

    # Count TASK_COMPLETE events
    local tasks=$(grep -c "TASK_COMPLETE" "$worker_log" 2>/dev/null || echo "0")
    echo "$tasks"
}

# Count checkpoints (commits logged)
metrics_checkpoints() {
    local worker_id=$1
    local worker_log="${CZARINA_DIR}/logs/${worker_id}.log"

    if [ ! -f "$worker_log" ]; then
        echo "0"
        return
    fi

    # Count CHECKPOINT events
    local checkpoints=$(grep -c "CHECKPOINT" "$worker_log" 2>/dev/null || echo "0")
    echo "$checkpoints"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LAST ACTIVITY METRIC
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Get last activity timestamp (epoch seconds)
metrics_last_activity() {
    local worker_id=$1
    local worker_log="${CZARINA_DIR}/logs/${worker_id}.log"

    if [ ! -f "$worker_log" ]; then
        echo "0"
        return
    fi

    # Get modification time of log file
    local timestamp=$(stat -c %Y "$worker_log" 2>/dev/null || echo "0")
    echo "$timestamp"
}

# Calculate seconds since last activity
metrics_idle_time() {
    local worker_id=$1
    local last_activity=$(metrics_last_activity "$worker_id")
    local current_time=$(date +%s)
    local idle_seconds=$((current_time - last_activity))
    echo "$idle_seconds"
}

# Format idle time as human-readable string
metrics_format_time() {
    local seconds=$1

    if [ $seconds -lt 60 ]; then
        echo "${seconds}s"
    elif [ $seconds -lt 3600 ]; then
        local minutes=$((seconds / 60))
        echo "${minutes}m"
    elif [ $seconds -lt 86400 ]; then
        local hours=$((seconds / 3600))
        local minutes=$(((seconds % 3600) / 60))
        echo "${hours}h ${minutes}m"
    else
        local days=$((seconds / 86400))
        local hours=$(((seconds % 86400) / 3600))
        echo "${days}d ${hours}h"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMMIT METRICS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Count commits on worker branch
metrics_commits() {
    local worker_id=$1
    local worker_branch=$(jq -r ".workers[] | select(.id == \"$worker_id\") | .branch" "$CONFIG_FILE")

    if [ "$worker_branch" = "null" ] || [ -z "$worker_branch" ]; then
        echo "0"
        return
    fi

    cd "$PROJECT_ROOT" 2>/dev/null || {
        echo "0"
        return
    }

    # Check if branch exists
    if ! git rev-parse --verify "$worker_branch" >/dev/null 2>&1; then
        echo "0"
        return
    fi

    # Count commits ahead of main
    local commits=$(git rev-list --count main..."$worker_branch" 2>/dev/null || echo "0")
    echo "$commits"
}

# Count recent commits (last N minutes)
metrics_recent_commits() {
    local worker_id=$1
    local minutes=${2:-20}  # Default: last 20 minutes
    local worker_branch=$(jq -r ".workers[] | select(.id == \"$worker_id\") | .branch" "$CONFIG_FILE")

    if [ "$worker_branch" = "null" ] || [ -z "$worker_branch" ]; then
        echo "0"
        return
    fi

    cd "$PROJECT_ROOT" 2>/dev/null || {
        echo "0"
        return
    }

    # Check if branch exists
    if ! git rev-parse --verify "$worker_branch" >/dev/null 2>&1; then
        echo "0"
        return
    fi

    # Count commits in last N minutes
    local commits=$(git log "$worker_branch" --since="${minutes} minutes ago" --oneline 2>/dev/null | wc -l || echo "0")
    echo "$commits"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPREHENSIVE WORKER METRICS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Get all metrics for a worker as JSON
metrics_all() {
    local worker_id=$1

    local files_changed=$(metrics_files_changed "$worker_id")
    local files_uncommitted=$(metrics_files_changed_worktree "$worker_id")
    local tasks_complete=$(metrics_tasks_completed "$worker_id")
    local checkpoints=$(metrics_checkpoints "$worker_id")
    local commits=$(metrics_commits "$worker_id")
    local recent_commits=$(metrics_recent_commits "$worker_id")
    local last_activity=$(metrics_last_activity "$worker_id")
    local idle_seconds=$(metrics_idle_time "$worker_id")
    local idle_formatted=$(metrics_format_time "$idle_seconds")

    cat <<EOF
{
  "worker_id": "$worker_id",
  "files_changed": $files_changed,
  "files_uncommitted": $files_uncommitted,
  "tasks_completed": $tasks_complete,
  "checkpoints": $checkpoints,
  "commits": $commits,
  "recent_commits": $recent_commits,
  "last_activity_epoch": $last_activity,
  "idle_seconds": $idle_seconds,
  "idle_time": "$idle_formatted"
}
EOF
}

# Get metrics for all workers
metrics_all_workers() {
    echo "["
    local first=true

    for ((i=0; i<WORKER_COUNT; i++)); do
        local worker_id=$(jq -r ".workers[$i].id" "$CONFIG_FILE")

        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi

        metrics_all "$worker_id"
    done

    echo "]"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMMAND DISPATCH
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    METRIC="${3:-all}"

    if [ -z "$WORKER_ID" ]; then
        echo "Usage: $0 <czarina-dir> <worker-id> [metric]"
        echo ""
        echo "Metrics:"
        echo "  all              - All metrics as JSON (default)"
        echo "  files            - Files changed"
        echo "  tasks            - Tasks completed"
        echo "  commits          - Commit count"
        echo "  idle             - Idle time"
        echo "  all-workers      - Metrics for all workers"
        exit 1
    fi

    case "$METRIC" in
        files)
            metrics_files_changed "$WORKER_ID"
            ;;
        tasks)
            metrics_tasks_completed "$WORKER_ID"
            ;;
        commits)
            metrics_commits "$WORKER_ID"
            ;;
        idle)
            metrics_idle_time "$WORKER_ID"
            ;;
        all)
            metrics_all "$WORKER_ID"
            ;;
        all-workers)
            metrics_all_workers
            ;;
        *)
            echo "Unknown metric: $METRIC"
            exit 1
            ;;
    esac
fi
