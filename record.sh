#!/bin/bash
#
# PostToolUse hook: records tool usage to date-partitioned JSONL files.
# Reads JSON payload from stdin with fields: tool_name, tool_input, cwd
# Writes to ~/r/history/<hostname>/claude/YYYYMM/dd.jsonl
#

set -euo pipefail

payload="$(cat)"

BASE_DIR="$HOME/r/history/$(hostname -s)/claude"
MAX_STRING_LEN=200

# Date-partitioned path (UTC)
dir="$BASE_DIR/$(date -u +%Y%m)"
file="$dir/$(date -u +%d).jsonl"
mkdir -p "$dir"

# Build record: metadata + tool_name + truncated tool_input
# Long strings (file content, edit diffs) are truncated to keep records compact
echo "$payload" | jq -c \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg hn "$(hostname -s)" \
  --arg gb "$(git -C "$PWD" branch --show-current 2>/dev/null || echo '')" \
  --argjson max "$MAX_STRING_LEN" \
  '{
    timestamp: $ts,
    hostname: $hn,
    cwd: .cwd,
    git_branch: $gb,
    tool_name: .tool_name,
    tool_input: (.tool_input | walk(
      if type == "string" and length > $max then
        .[:$max] + "...[truncated]"
      else . end
    ))
  }' >> "$file"
