#!/bin/bash
# Czarina Autonomous Daemon - Handles all worker approvals and monitoring
# The human should NEVER need to approve - Czar makes all decisions
#
# This is the generalized version that works with any Czarina project

set -uo pipefail  # Don't use -e in daemon - we want it to continue on errors

# Configuration (can be overridden by config file)
PROJECT_DIR="${1:-.}"
CONFIG_FILE="${PROJECT_DIR}/config.json"

# Validate config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    echo "Usage: $0 <project-orchestration-dir>"
    echo "Example: $0 /path/to/project/czarina-myproject"
    exit 1
fi

# Load configuration from JSON
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed"
    exit 1
fi

PROJECT_SLUG=$(jq -r '.project.slug' "$CONFIG_FILE")
PROJECT_ROOT=$(jq -r '.project.repository' "$CONFIG_FILE")
WORKER_COUNT=$(jq '.workers | length' "$CONFIG_FILE")

# Session and logging
# Try to find actual session name - check multiple naming patterns
POSSIBLE_SESSIONS=(
    "czarina-${PROJECT_SLUG}"
    "${PROJECT_SLUG}-session"
    # Also try without dashes (multi-agent-support -> multiagent or multi-agent)
    "czarina-$(echo $PROJECT_SLUG | sed 's/-//')"
)

SESSION=""
for sess in "${POSSIBLE_SESSIONS[@]}"; do
    if tmux has-session -t "$sess" 2>/dev/null; then
        SESSION="$sess"
        break
    fi
done

if [ -z "$SESSION" ]; then
    echo "⚠️  Warning: No worker session found"
    echo "   Tried: ${POSSIBLE_SESSIONS[*]}"
    echo "   Daemon will start but may not find workers until session is created"
    SESSION="czarina-${PROJECT_SLUG}"  # Default guess
fi
LOG_FILE="${PROJECT_DIR}/status/daemon.log"
SLEEP_INTERVAL=120  # Check every 2 minutes

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

echo "🎭 CZAR DAEMON STARTING" | tee -a "$LOG_FILE"
echo "Time: $(date)" | tee -a "$LOG_FILE"
echo "Project: $PROJECT_SLUG" | tee -a "$LOG_FILE"
echo "Session: $SESSION" | tee -a "$LOG_FILE"
echo "Workers: $WORKER_COUNT" | tee -a "$LOG_FILE"
echo "Check interval: ${SLEEP_INTERVAL}s" | tee -a "$LOG_FILE"
echo "======================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Function to auto-approve all pending requests
auto_approve_all() {
    local approved_count=0

    for ((window=0; window<WORKER_COUNT; window++)); do
        output=$(tmux capture-pane -t $SESSION:$window -p 2>/dev/null || echo "")

        # Check for "Do you want to proceed?" prompts
        if echo "$output" | grep -q "Do you want to proceed?"; then
            # CZAR DECISION: Always approve option 2 (allow reading from directories)
            echo "[$(date '+%H:%M:%S')] Auto-approving window $window" | tee -a "$LOG_FILE"
            tmux send-keys -t $SESSION:$window "2" C-m 2>/dev/null
            ((approved_count++))
            sleep 0.5
        fi

        # Check for edit acceptance prompts "accept edits" - try multiple methods
        if echo "$output" | grep -q "accept edits"; then
            # CZAR DECISION: Always accept edits workers propose
            echo "[$(date '+%H:%M:%S')] Auto-accepting edits in window $window" | tee -a "$LOG_FILE"
            # Try just Enter
            tmux send-keys -t $SESSION:$window C-m 2>/dev/null
            sleep 0.3
            # If still there, try Tab then Enter (to select default)
            tmux send-keys -t $SESSION:$window Tab C-m 2>/dev/null
            ((approved_count++))
            sleep 0.5
        fi

        # Check for Y/N prompts
        if echo "$output" | tail -5 | grep -qiE "\[Y/n\]|\(y/N\)"; then
            # CZAR DECISION: Default to yes for most prompts
            echo "[$(date '+%H:%M:%S')] Auto-confirming Y/N in window $window" | tee -a "$LOG_FILE"
            tmux send-keys -t $SESSION:$window "y" C-m 2>/dev/null
            ((approved_count++))
            sleep 0.5
        fi

        # Check if just waiting at prompt (might need a nudge)
        if echo "$output" | tail -2 | grep -qE "^> $"; then
            last_line=$(echo "$output" | grep -E "complete|finished|done|ready" | tail -1)
            if [ -n "$last_line" ]; then
                # Worker reports done but might be waiting - send enter to confirm
                echo "[$(date '+%H:%M:%S')] Nudging idle worker in window $window" | tee -a "$LOG_FILE"
                tmux send-keys -t $SESSION:$window C-m 2>/dev/null
                ((approved_count++))
                sleep 0.5
            fi
        fi
    done

    if [ $approved_count -gt 0 ]; then
        echo "[$(date '+%H:%M:%S')] ✅ Auto-approved $approved_count items" | tee -a "$LOG_FILE"
    fi

    return $approved_count
}

