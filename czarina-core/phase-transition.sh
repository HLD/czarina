#!/bin/bash
# Czarina Phase Transition System
# Handles automated phase transitions:
# - Detects phase completion
# - Updates config for next phase
# - Launches next phase workers
# - Handles edge cases gracefully

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================================
# CONFIGURATION
# ============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load config path
CONFIG_FILE="${1:-}"
if [ -z "$CONFIG_FILE" ]; then
    # Try to find config in standard location
    if [ -f "../.czarina/config.json" ]; then
        CONFIG_FILE="../.czarina/config.json"
    elif [ -f ".czarina/config.json" ]; then
        CONFIG_FILE=".czarina/config.json"
    else
        echo -e "${RED}❌ Usage: $0 <config-file>${NC}"
        exit 1
    fi
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Config file not found: ${CONFIG_FILE}${NC}"
    exit 1
fi

# Get absolute path
CONFIG_FILE=$(readlink -f "$CONFIG_FILE")
CZARINA_DIR=$(dirname "$CONFIG_FILE")
PROJECT_ROOT=$(jq -r '.project.repository' "$CONFIG_FILE")

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$level" in
        INFO)  echo -e "${BLUE}ℹ${NC}  $msg" ;;
        WARN)  echo -e "${YELLOW}⚠${NC}  $msg" ;;
        ERROR) echo -e "${RED}❌${NC} $msg" ;;
        SUCCESS) echo -e "${GREEN}✅${NC} $msg" ;;
        *)     echo "   $msg" ;;
    esac

    # Also log to daemon log if available
    if [ -n "${CZAR_DAEMON_LOG:-}" ] && [ -f "$CZAR_DAEMON_LOG" ]; then
        echo "[$timestamp] [$level] $msg" >> "$CZAR_DAEMON_LOG"
    fi
}

# Get current phase from config
get_current_phase() {
    jq -r '.project.phase // 1' "$CONFIG_FILE"
}

# Get workers for a specific phase
get_phase_workers() {
    local phase="$1"
    jq -c ".workers[] | select(.phase == $phase or (.phase == null and $phase == 1))" "$CONFIG_FILE"
}

# Count workers in a phase
count_phase_workers() {
    local phase="$1"
    get_phase_workers "$phase" | wc -l
}

# Check if a phase has any workers defined
has_phase_workers() {
    local phase="$1"
    local count=$(count_phase_workers "$phase")
    [ "$count" -gt 0 ]
}

# Get worker status from status file
get_worker_status() {
    local worker_id="$1"
    local status_file="${CZARINA_DIR}/status/${worker_id}.status.json"

    if [ ! -f "$status_file" ]; then
        echo "PENDING"
        return
    fi

    jq -r '.status // "PENDING"' "$status_file"
}

# Check if all workers in a phase are complete
is_phase_complete() {
    local phase="$1"
    local all_complete=true

    while IFS= read -r worker; do
        local worker_id=$(echo "$worker" | jq -r '.id')
        local status=$(get_worker_status "$worker_id")

        if [ "$status" != "COMPLETE" ]; then
            all_complete=false
            break
        fi
    done < <(get_phase_workers "$phase")

    if [ "$all_complete" = "true" ]; then
        return 0
    else
        return 1
    fi
}

# ============================================================================
# PHASE TRANSITION FUNCTIONS
# ============================================================================

# Increment phase in config
increment_phase() {
    local current_phase=$(get_current_phase)
    local next_phase=$((current_phase + 1))

    log "INFO" "Incrementing phase: $current_phase → $next_phase"

    # Create backup
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"

    # Update phase in config
    jq ".project.phase = $next_phase" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    log "SUCCESS" "Phase updated to $next_phase in config"
    echo "$next_phase"
}

# Update omnibus branch for new phase
update_omnibus_branch() {
    local phase="$1"
    local version=$(jq -r '.project.version' "$CONFIG_FILE")
    local new_branch="cz${phase}/release/v${version}"

    log "INFO" "Updating omnibus branch to: $new_branch"

    jq ".omnibus_branch = \"$new_branch\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

    log "SUCCESS" "Omnibus branch set to: $new_branch"
}

# Launch workers for a specific phase
launch_phase_workers() {
    local phase="$1"

    log "INFO" "Launching Phase $phase workers..."

    # Check if any workers exist for this phase
    if ! has_phase_workers "$phase"; then
        log "WARN" "No workers defined for Phase $phase"
        return 1
    fi

    local worker_count=$(count_phase_workers "$phase")
    log "INFO" "Found $worker_count workers for Phase $phase"

    # Use launch-project-v2.sh to launch workers
    local launcher="${SCRIPT_DIR}/launch-project-v2.sh"
    if [ ! -f "$launcher" ]; then
        log "ERROR" "Launcher script not found: $launcher"
        return 1
    fi

    log "INFO" "Executing launcher: $launcher"

    # Launch with phase filter
    PHASE_FILTER="$phase" "$launcher" "$CZARINA_DIR"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log "SUCCESS" "Phase $phase workers launched successfully"
        return 0
    else
        log "ERROR" "Failed to launch Phase $phase workers (exit code: $exit_code)"
        return 1
    fi
}

