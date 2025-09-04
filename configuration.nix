{ inputs, config, pkgs, ... }: {
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "vivobook"; # Define your hostname
    networkmanager.enable = true;
  };

  # Set your time zone
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  # Configure services
  services = {
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };
    power-profiles-daemon = { enable = true; };
    flatpak = { enable = true; };
    # Enable automatic login for the user
    getty.autologinUser = "umceko";
  };

  programs = {
    hyprland = {
      enable = true;
      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      xwayland = { enable = true; };
    };
    bash = { completion = { enable = true; }; };
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libva
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    bluetooth = { enable = true; };
  };

  # Define a user account. Don't forget to set a password with 'passwd'
  users.users.umceko = {
    isNormalUser = true;
    description = "Umut Cevdet Kocak";
    extraGroups =
      [ "networkmanager" "wheel" "video" "render" "input" "docker" ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  virtualisation = { docker = { enable = true; }; };

  # System packages
  environment = {
    systemPackages = with pkgs; [
      # Core GNU/Unix
      coreutils
      findutils
      gawk
      diffutils
      less
      which
      file
      procps
      psmisc # ps, top, killall, fuser, pstree
      util-linux # mount, dmesg, etc.
      iproute2
      inetutils
      nettools # ip, ping/hostname, ifconfig/netstat
      ethtool
      rsync
      tree
      pv
      jq
      yq
      tldr
      eza
      duf
      fastfetch
      btop
      htop
      glances
      dmidecode
      hwinfo
      lsscsi
      hdparm
      smartmontools
      sg3_utils
      inotify-tools
      usbutils
      pciutils
      rlwrap # handy shell wrapper
      ripgrep

      # Filesystems & storage
      btrfs-progs
      e2fsprogs
      xfsprogs
      jfsutils
      f2fs-tools
      nilfs-utils
      exfatprogs
      ntfs3g
      dosfstools
      mtools
      cryptsetup
      lvm2
      mdadm
      dmraid
      efibootmgr

      # Networking & security
      nmap
      whois
      iptables
      bind # for dig, nslookup
      dnsmasq
      openssh # client

      # Dev & build toolchains
      git
      gh
      git-filter-repo
      gcc
      gnumake
      cmake
      pkg-config
      go
      rustup
      cargo
      rustc
      nodejs
      python3
      python3Packages.pip
      just
      buf
      protobuf
      helm
      kubectl
      docker-compose
      neovim

      # Wayland/Hypr/CLI helpers
      wlr-randr
      cliphist
      brightnessctl
      playerctl
      wl-clipboard
      grim
      slurp
      swappy
      waypipe

      # Android tools
      android-tools # adb/fastboot

      # Applications
      firefox
      kitty
    ];

    sessionVariables = {
      EDITOR = "nvim";
      NIXOS_OZONE_WL = "1";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig = { enable = true; };
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];
  };

  system.stateVersion = "25.05";
}
