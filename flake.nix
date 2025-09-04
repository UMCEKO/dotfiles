{
  description = "UMCEKO Os";

  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-25.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
  };

  outputs = { nixpkgs, nix-flatpak, ... }@inputs:
    let
      system = "x86_64-linux";
      host = "vivobook";
      username = "umceko";
      variables = import ./hosts/${host}/variables.nix;

      mkNixosConfig = gpuProfile:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username host variables;
            # expose the selected profile to modules
            profile = gpuProfile;
          };
          modules = [
            # point to the actual file:
            ./profiles/${gpuProfile}.nix

            # point to the host dir that *has* default.nix:
            ./hosts/${host}

            # modules/ has default.nix (per your tree)
            ./modules

            nix-flatpak.nixosModules.nix-flatpak
          ];
        };
    in {
      nixosConfigurations = {
        amd = mkNixosConfig "amd";
        intel = mkNixosConfig "intel";
        nvidia = mkNixosConfig "nvidia";
        nvidia-laptop = mkNixosConfig "nvidia-laptop";
      };
    };
}
