#!/bin/bash
# Auto-load worker prompt based on current git branch
# This script is called by SessionStart hooks in .claude/settings.local.json

set -euo pipefail

# Find the orchestration directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$SCRIPT_DIR/..")"
ORCHESTRATION_DIR="$PROJECT_ROOT/.czarina"

# Check if orchestration exists
if [ ! -d "$ORCHESTRATION_DIR" ]; then
    echo "⚠️  No .czarina orchestration found"
    echo "This repository is not set up for multi-agent orchestration."
    exit 0
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

if [ -z "$CURRENT_BRANCH" ]; then
    echo "⚠️  Not on a git branch (detached HEAD?)"
    exit 0
fi

# Check if config.json exists
CONFIG_FILE="$ORCHESTRATION_DIR/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "⚠️  No config.json found in .czarina/"
    exit 0
fi

# Check if jq is available (optional, fallback to grep)
if command -v jq &> /dev/null; then
    # Use jq to find worker by branch
    WORKER_FILE=$(jq -r ".workers[] | select(.branch == \"$CURRENT_BRANCH\") | .id" "$CONFIG_FILE" 2>/dev/null | head -1)

    if [ -n "$WORKER_FILE" ]; then
        WORKER_PROMPT="$ORCHESTRATION_DIR/workers/${WORKER_FILE}.md"

        if [ -f "$WORKER_PROMPT" ]; then
            echo "╔════════════════════════════════════════════════════════════╗"
            echo "║        Czarina Multi-Agent Orchestration Active           ║"
            echo "╚════════════════════════════════════════════════════════════╝"
            echo ""
            echo "🎯 Worker Identity: $WORKER_FILE"
            echo "🌿 Branch: $CURRENT_BRANCH"
            echo "📄 Prompt: $WORKER_PROMPT"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""

            # Load the worker prompt
            cat "$WORKER_PROMPT"

            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "✅ Worker prompt loaded successfully!"
            echo ""
            exit 0
        fi
    fi
fi

# Fallback: Try to match branch to worker files manually
for worker_file in "$ORCHESTRATION_DIR/workers"/*.md; do
    if [ -f "$worker_file" ]; then
        worker_id=$(basename "$worker_file" .md)

        # Check if config mentions this worker with current branch
        if grep -q "\"branch\": \"$CURRENT_BRANCH\"" "$CONFIG_FILE" 2>/dev/null; then
            # Verify it's for this worker
            if grep -B 1 "\"branch\": \"$CURRENT_BRANCH\"" "$CONFIG_FILE" | grep -q "\"id\": \"$worker_id\""; then
                echo "╔════════════════════════════════════════════════════════════╗"
                echo "║        Czarina Multi-Agent Orchestration Active           ║"
                echo "╚════════════════════════════════════════════════════════════╝"
                echo ""
                echo "🎯 Worker Identity: $worker_id"
                echo "🌿 Branch: $CURRENT_BRANCH"
                echo "📄 Prompt: $worker_file"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""

                # Load the worker prompt
                cat "$worker_file"

                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "✅ Worker prompt loaded successfully!"
                echo ""
                exit 0
            fi
        fi
    fi
done

# Not a worker branch - check for czar-rules or default rules
if [ -f "$PROJECT_ROOT/.claude/czar-rules.md" ]; then
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Czar Rules Loaded (Non-Worker Branch)        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "🌿 Branch: $CURRENT_BRANCH"
    echo "📄 Loading: .claude/czar-rules.md"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    cat "$PROJECT_ROOT/.claude/czar-rules.md"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

# Also load any project-specific rules
if [ -f "$PROJECT_ROOT/.kilocode/rules" ] && ls "$PROJECT_ROOT/.kilocode/rules"/*.md &>/dev/null; then
    echo "📚 Project Rules:"
    echo ""
    cat "$PROJECT_ROOT/.kilocode/rules"/*.md
    echo ""
fi

exit 0
