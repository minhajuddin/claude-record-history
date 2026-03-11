# claude-record-history

A Claude Code PostToolUse hook that records tool usage to date-partitioned JSONL files.

## How it works

Registered as a PostToolUse hook in `~/.claude/settings.json`, the script:

1. Reads the hook JSON payload from stdin (tool_name, tool_input, cwd)
2. Adds metadata: UTC timestamp, hostname, git branch
3. Truncates long strings in tool_input (>200 chars) to keep records compact
4. Appends the record to `~/r/history/claude/YYYYMM/dd.jsonl`

## Output format

Each line is a JSON object:

```json
{
  "timestamp": "2026-03-11T04:00:00Z",
  "hostname": "macbook",
  "cwd": "/Users/me/project",
  "git_branch": "main",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/Users/me/project/main.go",
    "old_string": "...[truncated]",
    "new_string": "...[truncated]"
  }
}
```

## Dependencies

- `jq` (1.6+)

## Installation

The hook is configured in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/minhajuddin/r/claude-record-history/record.sh"
          }
        ]
      }
    ]
  }
}
```
