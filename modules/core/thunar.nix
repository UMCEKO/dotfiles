{ variables, pkgs, ... }: {
  programs = {
    thunar = {
      enable = (variables.fileManager == "thunar");
      plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };
  };
  environment.systemPackages = with pkgs;
    [
      ffmpegthumbnailer # Need For Video / Image Preview
    ];
}