# Track last activity time for each worker
declare -A LAST_ACTIVITY
declare -A STUCK_COUNT

# Function to check for workers needing guidance
check_for_issues() {
    local issues_found=0

    for ((window=0; window<WORKER_COUNT; window++)); do
        output=$(tmux capture-pane -t $SESSION:$window -p 2>/dev/null || echo "")

        # Get current pane content hash to detect changes
        current_hash=$(echo "$output" | md5sum | cut -d' ' -f1)
        last_hash="${LAST_ACTIVITY[$window]:-}"

        # Check for explicit questions to Czar
        if echo "$output" | tail -20 | grep -qiE "czar.*\?|question for czar|@czar"; then
            echo "[$(date '+%H:%M:%S')] ⚠️  Window $window has question for Czar" | tee -a "$LOG_FILE"
            echo "   Context: $(echo "$output" | grep -iE "czar.*\?|question|@czar" | tail -1)" | tee -a "$LOG_FILE"
            notify_czar "$window" "Question" "$(echo "$output" | grep -iE "czar.*\?|question|@czar" | tail -1)"
            ((issues_found++))
        fi

        # Check for errors that look serious
        if echo "$output" | tail -10 | grep -qiE "fatal|critical|cannot proceed|blocked|error:"; then
            echo "[$(date '+%H:%M:%S')] ❌ Window $window has blocking error" | tee -a "$LOG_FILE"
            error_line=$(echo "$output" | grep -iE "fatal|critical|cannot|blocked|error:" | tail -1)
            echo "   Error: $error_line" | tee -a "$LOG_FILE"
            notify_czar "$window" "Error" "$error_line"
            ((issues_found++))
        fi

        # Check if worker is stuck (no activity for multiple iterations)
        if [ "$current_hash" = "$last_hash" ]; then
            stuck_count=$((${STUCK_COUNT[$window]:-0} + 1))
            STUCK_COUNT[$window]=$stuck_count

            # If stuck for 3+ iterations (6+ minutes), flag it
            if [ $stuck_count -ge 3 ]; then
                # Check if it looks idle (at prompt)
                if echo "$output" | tail -3 | grep -qE "Ready to begin|✅|instructions"; then
                    echo "[$(date '+%H:%M:%S')] 🔔 Window $window appears idle for ${stuck_count} iterations" | tee -a "$LOG_FILE"
                    echo "   Last line: $(echo "$output" | tail -1)" | tee -a "$LOG_FILE"

                    # Try a gentle nudge
                    echo "   Sending nudge (Enter)..." | tee -a "$LOG_FILE"
                    tmux send-keys -t $SESSION:$window C-m 2>/dev/null

                    # Reset counter after nudge
                    STUCK_COUNT[$window]=0
                elif [ $stuck_count -ge 5 ]; then
                    # Stuck for 10+ minutes with no obvious prompt - escalate
                    echo "[$(date '+%H:%M:%S')] ⚠️  Window $window STUCK for ${stuck_count} iterations (10+ min)" | tee -a "$LOG_FILE"
                    notify_czar "$window" "Stuck" "No activity for $((stuck_count * 2)) minutes"
                    ((issues_found++))
                    STUCK_COUNT[$window]=0  # Reset to avoid spam
                fi
            fi
        else
            # Activity detected, reset counter
            LAST_ACTIVITY[$window]=$current_hash
            STUCK_COUNT[$window]=0
        fi
    done

    return $issues_found
}

# Function to notify Czar window (window 0)
notify_czar() {
    local worker_window=$1
    local issue_type=$2
    local message=$3

    # Send notification to Czar window (window 0 or "czar" window)
    tmux send-keys -t $SESSION:0 "" 2>/dev/null  # Just ensure window exists
    tmux send-keys -t $SESSION:0 "echo '[$(date '+%H:%M:%S')] 🔔 Worker $worker_window - $issue_type: $message'" C-m 2>/dev/null || true
}

# Main daemon loop
iteration=0
while true; do
    ((iteration++))
    echo "" | tee -a "$LOG_FILE"
    echo "=== Iteration $iteration - $(date '+%Y-%m-%d %H:%M:%S') ===" | tee -a "$LOG_FILE"

    # 1. Auto-approve everything that needs approval
    auto_approve_all
    approved=$?

    # 2. Check for issues that need Czar intelligence
    check_for_issues
    issues=$?

    # 3. If there were approvals or issues, give workers a moment then check again
    if [ $approved -gt 0 ] || [ $issues -gt 0 ]; then
        sleep 3
        auto_approve_all  # Second pass to catch cascading prompts
    fi

    # 4. Log git activity every 10 iterations (~20 min)
    if [ $((iteration % 10)) -eq 0 ]; then
        echo "[$(date '+%H:%M:%S')] Git activity check..." | tee -a "$LOG_FILE"
        cd "$PROJECT_ROOT"
        recent=$(git log --all --since="20 minutes ago" --oneline 2>/dev/null | wc -l)
        echo "[$(date '+%H:%M:%S')] Commits in last 20 min: $recent" | tee -a "$LOG_FILE"
    fi

    # Wait before next check
    sleep $SLEEP_INTERVAL
done
