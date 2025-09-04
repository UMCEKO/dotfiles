{ pkgs, ... }: {
  home.packages = with pkgs; [ bash ];

  home.file."./.bashrc".text = ''
    #!/usr/bin/env bash

    export EDITOR="nvim"
    export VISUAL="nvim"
  '';
}
