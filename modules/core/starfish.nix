{ ... }: {
  programs = {
    starship = {
      enable = false;
      settings = {
        add_newline = false;
        buf = { symbol = " "; };
        c = { symbol = " "; };
        directory = { read_only = " 󰌾"; };
        docker_context = { symbol = " "; };
        fossil_branch = { symbol = " "; };
        git_branch = { symbol = " "; };
        golang = { symbol = " "; };
        hg_branch = { symbol = " "; };
        hostname = { ssh_symbol = " "; };
        lua = { symbol = " "; };
        memory_usage = { symbol = "󰍛 "; };
        meson = { symbol = "󰔷 "; };
        nim = { symbol = "󰆥 "; };
        nix_shell = { symbol = " "; };
        nodejs = { symbol = " "; };
        ocaml = { symbol = " "; };
        package = { symbol = "󰏗 "; };
        python = { symbol = " "; };
        rust = { symbol = " "; };
        swift = { symbol = " "; };
        zig = { symbol = " "; };
      };
    };
  };
}
