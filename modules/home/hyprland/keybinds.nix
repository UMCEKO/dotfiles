{ variables, config, ... }: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
      source = ${config.home.homeDirectory}/.config/hypr/ssw.conf
      source = ${config.home.homeDirectory}/.config/hypr/monitor.conf
    '';
    settings = {
      # ---------------------
      # Key bindings (bind)
      # ---------------------
      bind = [
        # Applications
        "$modifier, RETURN, exec, ${variables.terminal}"
        "$modifier, B, exec, ${variables.browser}"
        "$modifier, E, exec, ${variables.fileManager}"
        "$modifier CTRL, E, exec, emopicker9000"

        # Windows
        "$modifier, Q, killactive"
        "$modifier SHIFT, Q, exec, hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill"
        "$modifier, F, fullscreen, 0"
        "$modifier, M, fullscreen, 1"
        "$modifier, D, togglefloating"
        "$modifier SHIFT, T, workspaceopt, allfloat"
        "$modifier, J, togglesplit"
        "$modifier, left,  movefocus, l"
        "$modifier, right, movefocus, r"
        "$modifier, up,    movefocus, u"
        "$modifier, down,  movefocus, d"
        "$modifier Shift, Left,  movewindow, l"
        "$modifier Shift, Right, movewindow, r"
        "$modifier Shift, Up,    movewindow, u"
        "$modifier Shift, Down,  movewindow, d"
        "$modifier, G, togglegroup"
        "$modifier, K, swapsplit"
        "$modifier ALT, left,  swapwindow, l"
        "$modifier ALT, right, swapwindow, r"
        "$modifier ALT, up,    swapwindow, u"
        "$modifier ALT, down,  swapwindow, d"

        # Actions
        "$modifier CTRL, R, exec, hyprctl reload"
        "$modifier, PRINT, exec, grimblast --notify copy area"
        "$modifier SHIFT, S, exec, grimblast --notify copy area"
        "$modifier CTRL, Q, exec, wlogout"
        "$modifier SHIFT, W, exec, waypaper --random"
        "$modifier CTRL, W, exec, waypaper"
        "$modifier, space, exec, pkill rofi || rofi -show drun -replace -i"
        "$modifier SHIFT, B, exec, ~/.config/waybar/launch.sh"
        "$modifier CTRL, B, exec, ~/.config/waybar/toggle.sh"
        "$modifier, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$modifier CTRL, T, exec, ~/.config/waybar/themeswitcher.sh"
        "$modifier CTRL, S, exec, flatpak run com.ml4w.settings"
        "$modifier CTRL, L, exec, ~/.config/hypr/scripts/power.sh lock"
        "$modifier, P, exec, switch-monitors"
        ", XF86Display, exec, switch-monitors"

        # Workspaces (switch)
        "$modifier, 1, exec, smart-switch-workspace workspace 1"
        "$modifier, 2, exec, smart-switch-workspace workspace 2"
        "$modifier, 3, exec, smart-switch-workspace workspace 3"
        "$modifier, 4, exec, smart-switch-workspace workspace 4"
        "$modifier, 5, exec, smart-switch-workspace workspace 5"
        "$modifier, 6, exec, smart-switch-workspace workspace 6"
        "$modifier, 7, exec, smart-switch-workspace workspace 7"
        "$modifier, 8, exec, smart-switch-workspace workspace 8"
        "$modifier, 9, exec, smart-switch-workspace workspace 9"
        "$modifier, 0, exec, smart-switch-workspace workspace 10"

        # Workspaces (move focused window)
        "$modifier SHIFT, 1, exec, smart-switch-workspace movetoworkspace 1"
        "$modifier SHIFT, 2, exec, smart-switch-workspace movetoworkspace 2"
        "$modifier SHIFT, 3, exec, smart-switch-workspace movetoworkspace 3"
        "$modifier SHIFT, 4, exec, smart-switch-workspace movetoworkspace 4"
        "$modifier SHIFT, 5, exec, smart-switch-workspace movetoworkspace 5"
        "$modifier SHIFT, 6, exec, smart-switch-workspace movetoworkspace 6"
        "$modifier SHIFT, 7, exec, smart-switch-workspace movetoworkspace 7"
        "$modifier SHIFT, 8, exec, smart-switch-workspace movetoworkspace 8"
        "$modifier SHIFT, 9, exec, smart-switch-workspace movetoworkspace 9"
        "$modifier SHIFT, 0, exec, smart-switch-workspace movetoworkspace 10"

        # Fn keys (brightness/audio/misc)
        ", XF86MonBrightnessUp,   exec, brightnessctl -q s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl -q s 5%-"
        ", XF86AudioMute,     exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioPlay,     exec, playerctl play-pause"
        ", XF86AudioPause,    exec, playerctl pause"
        ", XF86AudioNext,     exec, playerctl next"
        ", XF86AudioPrev,     exec, playerctl previous"
        ", XF86AudioMicMute,  exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
        ", XF86Calculator,    exec, ~/.config/ml4w/settings/calculator.sh"
        ", XF86Lock,          exec, hyprlock"
        ", XF86Tools,         exec, flatpak run com.ml4w.settings"

        # Keyboard backlight (Apple-style kbd as example)
        ", code:238, exec, brightnessctl -d smc::kbd_backlight s +10"
        ", code:237, exec, brightnessctl -d smc::kbd_backlight s 10-"
      ];

      # ---------------------
      # Mouse binds
      # ---------------------
      bindm = [
        "$modifier, mouse:272, movewindow"
        "$modifier, mouse:273, resizewindow"
      ];

      # ---------------------
      # Special bind variants
      # ---------------------
      # Raw keycode launcher (use plain 'bind' if your Hypr doesn't support 'bindi')
      bindi = [ ", code:201, exec, pkill rofi || rofi -show drun -replace -i" ];

      # Locked + repeat on hold (supported by Hyprland ≥0.37)
      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      ];
    };
  };
}
