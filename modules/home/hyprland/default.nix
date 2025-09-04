{ variables, ... }: {
  imports = [
    variables.animChoice
    ./env.nix
    ./exec-once.nix
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./keybinds.nix
    ./pyprland.nix
    ./windowrules.nix
  ];
}
