#!/bin/bash
# Clear the saved prompt and reset pane title when Claude finishes.
# Called by Stop hook.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | grep -oP '"session_id"\s*:\s*"\K[^"]*')
CWD=$(echo "$INPUT" | grep -oP '"cwd"\s*:\s*"\K[^"]*')

# Remove prompt file
rm -f "$HOME/.claude/state/prompt-$SESSION_ID"

# Reset pane title
[ -z "$TMUX" ] || [ -z "$TMUX_PANE" ] && exit 0

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
