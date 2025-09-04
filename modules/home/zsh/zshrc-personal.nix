
{ pkgs, ... }: {
  home.packages = with pkgs; [ zsh ];

  home.file."./.zshrc-personal".text = ''
    #!/usr/bin/env zsh
    export EDITOR="nvim"
    export VISUAL="nvim"
  '';
}

