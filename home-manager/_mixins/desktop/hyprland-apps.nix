{ pkgs, ... }: {
  imports = [
  ];

  programs = {
    waybar = {
      enable = true;
      package = pkgs.waybar;
    };
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      terminal = "wezterm";
      theme = "DarkBlue";
    };
  };

  home = {
    packages = with pkgs; [
      wezterm
      kitty
      dunst
      libnotify
    ];

    file.".wezterm.lua".text = ''
      local wezterm = require('wezterm')
      local action = wezterm.action

      local colors = {
        status_bg = '#101010',
        bg = '#101010',
        fg = '#d2c5bc',
        white = '#909090',
        yellow = '#f9bb80',
        red = '#d14548',
        light_red = '#b91e2e',
        dark_blue = '#265584',
        blue = '#356579',
        light_blue = '#0f829d',
      }
      -- Powerline dividers
      --local SOLID_RIGHT_ARROW = utf8.char(0xe0b0) -- The  symbol
      --local SOLID_LEFT_ARROW = utf8.char(0xe0b2) -- The  symbol

      -- Sets the title of the active tab in the current window.
      -- This method is intended to be called from the debug overlay repl
      function set_tab_title(title)
        -- The debug overlay defines a global `window` variable that is a Gui Window object; let's
        -- access it via the special `_G` lua table that always references the global variables
        local gui_window = _G.window
        -- "Convert" the gui window into a mux window
        local window = wezterm.mux.get_window(gui_window:window_id())
        -- Locate the active tab
        for _, tab_info in ipairs(window:tabs_with_info()) do
          if tab_info.is_active then
            -- Set the title and log something to indicate the changes that we made
            tab_info.tab:set_title(title)
            wezterm.log_info("Changed title for tab " .. tostring(tab_info.tab:tab_id()) .. " to " .. tab_info.tab:get_title())
            break
          end
        end
      end

      wezterm.on('update-right-status', function(window)
        local date = wezterm.strftime(' %Y/%m/%d %H:%M:%S ')
        local utc = wezterm.strftime_utc('[%H]')

        window:set_right_status(wezterm.format({
          { Background = { Color = colors.status_bg } },
          { Foreground = { Color = colors.dark_blue } },
          --{ Text = SOLID_LEFT_ARROW },
          { Text = "" },
          { Background = { Color = colors.dark_blue } },
          { Foreground = { Color = colors.yellow } },
          { Text = date },
          { Foreground = { Color = colors.light_red } },
          { Text = utc },
        }))
      end)

      wezterm.GLOBAL.tab_titles = {}
      wezterm.on('format-tab-title', function(tab, _, panes)
        local tab_id = tostring(tab.tab_id)

        if tab.is_active then
          for _, pane in ipairs(panes) do
            local pane_title = pane.title
            if pane_title:sub(1, 1) == '>' then
              local title = pane_title:sub(2)
              local current_titles = wezterm.GLOBAL.tab_titles
              current_titles[tab_id] = title
              wezterm.GLOBAL.tab_titles = current_titles
            end
          end
        end

        local title = wezterm.GLOBAL.tab_titles[tab_id] or tab.active_pane.title

        if tab.is_active then
          local style = {
            { Background = { Color = colors.dark_blue } },
            { Foreground = { Color = colors.yellow } },
            { Text = ' ' .. title .. ' ' },
            { Background = { Color = colors.status_bg } },
            { Foreground = { Color = colors.dark_blue } },
            --{ Text = SOLID_RIGHT_ARROW },
            { Text = "" },
          }
          if tab.tab_index ~= 0 then
            table.insert(style, 1, { Background = { Color = colors.dark_blue } })
            table.insert(style, 2, { Foreground = { Color = colors.status_bg } })
            --table.insert(style, 3, { Text = SOLID_RIGHT_ARROW })
            table.insert(style, 3, { Text = "" })
          end
          return style
        end

        return '  ' .. title .. '  '
      end)

      -- lighten up background
      --local gb_dark = wezterm.get_builtin_color_schemes()['Gruvbox Dark']
      --gb_dark.background = colors.bg

      return {
        -- look
        --color_schemes = {
          --['Gruvbox Dark'] = gb_dark,
        --},
        color_scheme = 'ayu',
        font = wezterm.font('JetBrains Mono'),
        font_size = 18,
        cursor_blink_rate = 0,
        colors = {
          background = colors.bg,
          tab_bar = {
            background = colors.status_bg,
            active_tab = { bg_color = colors.blue, fg_color = colors.white, intensity = 'Bold' },
            inactive_tab = { bg_color = colors.status_bg, fg_color = colors.white },
            inactive_tab_hover = { bg_color = colors.status_bg, fg_color = colors.white },
          },
        },
        tab_bar_style = {
          new_tab = "",
          new_tab_hover = 'new tab',
        },

        -- window
        --window_decorations = 'RESIZE',
        enable_tab_bar = true,
        use_fancy_tab_bar = false,
        enable_scroll_bar = false,
        window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
        tab_bar_at_bottom = false,

        -- behavior
        -- mux
        default_gui_startup_args = { 'connect', 'unix' },
        unix_domains = {
          {
            name = 'unix',
          },
        },
        -- tmux bindings
        leader = { key = 'b', mods = 'SUPER' },
        keys = {
          { key = ':', mods = 'LEADER', action = 'ShowLauncher' },
          {
            key = '-',
            mods = 'LEADER',
            action = action({ SplitVertical = { domain = 'CurrentPaneDomain' } }),
          },
          {
            key = '|',
            mods = 'LEADER',
            action = action({ SplitHorizontal = { domain = 'CurrentPaneDomain' } }),
          },
          {
            key = 'h',
            mods = 'LEADER',
            action = action({ ActivatePaneDirection = 'Left' }),
          },
          {
            key = 'j',
            mods = 'LEADER',
            action = action({ ActivatePaneDirection = 'Down' }),
          },
          {
            key = 'k',
            mods = 'LEADER',
            action = action({ ActivatePaneDirection = 'Up' }),
          },
          {
            key = 'l',
            mods = 'LEADER',
            action = action({ ActivatePaneDirection = 'Right' }),
          },
          { key = 'H', mods = 'LEADER', action = action({ AdjustPaneSize = { 'Left', 5 } }) },
          { key = 'J', mods = 'LEADER', action = action({ AdjustPaneSize = { 'Down', 5 } }) },
          { key = 'K', mods = 'LEADER', action = action({ AdjustPaneSize = { 'Up', 5 } }) },
          { key = 'L', mods = 'LEADER', action = action({ AdjustPaneSize = { 'Right', 5 } }) },

          { key = 'n', mods = 'LEADER', action = action({ ActivateTabRelative = 1 }) },
          { key = 'p', mods = 'LEADER', action = action({ ActivateTabRelative = -1 }) },
          {
            key = 'c',
            mods = 'LEADER',
            action = action({ SpawnTab = 'CurrentPaneDomain' }),
          },
          {
            key = 'x',
            mods = 'LEADER',
            action = action({ CloseCurrentPane = { confirm = true } }),
          },
          { key = 'z', mods = 'LEADER', action = 'TogglePaneZoomState' },
          { key = '[', mods = 'LEADER', action = 'ActivateCopyMode' },
          { key = '{', mods = 'LEADER', action = action({ RotatePanes = 'Clockwise' }) },
          { key = '}', mods = 'LEADER', action = action({ RotatePanes = 'CounterClockwise' }) },
        },
      }
    '';
  };
}