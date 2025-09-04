{ host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix)
    alacrittyEnable ghosttyEnable tmuxEnable waybarChoice weztermEnable
    vscodeEnable helixEnable doomEmacsEnable;
in {
  imports = [
    ./fastfetch
    ./hyprland
    ./waybar
    ./btop.nix
    ./bash.nix
    ./bashrc.nix
    ./gh.nix
    ./tmux.nix
  ];
}
