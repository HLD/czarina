#!/usr/bin/env bash
# czarina-core/logging.sh
# Structured logging system for czarina v0.5.0
# Provides human-readable logs and machine-readable event stream

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Get CZARINA_DIR from environment or default to .czarina
CZARINA_DIR="${CZARINA_DIR:-.czarina}"
LOGS_DIR="${CZARINA_DIR}/logs"
EVENTS_FILE="${LOGS_DIR}/events.jsonl"
ORCHESTRATION_LOG="${LOGS_DIR}/orchestration.log"

# ============================================================================
# INITIALIZATION
# ============================================================================

# czarina_log_init()
# Initialize logging infrastructure
# Creates log directories and base files
czarina_log_init() {
  local force="${1:-false}"

  # Create logs directory if it doesn't exist
  if [[ ! -d "$LOGS_DIR" ]]; then
    mkdir -p "$LOGS_DIR"
    echo "[$(date +%H:%M:%S)] Created logs directory: $LOGS_DIR" >&2
  fi

  # Create events.jsonl if it doesn't exist
  if [[ ! -f "$EVENTS_FILE" ]]; then
    touch "$EVENTS_FILE"
    echo "[$(date +%H:%M:%S)] Created event stream: $EVENTS_FILE" >&2
  fi

  # Create orchestration.log if it doesn't exist
  if [[ ! -f "$ORCHESTRATION_LOG" ]]; then
    touch "$ORCHESTRATION_LOG"
    echo "[$(date +%H:%M:%S)] Created orchestration log: $ORCHESTRATION_LOG" >&2
  fi

  return 0
}

# ============================================================================
# HUMAN-READABLE LOGGING
# ============================================================================

# czarina_log_worker()
# Log a worker event to the worker's log file
# Usage: czarina_log_worker <worker-id> <emoji> <event-type> <description> [key=value ...]
# Example: czarina_log_worker foundation 🚀 WORKER_START "Starting foundation worker"
czarina_log_worker() {
  local worker_id="${1:?Worker ID required}"
  local emoji="${2:?Emoji required}"
  local event_type="${3:?Event type required}"
  local description="${4:?Description required}"
  shift 4
  local metadata="$*"

  # Ensure logs directory exists
  mkdir -p "$LOGS_DIR"

  local worker_log="${LOGS_DIR}/${worker_id}.log"
  local timestamp=$(date +%H:%M:%S)

  # Format: [HH:MM:SS] [EMOJI] EVENT_TYPE: description (key=value)
  if [[ -n "$metadata" ]]; then
    echo "[${timestamp}] ${emoji} ${event_type}: ${description} (${metadata})" >> "$worker_log"
  else
    echo "[${timestamp}] ${emoji} ${event_type}: ${description}" >> "$worker_log"
  fi
}

# czarina_log_daemon()
# Log a daemon event to orchestration.log
# Usage: czarina_log_daemon <emoji> <event-type> <description> [key=value ...]
# Example: czarina_log_daemon 🔄 DAEMON_ITERATION "Checking worker status"
czarina_log_daemon() {
  local emoji="${1:?Emoji required}"
  local event_type="${2:?Event type required}"
  local description="${3:?Description required}"
  shift 3
  local metadata="$*"

  # Ensure logs directory exists
  mkdir -p "$LOGS_DIR"

  local timestamp=$(date +%H:%M:%S)

  # Format: [HH:MM:SS] [EMOJI] EVENT_TYPE: description (key=value)
  if [[ -n "$metadata" ]]; then
    echo "[${timestamp}] ${emoji} ${event_type}: ${description} (${metadata})" >> "$ORCHESTRATION_LOG"
  else
    echo "[${timestamp}] ${emoji} ${event_type}: ${description}" >> "$ORCHESTRATION_LOG"
  fi
}

# ============================================================================
# MACHINE-READABLE EVENT STREAM
# ============================================================================

# czarina_log_event()
# Append a structured event to events.jsonl
# Usage: czarina_log_event <worker-id|daemon|czar> <event-type> [key=value ...]
# Example: czarina_log_event foundation TASK_START task=logging status=in_progress
czarina_log_event() {
  local source="${1:?Source required (worker-id, daemon, or czar)}"
  local event_type="${2:?Event type required}"
  shift 2

  # Ensure logs directory exists
  mkdir -p "$LOGS_DIR"

  local timestamp=$(date -Iseconds)

  # Build metadata object from key=value pairs
  local metadata="{"
  local first=true
  for arg in "$@"; do
    if [[ "$arg" =~ ^([^=]+)=(.+)$ ]]; then
      local key="${BASH_REMATCH[1]}"
      local value="${BASH_REMATCH[2]}"

      if [[ "$first" == true ]]; then
        first=false
      else
        metadata+=","
      fi

      # Escape quotes in value
      value="${value//\"/\\\"}"
      metadata+="\"${key}\":\"${value}\""
    fi
  done
  metadata+="}"

  # Create JSON event
  local event="{\"ts\":\"${timestamp}\",\"source\":\"${source}\",\"event\":\"${event_type}\",\"metadata\":${metadata}}"

  # Append to events.jsonl
  echo "$event" >> "$EVENTS_FILE"
}

