{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "UMCEKO";
  gitEmail = "umutcevdetkocak@gmail.com";

  # Set Displau Manager
  # `tui` for Text login
  # `sddm` for graphical GUI (default)
  # SDDM background is set with stylixImage
  displayManager = "tui";

  # Emable/disable bundled applications
  tmuxEnable = true;

  # Waybar Settings
  clock24h = false;

  # Program Options
  # Set Default Browser (google-chrome-stable for google-chrome)
  # This does NOT install your browser
  # You need to install it by adding it to the `packages.nix`
  # or as a flatpak
  browser = "brave";

  # Available Options:
  # Kitty, ghostty, wezterm, aalacrity
  # Note: kitty, wezterm, alacritty have to be enabled in `variables.nix`
  # Setting it here does not enable it. Kitty is installed by default
  terminal = "kitty"; # Set Default System Terminal

  keyboardLayout = "us";
  consoleKeyMap = "us";

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = false;

  # Themes, waybar and animation.
  #  Only uncomment your selection
  # The others much be commented out.

  # Set Stylix Image
  # This will set your color palette
  # Default background
  # Add new images to /wallpapers
  stylixImage = ../../wallpapers/mountainscapedark.jpg;

  # Set Waybar
  waybarChoice = ../../modules/home/waybar/default.nix;

  # Set Animation style
  animChoice = ../../modules/home/hyprland/animations/def.nix;

  # Set network hostId if required (needed for zfs)
  # Otherwise leave as-is
  hostId = "5ab03f50";
}
