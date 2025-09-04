{ pkgs, ... }: {
  # Only enable either docker or podman -- Not both
  virtualisation = {
    libvirtd = { enable = true; };

    virtualbox.host = {
      enable = false;
      enableExtensionPack = true;
    };
  };

  programs = { virt-manager.enable = false; };

  environment.systemPackages = with pkgs;
    [
      virt-viewer # View Virtual Machines
    ];
}
