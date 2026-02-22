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

# Create a Windows hard link for files that Windows apps need to read.
# WSL symlinks use /mnt/c paths that Windows cannot resolve, so we use
# cmd.exe mklink /H which creates a native NTFS hard link.
# Usage: make_win_hardlink <source> <target>  (both as /mnt/c/... paths)
make_win_hardlink() {
    local src="$1" tgt="$2"

    # Convert /mnt/c/... to C:\...
    local win_src win_tgt
    win_src="$(echo "$src" | sed 's|^/mnt/\([a-z]\)/|\U\1:\\|; s|/|\\|g')"
    win_tgt="$(echo "$tgt" | sed 's|^/mnt/\([a-z]\)/|\U\1:\\|; s|/|\\|g')"

    # Already a working hard link (same inode)
    if [ -f "$tgt" ] && [ "$(stat -c %i "$src")" = "$(stat -c %i "$tgt")" ]; then
        ok "$tgt hard-linked to $src (already set)"
        return
    fi

    # Back up existing file/symlink
    if [ -e "$tgt" ] || [ -L "$tgt" ]; then
        local backup="${tgt}.bak.$(date +%Y%m%d%H%M%S)"
        warn "Backing up $tgt -> $backup"
        mv "$tgt" "$backup"
    fi

    cmd.exe /c "mklink /H \"$win_tgt\" \"$win_src\"" >/dev/null 2>&1
    ok "$tgt hard-linked to $src"
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
            make_win_hardlink "$DOTFILES_DIR/wezterm/.wezterm.lua" "$WIN_HOME/.wezterm.lua"
        else
            warn "Windows home not found at $WIN_HOME — skipping WezTerm"
        fi

        # Tmux config
        make_link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

        # Bash extensions
        ensure_sourced "$DOTFILES_DIR/bash/pane-tag.bash" "$HOME/.bashrc"
        ensure_sourced "$DOTFILES_DIR/bash/claude-pane.bash" "$HOME/.bashrc"

        # Claude Code hooks
        mkdir -p "$HOME/.claude/hooks"
        make_link "$DOTFILES_DIR/claude/hooks/prompt-to-pane.sh" "$HOME/.claude/hooks/prompt-to-pane.sh"
        make_link "$DOTFILES_DIR/claude/hooks/stop-clear-pane.sh" "$HOME/.claude/hooks/stop-clear-pane.sh"
        make_link "$DOTFILES_DIR/claude/hooks/statusline.sh" "$HOME/.claude/hooks/statusline.sh"
        ;;

    linux)
        # WezTerm config in Linux home
        make_link "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

        # Tmux config
        make_link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

        # Bash extensions
        ensure_sourced "$DOTFILES_DIR/bash/pane-tag.bash" "$HOME/.bashrc"
        ensure_sourced "$DOTFILES_DIR/bash/claude-pane.bash" "$HOME/.bashrc"

        # Claude Code hooks
        mkdir -p "$HOME/.claude/hooks"
        make_link "$DOTFILES_DIR/claude/hooks/prompt-to-pane.sh" "$HOME/.claude/hooks/prompt-to-pane.sh"
        make_link "$DOTFILES_DIR/claude/hooks/stop-clear-pane.sh" "$HOME/.claude/hooks/stop-clear-pane.sh"
        make_link "$DOTFILES_DIR/claude/hooks/statusline.sh" "$HOME/.claude/hooks/statusline.sh"
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
