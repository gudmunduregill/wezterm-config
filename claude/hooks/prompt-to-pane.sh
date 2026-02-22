#!/bin/bash
# Save user prompt to a temp file for the status line to pick up.
# Called by UserPromptSubmit hook.

INPUT=$(cat)

PROMPT=$(echo "$INPUT" | grep -oP '"prompt"\s*:\s*"\K[^"]*')
SESSION_ID=$(echo "$INPUT" | grep -oP '"session_id"\s*:\s*"\K[^"]*')

# Clean up: collapse whitespace, strip newlines, truncate
PROMPT=$(echo "$PROMPT" | tr '\n' ' ' | sed 's/  */ /g')
MAX_LEN=50
if [ ${#PROMPT} -gt $MAX_LEN ]; then
    PROMPT="${PROMPT:0:$MAX_LEN}…"
fi

STATE_DIR="$HOME/.claude/state"
mkdir -p "$STATE_DIR"
echo "$PROMPT" > "$STATE_DIR/prompt-$SESSION_ID"
