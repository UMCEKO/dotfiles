{ pkgs, ... }: {
  # Only enable either docker or podman -- Not both
  virtualisation = {
    docker = { enable = true; };
    podman.enable = false;
  };

  environment.systemPackages = with pkgs; [ lazydocker docker-client ];
}
