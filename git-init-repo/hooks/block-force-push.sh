#!/usr/bin/env bash

  # PreToolUse hook: blocks force pushes. Reads the tool call as JSON on stdin.
  cmd=$(jq -r '.tool_input.command // empty')

  if echo "$cmd" | grep -Eq 'git[[:space:]]+push.*(--force|--force-with-lease|[[:space:]]-[a-zA-Z]*f|[[:space:]].*\+(\w+))'; then
    echo "Blocked by git-init-repo: force push is not allowed. Explain the rejection to the user and let them decide." >&2
    exit 2
  fi
  exit 0
