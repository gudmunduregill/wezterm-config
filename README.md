# dotfiles

Personal configuration files for WezTerm, tmux, and bash.

## Contents

| Path | Description |
|------|-------------|
| `wezterm/.wezterm.lua` | WezTerm terminal config (Catppuccin Mocha, Inconsolata NF) |
| `tmux/.tmux.conf` | tmux config (vi mode, vim-tmux-navigator, pane labels) |
| `bash/pane-tag.bash` | `tp` function -- tag tmux panes with name and color |
| `install.sh` | Cross-platform symlink installer |

## Installation

```sh
git clone https://github.com/gudmunduregill/dotfiles.git
cd dotfiles
./install.sh
```

The installer detects your environment (WSL, native Linux, or Windows/MSYS) and creates the appropriate symlinks. Existing files are backed up with a `.bak.*` suffix before being replaced.

## Pane tagging

The `tp` function lets you label and color-code tmux panes:

```sh
tp "api-server" blue
tp "logs" red
```

Available colors: red, green, blue, yellow, magenta, cyan, orange, pink -- or pass any raw tmux colour.