# ============================================================================
# LOG PARSING
# ============================================================================

# czarina_log_parse_last()
# Get the last log entry for a worker
# Usage: czarina_log_parse_last <worker-id>
# Returns: The last line of the worker's log file
czarina_log_parse_last() {
  local worker_id="${1:?Worker ID required}"
  local worker_log="${LOGS_DIR}/${worker_id}.log"

  if [[ ! -f "$worker_log" ]]; then
    echo ""
    return 1
  fi

  tail -n 1 "$worker_log"
}

# czarina_log_parse_event_type()
# Extract the event type from a log line
# Usage: czarina_log_parse_event_type <log-line>
# Returns: The event type (e.g., WORKER_START, TASK_COMPLETE)
czarina_log_parse_event_type() {
  local log_line="${1:?Log line required}"

  # Extract event type from format: [HH:MM:SS] [EMOJI] EVENT_TYPE: description
  if [[ "$log_line" =~ \]\ [^\ ]+\ ([A-Z_]+): ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    echo ""
    return 1
  fi
}

# czarina_log_get_worker_status()
# Get the current status of a worker based on last log entry
# Usage: czarina_log_get_worker_status <worker-id>
# Returns: Status string (STARTING, RUNNING, COMPLETED, ERROR, BLOCKED, UNKNOWN)
czarina_log_get_worker_status() {
  local worker_id="${1:?Worker ID required}"
  local last_log=$(czarina_log_parse_last "$worker_id")

  if [[ -z "$last_log" ]]; then
    echo "UNKNOWN"
    return 0
  fi

  local event_type=$(czarina_log_parse_event_type "$last_log")

  case "$event_type" in
    WORKER_START)
      echo "STARTING"
      ;;
    TASK_START|FILE_CREATE|FILE_MODIFY|TEST_RUN|COMMIT|CHECKPOINT)
      echo "RUNNING"
      ;;
    WORKER_COMPLETE)
      echo "COMPLETED"
      ;;
    ERROR)
      echo "ERROR"
      ;;
    BLOCKED)
      echo "BLOCKED"
      ;;
    *)
      echo "UNKNOWN"
      ;;
  esac
}

