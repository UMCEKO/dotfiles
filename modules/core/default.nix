{ inputs, ... }: {
  imports = [
    ./boot.nix
    ./docker.nix
    ./flatpak.nix
    ./fonts.nix
    ./network.nix
    ./hardware.nix
    ./nfs.nix
    ./nh.nix
    ./packages.nix
    ./printing.nix
    ./tui.nix # Display Manager
    ./security.nix
    ./services.nix
    ./steam.nix
    ./stylix.nix
    ./syncthing.nix
    ./system.nix
    ./thunar.nix
    ./user.nix
    ./xserver.nix
    ./virtualisation.nix
    inputs.stylix.nixosModules.stylix
  ];
}
