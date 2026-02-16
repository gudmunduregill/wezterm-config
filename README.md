# dotfiles

Personal configuration files for WezTerm, tmux, bash, and Claude Code.

## Contents

| Path | Description |
|------|-------------|
| `wezterm/.wezterm.lua` | WezTerm terminal config (Catppuccin Mocha, Inconsolata NF) |
| `tmux/.tmux.conf` | tmux config (vi mode, vim-tmux-navigator, pane labels) |
| `bash/pane-tag.bash` | `tp` function -- tag tmux panes with name and color |
| `claude/commands/*.md` | Claude Code slash commands (init-project, retro) |
| `install.sh` | Cross-platform symlink installer |

## Installation

```sh
git clone https://github.com/gudmunduregill/dotfiles.git
cd dotfiles
./install.sh
```

The installer detects your environment (WSL, native Linux, or Windows/MSYS) and creates the appropriate symlinks. Existing files are backed up with a `.bak.*` suffix before being replaced.

## Claude Code commands

Custom slash commands for Claude Code, installed as symlinks into `~/.claude/commands/`.

| Command | Description |
|---------|-------------|
| `/init-project` | Bootstrap a claude-first project with domain analysis and agentic workflow design |
| `/retro` | Analyze a completed implementation to identify AI tooling improvements |

Install:

```sh
./claude/install.sh
```

The script auto-discovers all `.md` files in `claude/commands/`, so adding new commands only requires dropping a file in that directory.

## Pane tagging

The `tp` function lets you label and color-code tmux panes:

```sh
tp "api-server" blue
tp "logs" red
```

Available colors: red, green, blue, yellow, magenta, cyan, orange, pink -- or pass any raw tmux colour.
