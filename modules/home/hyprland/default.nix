{ host, ... }:
let inherit (../../../hosts/${host}/variables.nix) animChoice;
in { imports = [ animChoice ./hyprland.nix ]; }
