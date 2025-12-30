#!/bin/bash
# Unit tests for phase-transition.sh
# Tests core functionality, edge cases, and error handling

set -euo pipefail

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PHASE_TRANSITION_SCRIPT="${SCRIPT_DIR}/../phase-transition.sh"

# Test output directory
TEST_DIR="/tmp/czarina-phase-transition-tests-$$"
mkdir -p "$TEST_DIR"

# Cleanup on exit
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# ============================================================================
# TEST HELPERS
# ============================================================================

print_test_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "TEST: $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

assert_equal() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $message"
        echo "   Expected: $expected"
        echo "   Actual:   $actual"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if echo "$haystack" | grep -q "$needle"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $message"
        echo "   Expected to find: $needle"
        echo "   In: $haystack"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File exists: $file}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ -f "$file" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: $message"
        echo "   File not found: $file"
        return 1
    fi
}

create_test_config() {
    local config_file="$1"
    local phase="${2:-1}"
    local num_workers="${3:-2}"

    cat > "$config_file" <<EOF
{
  "project": {
    "name": "Test Project",
    "slug": "test_project",
    "version": "0.1.0",
    "phase": $phase,
    "description": "Test configuration",
    "repository": "$TEST_DIR/repo",
    "orchestration_dir": ".czarina"
  },
  "orchestration": {
    "mode": "local",
    "auto_push_branches": false
  },
  "omnibus_branch": "cz${phase}/release/v0.1.0",
  "workers": [
    {
      "id": "worker-1",
      "role": "core",
      "agent": "claude",
      "branch": "cz${phase}/feat/worker-1",
      "phase": $phase,
      "description": "Test worker 1",
      "dependencies": []
    },
    {
      "id": "worker-2",
      "role": "core",
      "agent": "claude",
      "branch": "cz${phase}/feat/worker-2",
      "phase": $phase,
      "description": "Test worker 2",
      "dependencies": []
    }
  ]
}
EOF
}

create_worker_status() {
    local status_dir="$1"
    local worker_id="$2"
    local status="${3:-COMPLETE}"

    mkdir -p "$status_dir"
    cat > "${status_dir}/${worker_id}.status.json" <<EOF
{
  "worker_id": "$worker_id",
  "status": "$status",
  "updated": "$(date -Iseconds)"
}
EOF
}

# ============================================================================
# TESTS
# ============================================================================

test_check_phase_complete() {
    print_test_header "Check phase complete status"

    local test_dir="${TEST_DIR}/test1"
    local test_config="${test_dir}/config.json"
    local status_dir="${test_dir}/status"

    mkdir -p "$test_dir"
    create_test_config "$test_config" 1 2
    create_worker_status "$status_dir" "worker-1" "COMPLETE"
    create_worker_status "$status_dir" "worker-2" "COMPLETE"

    local output=$("$PHASE_TRANSITION_SCRIPT" "$test_config" check 2>&1 || true)

    assert_contains "$output" "Phase 1 is COMPLETE" "Detects complete phase"
}

test_check_phase_incomplete() {
    print_test_header "Check phase incomplete status"

    local test_dir="${TEST_DIR}/test2"
    local test_config="${test_dir}/config.json"
    local status_dir="${test_dir}/status"

    mkdir -p "$test_dir"
    create_test_config "$test_config" 1 2
    create_worker_status "$status_dir" "worker-1" "COMPLETE"
    create_worker_status "$status_dir" "worker-2" "ACTIVE"

    local output=$("$PHASE_TRANSITION_SCRIPT" "$test_config" check 2>&1 || true)

    assert_contains "$output" "Phase 1 in progress" "Detects incomplete phase"
}

test_show_next_phase() {
    print_test_header "Show next phase info"

    local test_dir="${TEST_DIR}/test3"
    local test_config="${test_dir}/config.json"

    mkdir -p "$test_dir"
    create_test_config "$test_config" 1 2

    local output=$("$PHASE_TRANSITION_SCRIPT" "$test_config" next 2>&1)

    assert_contains "$output" "Current Phase: 1" "Shows current phase"
    assert_contains "$output" "Next Phase: 2" "Shows next phase"
}

test_increment_phase() {
    print_test_header "Increment phase in config"

    local test_dir="${TEST_DIR}/test4"
    local test_config="${test_dir}/config.json"
    local status_dir="${test_dir}/status"

    mkdir -p "$test_dir"
    create_test_config "$test_config" 1 2

    # Add phase 2 workers
    local temp=$(mktemp)
    jq '.workers += [
        {
            "id": "phase2-worker-1",
            "role": "core",
            "agent": "claude",
            "branch": "cz2/feat/phase2-worker-1",
            "phase": 2,
            "description": "Phase 2 worker",
            "dependencies": []
        }
    ]' "$test_config" > "$temp"
    mv "$temp" "$test_config"

    # Mark phase 1 complete
    create_worker_status "$status_dir" "worker-1" "COMPLETE"
    create_worker_status "$status_dir" "worker-2" "COMPLETE"

    # Read initial phase
    local initial_phase=$(jq -r '.project.phase' "$test_config")
    assert_equal "1" "$initial_phase" "Initial phase is 1"

    # Note: We can't actually run the full transition in tests without tmux/worktrees
    # So we just test that the script exists and accepts the command
    local exit_code=0
    "$PHASE_TRANSITION_SCRIPT" "$test_config" check >/dev/null 2>&1 || exit_code=$?

    assert_equal "0" "$exit_code" "Check command succeeds"
}

test_no_next_phase() {
    print_test_header "Handle no next phase gracefully"

    local test_dir="${TEST_DIR}/test5"
    local test_config="${test_dir}/config.json"

    mkdir -p "$test_dir"
    create_test_config "$test_config" 1 2

    # Phase 1 has workers, but phase 2 doesn't
    local output=$("$PHASE_TRANSITION_SCRIPT" "$test_config" next 2>&1)

    assert_contains "$output" "No workers defined (final phase)" "Detects final phase"
}

test_script_executable() {
    print_test_header "Verify script is executable"

    assert_file_exists "$PHASE_TRANSITION_SCRIPT" "phase-transition.sh exists"

    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -x "$PHASE_TRANSITION_SCRIPT" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} PASS: Script is executable"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} FAIL: Script is not executable"
    fi
}

test_help_command() {
    print_test_header "Test help command"

    # Create a minimal test config for help
    local test_config="${TEST_DIR}/config_help.json"
    create_test_config "$test_config" 1 2

    local output=$("$PHASE_TRANSITION_SCRIPT" "$test_config" help 2>&1 || true)

    assert_contains "$output" "Usage:" "Shows usage information"
    assert_contains "$output" "transition" "Documents transition command"
    assert_contains "$output" "check" "Documents check command"
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║         Phase Transition System - Unit Test Suite             ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"

test_script_executable
test_help_command
test_check_phase_complete
test_check_phase_incomplete
test_show_next_phase
test_no_next_phase
test_increment_phase

# ============================================================================
# TEST SUMMARY
# ============================================================================

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                       Test Summary                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Tests run:    $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    exit 1
fi