# ============================================================================
# MAIN TRANSITION LOGIC
# ============================================================================

# Perform phase transition
transition_to_next_phase() {
    local current_phase=$(get_current_phase)
    local next_phase=$((current_phase + 1))

    log "INFO" "═══════════════════════════════════════════════════════════"
    log "INFO" "🔄 PHASE TRANSITION: Phase $current_phase → Phase $next_phase"
    log "INFO" "═══════════════════════════════════════════════════════════"
    echo ""

    # 1. Verify current phase is complete
    log "INFO" "Step 1: Verifying Phase $current_phase completion..."
    if ! is_phase_complete "$current_phase"; then
        log "ERROR" "Phase $current_phase is not complete yet"
        log "ERROR" "Cannot transition to next phase"
        return 1
    fi
    log "SUCCESS" "Phase $current_phase is complete"
    echo ""

    # 2. Check if next phase exists
    log "INFO" "Step 2: Checking for Phase $next_phase workers..."
    if ! has_phase_workers "$next_phase"; then
        log "WARN" "No workers defined for Phase $next_phase"
        log "INFO" "This appears to be the final phase"
        log "SUCCESS" "Project complete! 🎉"
        return 0
    fi
    log "SUCCESS" "Phase $next_phase has workers defined"
    echo ""

    # 3. Increment phase in config
    log "INFO" "Step 3: Updating configuration..."
    increment_phase
    update_omnibus_branch "$next_phase"
    echo ""

    # 4. Launch next phase workers
    log "INFO" "Step 4: Launching Phase $next_phase workers..."
    if launch_phase_workers "$next_phase"; then
        log "SUCCESS" "Phase transition complete! 🚀"
        log "INFO" "Now running: Phase $next_phase"
        return 0
    else
        log "ERROR" "Failed to launch Phase $next_phase workers"
        log "ERROR" "Manual intervention required"
        return 1
    fi
}

# ============================================================================
# CLI INTERFACE
# ============================================================================

# Show usage
show_usage() {
    echo "Czarina Phase Transition System"
    echo ""
    echo "Usage:"
    echo "  $0 <config-file> [command]"
    echo ""
    echo "Commands:"
    echo "  transition       - Perform phase transition (default)"
    echo "  check            - Check if current phase is complete"
    echo "  next             - Show next phase info"
    echo "  status           - Show current phase status"
    echo ""
    echo "Examples:"
    echo "  $0 .czarina/config.json transition"
    echo "  $0 .czarina/config.json check"
}

# Check phase completion status
check_phase_status() {
    local current_phase=$(get_current_phase)

    echo -e "${BLUE}Phase $current_phase Status${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local total=0
    local complete=0

    while IFS= read -r worker; do
        local worker_id=$(echo "$worker" | jq -r '.id')
        local status=$(get_worker_status "$worker_id")
        total=$((total + 1))

        if [ "$status" = "COMPLETE" ]; then
            complete=$((complete + 1))
            echo -e "  ${GREEN}✓${NC} $worker_id"
        else
            echo -e "  ${YELLOW}○${NC} $worker_id ($status)"
        fi
    done < <(get_phase_workers "$current_phase")

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Progress: $complete/$total complete"

    if [ $complete -eq $total ]; then
        echo -e "${GREEN}✅ Phase $current_phase is COMPLETE${NC}"
        return 0
    else
        echo -e "${YELLOW}⏳ Phase $current_phase in progress${NC}"
        return 1
    fi
}

# Show next phase info
show_next_phase() {
    local current_phase=$(get_current_phase)
    local next_phase=$((current_phase + 1))

    echo -e "${BLUE}Next Phase Info${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Current Phase: $current_phase"
    echo "  Next Phase: $next_phase"
    echo ""

    if has_phase_workers "$next_phase"; then
        local count=$(count_phase_workers "$next_phase")
        echo "  Status: $count workers defined"
        echo ""
        echo "  Workers:"
        while IFS= read -r worker; do
            local worker_id=$(echo "$worker" | jq -r '.id')
            local desc=$(echo "$worker" | jq -r '.description')
            echo "    • $worker_id - $desc"
        done < <(get_phase_workers "$next_phase")
    else
        echo "  Status: No workers defined (final phase)"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ============================================================================
# MAIN
# ============================================================================

# Parse command
COMMAND="${2:-transition}"

case "$COMMAND" in
    transition)
        transition_to_next_phase
        ;;
    check)
        check_phase_status
        ;;
    next)
        show_next_phase
        ;;
    status)
        check_phase_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac
