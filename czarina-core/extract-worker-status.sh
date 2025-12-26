#!/bin/bash
# Extract worker status from structured logs

CZARINA_DIR="${1:-.czarina}"
LOGS_DIR="${CZARINA_DIR}/logs"
OUTPUT="${CZARINA_DIR}/worker-status.json"

# Start JSON
echo "{" > "$OUTPUT"
echo "  \"last_updated\": \"$(date -Iseconds)\"," >> "$OUTPUT"
echo "  \"workers\": {" >> "$OUTPUT"

first=true
for worker_log in "${LOGS_DIR}"/*.log; do
    if [ "$worker_log" = "${LOGS_DIR}/orchestration.log" ]; then
        continue
    fi

    worker_id=$(basename "$worker_log" .log)

    # Extract info from log
    last_event=$(grep -oP '(?<=] )[A-Z_]+' "$worker_log" | tail -1)
    last_timestamp=$(tail -1 "$worker_log" | grep -oP '\[\K[0-9:]+')

    # Determine status
    if echo "$last_event" | grep -q "WORKER_COMPLETE"; then
        status="complete"
    elif echo "$last_event" | grep -q "TASK_START"; then
        status="working"
    elif echo "$last_event" | grep -q "TASK_COMPLETE"; then
        status="idle"
    else
        status="unknown"
    fi

    # Get current task from log
    current_task=$(grep "TASK_START" "$worker_log" | tail -1 | sed 's/.*TASK_START: //')

    # Add to JSON
    if [ "$first" = false ]; then
        echo "," >> "$OUTPUT"
    fi
    first=false

    cat >> "$OUTPUT" <<EOF
    "$worker_id": {
      "status": "$status",
      "current_task": "$current_task",
      "last_event": "$last_event",
      "last_update": "$last_timestamp"
    }
EOF
done

echo "" >> "$OUTPUT"
echo "  }" >> "$OUTPUT"
echo "}" >> "$OUTPUT"

echo "✅ Worker status extracted: $OUTPUT"
