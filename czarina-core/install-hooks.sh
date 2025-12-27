#!/bin/bash
# Install git hooks in worker worktrees

CZARINA_DIR="${1:-.czarina}"
PROJECT_ROOT="${2:-.}"

for worktree in "${CZARINA_DIR}/worktrees/"*/; do
    if [ -d "$worktree/.git" ]; then
        # Install post-commit hook
        if [ -f "${PROJECT_ROOT}/czarina-core/hooks/post-commit" ]; then
            cp "${PROJECT_ROOT}/czarina-core/hooks/post-commit" "${worktree}/.git/hooks/"
            chmod +x "${worktree}/.git/hooks/post-commit"
        fi

        # Install pre-push hook (dependency validation)
        if [ -f "${PROJECT_ROOT}/czarina-core/hooks/pre-push" ]; then
            cp "${PROJECT_ROOT}/czarina-core/hooks/pre-push" "${worktree}/.git/hooks/"
            chmod +x "${worktree}/.git/hooks/pre-push"
        fi

        echo "✅ Installed hooks in $(basename $worktree)"
    fi
done
