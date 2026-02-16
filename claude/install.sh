#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_SRC="$SCRIPT_DIR/commands"
COMMANDS_TGT="$HOME/.claude/commands"

# --- Helpers ---

info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[1;32m[ok]\033[0m    %s\n' "$*"; }

# Create a symlink, backing up existing files first.
# Usage: make_link <source> <target>
make_link() {
    local src="$1" tgt="$2"

    # Already correct
    if [ -L "$tgt" ] && [ "$(readlink "$tgt")" = "$src" ]; then
        ok "$tgt -> $src (already set)"
        return
    fi

    # Back up existing file/symlink
    if [ -e "$tgt" ] || [ -L "$tgt" ]; then
        local backup="${tgt}.bak.$(date +%Y%m%d%H%M%S)"
        warn "Backing up $tgt -> $backup"
        mv "$tgt" "$backup"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$tgt")"

    ln -s "$src" "$tgt"
    ok "$tgt -> $src"
}

# --- Install ---

info "Claude Code commands installer"
info "Source: $COMMANDS_SRC"
info "Target: $COMMANDS_TGT"
echo

mkdir -p "$COMMANDS_TGT"

count=0
for file in "$COMMANDS_SRC"/*.md; do
    [ -f "$file" ] || continue
    name="$(basename "$file")"
    make_link "$file" "$COMMANDS_TGT/$name"
    count=$((count + 1))
done

echo
if [ "$count" -eq 0 ]; then
    warn "No .md command files found in $COMMANDS_SRC"
else
    info "Installed $count command(s)"
fi

info "Done!"
