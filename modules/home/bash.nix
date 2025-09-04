{ profile, ... }: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      fastfetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';
    shellAliases = {
      nr = "sudo nixos-rebuild switch --flake $HOME/umcekonix";
      ncg =
        "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      v = "nvim";
    };
  };
}
