#!/bin/bash
# Status line script: sets tmux pane title with project, model, and current prompt.
# Receives JSON on stdin from Claude Code with session metadata.

INPUT=$(cat)

MODEL=$(echo "$INPUT" | grep -oP '"display_name"\s*:\s*"\K[^"]*')
SESSION_ID=$(echo "$INPUT" | grep -oP '"session_id"\s*:\s*"\K[^"]*')
CWD=$(echo "$INPUT" | grep -oP '"cwd"\s*:\s*"\K[^"]*' | head -1)

# Determine project name
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

# Read current prompt if one is active
PROMPT=""
PROMPT_FILE="$HOME/.claude/state/prompt-$SESSION_ID"
if [ -f "$PROMPT_FILE" ]; then
    PROMPT=$(cat "$PROMPT_FILE")
fi

# Build pane title
TITLE="$PROJECT ($MODEL)"
if [ -n "$PROMPT" ]; then
    TITLE="$TITLE | $PROMPT"
fi

# Update tmux pane title
if [ -n "$TMUX" ]; then
    tmux select-pane -T "$TITLE"
fi
