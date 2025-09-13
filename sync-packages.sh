#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACMAN_LIST="$SCRIPT_DIR/pacman-packages.txt"
AUR_LIST="$SCRIPT_DIR/aur-packages.txt"
PACMAN_IGNORE="$SCRIPT_DIR/.pacmanignore"
AUR_IGNORE="$SCRIPT_DIR/.aurignore"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Sync installed packages to package list files

OPTIONS:
    -f, --force      Force overwrite existing package lists
    -p, --preview    Show what would be synced without writing files
    -h, --help       Show this help message

This script will update pacman-packages.txt and aur-packages.txt with currently
installed packages, excluding those listed in .pacmanignore and .aurignore
EOF
}

create_ignore_files() {
  # Create .pacmanignore if it doesn't exist
  if [[ ! -f "$PACMAN_IGNORE" ]]; then
    echo -e "${BLUE}Creating .pacmanignore with common hardware/system specific packages${NC}"
    cat >"$PACMAN_IGNORE" <<'EOF'
# Hardware specific packages
nvidia*
amd-ucode
intel-ucode
mesa*
vulkan*
xf86-video*

# ASUS specific
asusctl
supergfxctl
rog-control-center

# System/distro specific  
endeavouros-*
eos-*
archlinux-keyring
archlinux-wallpaper*

# Kernel packages (user should choose)
linux*

# Drivers that may be hardware specific
broadcom-wl*
rtl*
r8168*

# Microcode (CPU specific)
*-ucode

# Font packages (too many variants)
ttf-*
noto-fonts*
adobe-source*

# Language packs
hunspell-*
libreoffice-*-help
EOF
  fi

  # Create .aurignore if it doesn't exist
  if [[ ! -f "$AUR_IGNORE" ]]; then
    echo -e "${BLUE}Creating .aurignore with common AUR packages to ignore${NC}"
    cat >"$AUR_IGNORE" <<'EOF'
# Hardware/brand specific
asusctl-git
supergfxctl-git
rog-control-center-git
g14-*
g15-*

# Distro specific
endeavouros-*
eos-*
garuda-*
manjaro-*

# Development versions that change frequently
*-git
*-bin
*-dev
*-nightly

# NVIDIA proprietary (hardware specific)
nvidia-*
optimus-*

# Personal/local packages
makepkg-*
aur-auto-vote*

# Font variants
ttf-*
otf-*
nerd-fonts*

# Theme variants (too subjective)
*-theme*
*-icons*
plymouth-*
EOF
  fi
}

get_installed_packages() {
  local ignore_file="$1"
  local package_list="$2"

  # Read ignore patterns
  local ignore_patterns=()
  if [[ -f "$ignore_file" ]]; then
    while IFS= read -r line; do
      # Skip empty lines and comments
      [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
      ignore_patterns+=("$line")
    done <"$ignore_file"
  fi

  # Filter packages
  local filtered_packages=()
  while IFS= read -r package; do
    local should_ignore=false

    # Check against ignore patterns
    for pattern in "${ignore_patterns[@]}"; do
      if [[ "$package" == $pattern ]]; then
        should_ignore=true
        break
      fi
    done

    [[ "$should_ignore" == "false" ]] && filtered_packages+=("$package")
  done <<<"$package_list"

  printf '%s\n' "${filtered_packages[@]}"
}

check_package_manager() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo -e "${RED}This script currently only supports Arch Linux (pacman)${NC}"
    exit 1
  fi
}

sync_packages() {
  local force="$1"
  local preview="$2"

  echo -e "${BLUE}Syncing package lists...${NC}"

  # Get explicitly installed packages (not dependencies)
  echo -e "${BLUE}Getting explicitly installed pacman packages...${NC}"
  local pacman_packages=$(pacman -Qeq | grep -v "$(pacman -Qmq)" | sort)
  local filtered_pacman=$(get_installed_packages "$PACMAN_IGNORE" "$pacman_packages")

  # Get AUR packages
  echo -e "${BLUE}Getting AUR packages...${NC}"
  local aur_packages=$(pacman -Qmq | sort)
  local filtered_aur=$(get_installed_packages "$AUR_IGNORE" "$aur_packages")

  if [[ "$preview" == "true" ]]; then
    echo -e "${YELLOW}PREVIEW MODE - No files will be written${NC}"
    echo
    echo -e "${BLUE}Pacman packages that would be synced:${NC}"
    echo "$filtered_pacman" | head -20
    [[ $(echo "$filtered_pacman" | wc -l) -gt 20 ]] && echo "... and $(($(echo "$filtered_pacman" | wc -l) - 20)) more"
    echo
    echo -e "${BLUE}AUR packages that would be synced:${NC}"
    echo "$filtered_aur" | head -20
    [[ $(echo "$filtered_aur" | wc -l) -gt 20 ]] && echo "... and $(($(echo "$filtered_aur" | wc -l) - 20)) more"
    return
  fi

  # Check if files exist and prompt if not force
  if [[ -f "$PACMAN_LIST" || -f "$AUR_LIST" ]] && [[ "$force" != "true" ]]; then
    echo -e "${YELLOW}Package list files already exist. Overwrite? (y/N)${NC}"
    read -r response
    [[ ! "$response" =~ ^[yY]([eE][sS])?$ ]] && {
      echo "Sync cancelled."
      exit 0
    }
  fi

  # Write package lists
  echo -e "${BLUE}Writing pacman packages to $PACMAN_LIST${NC}"
  {
    echo "# Official Arch packages - generated on $(date)"
    echo "# Run 'sudo pacman -S --needed \$(cat pacman-packages.txt)' to install"
    echo
    echo "$filtered_pacman"
  } >"$PACMAN_LIST"

  echo -e "${BLUE}Writing AUR packages to $AUR_LIST${NC}"
  {
    echo "# AUR packages - generated on $(date)"
    echo "# Run 'yay -S --needed \$(cat aur-packages.txt)' to install"
    echo
    echo "$filtered_aur"
  } >"$AUR_LIST"

  echo -e "${GREEN}Package sync complete!${NC}"
  echo -e "${BLUE}Pacman packages: $(echo "$filtered_pacman" | wc -l)${NC}"
  echo -e "${BLUE}AUR packages: $(echo "$filtered_aur" | wc -l)${NC}"
}

main() {
  local force=false
  local preview=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    -f | --force)
      force=true
      shift
      ;;
    -p | --preview)
      preview=true
      shift
      ;;
    -h | --help)
      show_usage
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      show_usage
      exit 1
      ;;
    esac
  done

  echo -e "${BLUE}Package List Sync${NC}"
  echo "=================="
  echo

  check_package_manager
  create_ignore_files
  sync_packages "$force" "$preview"
}

main "$@"
