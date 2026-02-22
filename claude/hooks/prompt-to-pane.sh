#!/bin/bash
# Save user prompt to a temp file for the status line to pick up,
# and immediately update the pane title.
# Called by UserPromptSubmit hook.

INPUT=$(cat)

# Extract prompt — get everything between "prompt":" and the next unescaped "
PROMPT=$(echo "$INPUT" | sed -n 's/.*"prompt"\s*:\s*"\(.*\)/\1/p' | sed 's/\\"//g; s/".*//')
SESSION_ID=$(echo "$INPUT" | grep -oP '"session_id"\s*:\s*"\K[^"]*')
CWD=$(echo "$INPUT" | grep -oP '"cwd"\s*:\s*"\K[^"]*')

# Clean up: collapse whitespace, truncate
PROMPT=$(echo "$PROMPT" | tr '\n' ' ' | sed 's/  */ /g')
MAX_LEN=50
if [ ${#PROMPT} -gt $MAX_LEN ]; then
    PROMPT="${PROMPT:0:$MAX_LEN}…"
fi

# Persist for the status line to read
STATE_DIR="$HOME/.claude/state"
mkdir -p "$STATE_DIR"
echo "$PROMPT" > "$STATE_DIR/prompt-$SESSION_ID"

# Also set pane title immediately (without model — status line adds it later)
if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
    PROJECT=""
    if [ -n "$CWD" ] && [ "$CWD" != "$HOME" ]; then
        CHECK="$CWD"
        while [ "$CHECK" != "$HOME" ] && [ "$CHECK" != "/" ]; do
            if [ -f "$CHECK/CLAUDE.md" ]; then
                PROJECT="$(basename "$CHECK")"
                break
            fi
            CHECK="$(dirname "$CHECK")"
        done
    fi
    PROJECT="${PROJECT:-claude}"
    tmux select-pane -t "$TMUX_PANE" -T "$PROJECT | $PROMPT"
fi
