#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# Append a source line to a file if not already present.
# Usage: ensure_sourced <file_to_source> <target_file>
ensure_sourced() {
    local src_line="source \"$1\""
    local tgt="$2"

    if [ -f "$tgt" ] && grep -qF "$1" "$tgt"; then
        ok "$tgt already sources $1"
        return
    fi

    printf '\n%s\n' "$src_line" >> "$tgt"
    ok "Added source line to $tgt"
}

# --- OS / environment detection ---

detect_env() {
    if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
        echo "wsl"
    elif [[ "${OSTYPE:-}" == msys* || "${OSTYPE:-}" == mingw* ]]; then
        echo "windows"
    else
        echo "linux"
    fi
}

ENV="$(detect_env)"
info "Detected environment: $ENV"
info "Dotfiles directory:   $DOTFILES_DIR"
echo

# --- Install ---

case "$ENV" in
    wsl)
        # WezTerm config goes to the Windows home directory
        WIN_USER="$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')"
        WIN_HOME="/mnt/c/Users/$WIN_USER"
        if [ -d "$WIN_HOME" ]; then
            make_link "$DOTFILES_DIR/wezterm/.wezterm.lua" "$WIN_HOME/.wezterm.lua"
        else
            warn "Windows home not found at $WIN_HOME — skipping WezTerm"
        fi

        # Tmux config
        make_link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

        # Bash extensions
        ensure_sourced "$DOTFILES_DIR/bash/pane-tag.bash" "$HOME/.bashrc"
        ensure_sourced "$DOTFILES_DIR/bash/claude-pane.bash" "$HOME/.bashrc"
        ;;

    linux)
        # WezTerm config in Linux home
        make_link "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

        # Tmux config
        make_link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

        # Bash extensions
        ensure_sourced "$DOTFILES_DIR/bash/pane-tag.bash" "$HOME/.bashrc"
        ensure_sourced "$DOTFILES_DIR/bash/claude-pane.bash" "$HOME/.bashrc"
        ;;

    windows)
        # WezTerm config to USERPROFILE
        if [ -n "${USERPROFILE:-}" ]; then
            WIN_HOME="$(cygpath "$USERPROFILE")"
            make_link "$DOTFILES_DIR/wezterm/.wezterm.lua" "$WIN_HOME/.wezterm.lua"
        else
            warn "USERPROFILE not set — skipping WezTerm"
        fi
        info "Tmux/bash setup skipped on native Windows"
        ;;
esac

echo
info "Done!"
