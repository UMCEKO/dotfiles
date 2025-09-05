{ config, lib, ... }:
let
  hyprlandConfigDir = ".config/hypr";
  monitorsDir = "${hyprlandConfigDir}/monitors";
  configs = [
    "default.conf"
    "laptop-only.conf"
    "dual-only.conf"
    "dual-only-reversed.conf"
  ];
in {
  # Create all the monitor config files as symlinks to Nix store
  home.file = builtins.listToAttrs (map (fileName: {
    name = "${monitorsDir}/${fileName}";
    value = { source = ./${fileName}; };
  }) configs);

  # Create monitor.conf as a symlink to current.conf (this was missing!)
  xdg.configFile."hypr/monitor.conf".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/${monitorsDir}/current.conf";

  # Ensure current.conf exists and points to default.conf initially
  home.activation.ensureHyprMonitorCurrent =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -eu
      confdir="$HOME/${hyprlandConfigDir}"
      mondir="$confdir/monitors"
      currentfile="$mondir/current.conf"
      mkdir -p "$mondir"
      # Create current.conf -> default.conf if missing
      if [ ! -e "$currentfile" ]; then
        ln -sfn "$mondir/default.conf" "$currentfile"
      fi
    '';
}
