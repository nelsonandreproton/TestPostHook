#!/bin/bash
# PostToolUse hook: run pytest after editing a Python file.
# Reads Claude Code hook JSON from stdin.
# Exits 0 (no-op) for non-Python files or passing tests.
# Outputs a blocking JSON response when tests fail so Claude sees the output.

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only act on .py files
if ! echo "$FILE" | grep -qE '\.py$'; then
  exit 0
fi

# Run pytest from the project root (Claude Code sets cwd to project root)
OUTPUT=$(pytest 2>&1)
RC=$?

# RC=0: all tests passed; RC=5: no tests collected — both are fine
if [ $RC -eq 0 ] || [ $RC -eq 5 ]; then
  exit 0
fi

# Tests failed — block and feed output back to the model
CONTEXT=$(printf '%s' "$OUTPUT" | jq -Rs .)
printf '{"decision":"block","reason":"pytest failed — fix the errors before proceeding","hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}' "$CONTEXT"
