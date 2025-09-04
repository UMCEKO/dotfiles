{ variables, ... }: {
  services = {
    printing = {
      enable = variables.printEnable;
      drivers = [
        # pkgs.hplipWithPlugin
      ];
    };
    avahi = {
      enable = variables.printEnable;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = variables.printEnable;
  };
}
