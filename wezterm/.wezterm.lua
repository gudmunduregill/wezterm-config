local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Default to WSL
config.default_domain = 'WSL:Ubuntu-24.04'

-- Catppuccin Mocha theme
config.color_scheme = 'Catppuccin Mocha'

-- Font
config.font = wezterm.font('Inconsolata Nerd Font', { weight = 'Regular' })
config.font_size = 12.0

-- Window appearance
if wezterm.hostname() == 'Hemingway' then
  config.window_background_opacity = 1.0
else
  config.window_background_opacity = 0.95
end
config.window_padding = {
  left = 12,
  right = 12,
  top = 12,
  bottom = 8,
}
config.window_decorations = 'RESIZE'

-- Tab bar at bottom with smaller font
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 24
config.window_frame = {
  font = wezterm.font('Inconsolata Nerd Font', { weight = 'Medium' }),
  font_size = 9.0,
  active_titlebar_bg = '#11111b',
  inactive_titlebar_bg = '#11111b',
}

-- Truncate long tab titles with ellipsis
wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local title = tab.active_pane.title
  if #title > max_width - 2 then
    title = title:sub(1, max_width - 3) .. '\u{2026}'
  end
  return title
end)

config.colors = {
  tab_bar = {
    background = '#11111b',
    active_tab = {
      bg_color = '#cba6f7',
      fg_color = '#11111b',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#1e1e2e',
      fg_color = '#6c7086',
    },
    inactive_tab_hover = {
      bg_color = '#313244',
      fg_color = '#cdd6f4',
    },
    new_tab = {
      bg_color = '#1e1e2e',
      fg_color = '#6c7086',
    },
    new_tab_hover = {
      bg_color = '#313244',
      fg_color = '#cdd6f4',
    },
  },
}

-- Fancy tab bar button styling (Catppuccin Mocha colors)
config.tab_bar_style = {
  new_tab = wezterm.format {
    { Background = { Color = '#1e1e2e' } },
    { Foreground = { Color = '#6c7086' } },
    { Text = ' + ' },
  },
  new_tab_hover = wezterm.format {
    { Background = { Color = '#313244' } },
    { Foreground = { Color = '#cdd6f4' } },
    { Text = ' + ' },
  },
}

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

-- Keybindings for borderless window management
config.keys = {
  { key = 'q', mods = 'CTRL|SHIFT', action = wezterm.action.QuitApplication },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = false } },
}

-- Alt + drag to move window (since no title bar)
config.mouse_bindings = {
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'ALT',
    action = wezterm.action.StartWindowDrag,
  },
}

-- Disable annoying close prompt
config.window_close_confirmation = 'NeverPrompt'

return config