# czarina_log_list_workers()
# List all workers that have log files
# Usage: czarina_log_list_workers
# Returns: List of worker IDs (one per line)
czarina_log_list_workers() {
  if [[ ! -d "$LOGS_DIR" ]]; then
    return 0
  fi

  # Find all .log files except orchestration.log
  find "$LOGS_DIR" -maxdepth 1 -name "*.log" -not -name "orchestration.log" -type f -printf "%f\n" | sed 's/\.log$//' | sort
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# czarina_log_tail()
# Tail a worker's log file
# Usage: czarina_log_tail <worker-id> [lines]
czarina_log_tail() {
  local worker_id="${1:?Worker ID required}"
  local lines="${2:-10}"
  local worker_log="${LOGS_DIR}/${worker_id}.log"

  if [[ ! -f "$worker_log" ]]; then
    echo "No log file found for worker: $worker_id" >&2
    return 1
  fi

  tail -n "$lines" "$worker_log"
}

# czarina_log_follow()
# Follow a worker's log file (like tail -f)
# Usage: czarina_log_follow <worker-id>
czarina_log_follow() {
  local worker_id="${1:?Worker ID required}"
  local worker_log="${LOGS_DIR}/${worker_id}.log"

  if [[ ! -f "$worker_log" ]]; then
    echo "No log file found for worker: $worker_id" >&2
    return 1
  fi

  tail -f "$worker_log"
}

# czarina_log_events_since()
# Get events from events.jsonl since a specific timestamp
# Usage: czarina_log_events_since <timestamp>
# Example: czarina_log_events_since "2025-12-24T10:00:00-05:00"
czarina_log_events_since() {
  local since_timestamp="${1:?Timestamp required}"

  if [[ ! -f "$EVENTS_FILE" ]]; then
    return 0
  fi

  # Filter events by timestamp
  while IFS= read -r line; do
    local event_ts=$(echo "$line" | grep -oP '"ts":"\K[^"]+')
    if [[ "$event_ts" > "$since_timestamp" || "$event_ts" == "$since_timestamp" ]]; then
      echo "$line"
    fi
  done < "$EVENTS_FILE"
}

# czarina_log_events_for_worker()
# Get all events for a specific worker from events.jsonl
# Usage: czarina_log_events_for_worker <worker-id>
czarina_log_events_for_worker() {
  local worker_id="${1:?Worker ID required}"

  if [[ ! -f "$EVENTS_FILE" ]]; then
    return 0
  fi

  # Filter events by source
  grep "\"source\":\"${worker_id}\"" "$EVENTS_FILE" || true
}

# ============================================================================
# CONVENIENCE FUNCTIONS FOR WORKERS
# ============================================================================

# Default log locations for workers (can be overridden by environment)
CZARINA_LOGS_DIR="${CZARINA_LOGS_DIR:-.czarina/logs}"
CZARINA_WORKER_LOG="${CZARINA_WORKER_LOG:-${CZARINA_LOGS_DIR}/worker.log}"
CZARINA_EVENTS_LOG="${CZARINA_EVENTS_LOG:-${CZARINA_LOGS_DIR}/events.jsonl}"

# czarina_log_task_start()
# Convenience function for workers to log task start
# Usage: czarina_log_task_start "Task 1.1: Description"
czarina_log_task_start() {
    local task="$1"
    local timestamp=$(date '+%H:%M:%S')
    echo "[${timestamp}] 🎯 TASK_START: ${task}" | tee -a "$CZARINA_WORKER_LOG"

    # Also log to events
    if [[ -n "${CZARINA_WORKER_ID:-}" ]]; then
        local event_timestamp=$(date -Iseconds)
        echo "{\"ts\":\"${event_timestamp}\",\"event\":\"TASK_START\",\"worker\":\"${CZARINA_WORKER_ID}\",\"meta\":{\"task\":\"${task}\"}}" >> "$CZARINA_EVENTS_LOG"
    fi
}

# czarina_log_task_complete()
# Convenience function for workers to log task completion
# Usage: czarina_log_task_complete "Task 1.1: Description"
czarina_log_task_complete() {
    local task="$1"
    local timestamp=$(date '+%H:%M:%S')
    echo "[${timestamp}] ✅ TASK_COMPLETE: ${task}" | tee -a "$CZARINA_WORKER_LOG"

    # Also log to events
    if [[ -n "${CZARINA_WORKER_ID:-}" ]]; then
        local event_timestamp=$(date -Iseconds)
        echo "{\"ts\":\"${event_timestamp}\",\"event\":\"TASK_COMPLETE\",\"worker\":\"${CZARINA_WORKER_ID}\",\"meta\":{\"task\":\"${task}\"}}" >> "$CZARINA_EVENTS_LOG"
    fi
}

# czarina_log_checkpoint()
# Convenience function for workers to log checkpoints (usually commits)
# Usage: czarina_log_checkpoint "feature_implemented"
czarina_log_checkpoint() {
    local checkpoint="$1"
    local timestamp=$(date '+%H:%M:%S')
    echo "[${timestamp}] 💾 CHECKPOINT: ${checkpoint}" | tee -a "$CZARINA_WORKER_LOG"

    # Also log to events
    if [[ -n "${CZARINA_WORKER_ID:-}" ]]; then
        local event_timestamp=$(date -Iseconds)
        echo "{\"ts\":\"${event_timestamp}\",\"event\":\"CHECKPOINT\",\"worker\":\"${CZARINA_WORKER_ID}\",\"meta\":{\"checkpoint\":\"${checkpoint}\"}}" >> "$CZARINA_EVENTS_LOG"
    fi
}

# czarina_log_worker_complete()
# Convenience function for workers to log completion
# Usage: czarina_log_worker_complete
czarina_log_worker_complete() {
    local timestamp=$(date '+%H:%M:%S')
    echo "[${timestamp}] 🎉 WORKER_COMPLETE: All tasks done" | tee -a "$CZARINA_WORKER_LOG"

    # Also log to events
    if [[ -n "${CZARINA_WORKER_ID:-}" ]]; then
        local event_timestamp=$(date -Iseconds)
        echo "{\"ts\":\"${event_timestamp}\",\"event\":\"WORKER_COMPLETE\",\"worker\":\"${CZARINA_WORKER_ID}\",\"meta\":{}}" >> "$CZARINA_EVENTS_LOG"
    fi
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================

# Export all public functions
export -f czarina_log_init
export -f czarina_log_worker
export -f czarina_log_daemon
export -f czarina_log_event
export -f czarina_log_parse_last
export -f czarina_log_parse_event_type
export -f czarina_log_get_worker_status
export -f czarina_log_list_workers
export -f czarina_log_tail
export -f czarina_log_follow
export -f czarina_log_events_since
export -f czarina_log_events_for_worker
export -f czarina_log_task_start
export -f czarina_log_task_complete
export -f czarina_log_checkpoint
export -f czarina_log_worker_complete
