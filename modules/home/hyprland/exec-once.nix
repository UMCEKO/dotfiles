{ variables, ... }: {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "wl-paste --type text --watch cliphist store" # Saves text
      "wl-paste --type image --watch cliphist store" # Saves images
      ''
        dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      ''
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user start hyprpolkitagent"

      "smart-switch-workspace workspace 1" # we do this to generate initial config

      "killall -q swww;sleep .5 && swww-daemon"
      "killall -q waybar;sleep .5 && waybar"
      "killall -q swaync;sleep .5 && swaync"
      "#wallsetter &"
      "pypr &"
      "nm-applet --indicator"
      "sleep 1.0 && swww img ${variables.stylixImage}"
    ];
  };
}
