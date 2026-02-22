#!/bin/bash
# Clear the saved prompt when Claude finishes responding.
# Called by Stop hook.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | grep -oP '"session_id"\s*:\s*"\K[^"]*')

STATE_DIR="$HOME/.claude/state"
rm -f "$STATE_DIR/prompt-$SESSION_ID"

# Reset pane title to just project name
[ -z "$TMUX" ] && exit 0

CWD=$(echo "$INPUT" | grep -oP '"cwd"\s*:\s*"\K[^"]*')
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

tmux select-pane -t "$TMUX_PANE" -T "$PROJECT"
