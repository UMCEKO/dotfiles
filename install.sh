#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Action modes
BACKUP_MODE=0
DELETE_MODE=1
SKIP_MODE=2
DEFAULT_ACTION=$BACKUP_MODE
SILENT_MODE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Install dotfiles by creating symlinks to ~/.config

OPTIONS:
    -b, --backup     Default to backup mode (default)
    -d, --delete     Default to delete mode
    -s, --skip       Default to skip mode
    -h, --help       Show this help message

MODES:
    backup [0]  - Backup existing configs with timestamp suffix
    delete [1]  - Delete existing configs without backup  
    skip [2]    - Skip conflicting configs, only link new ones
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -b | --backup)
      DEFAULT_ACTION=$BACKUP_MODE
      SILENT_MODE=true
      shift
      ;;
    -d | --delete)
      DEFAULT_ACTION=$DELETE_MODE
      SILENT_MODE=true
      shift
      ;;
    -s | --skip)
      DEFAULT_ACTION=$SKIP_MODE
      SILENT_MODE=true
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
}

should_process() {
  case "$1" in
  "README.md" | "install.sh" | "safe-dotfiles-install.sh" | "*.txt" | ".*" | "aur-packages.txt" | "pacman-packages.txt") return 1 ;;
  *) return 0 ;;
  esac
}

ask_user_action() {
  [[ "$SILENT_MODE" == "true" ]] && return $DEFAULT_ACTION

  echo -e "${YELLOW}Conflict found: $1 already exists${NC}"
  echo "What would you like to do?"
  echo "  [0] Backup existing file (default)"
  echo "  [1] Delete existing file"
  echo "  [2] Skip this file"
  echo -n "Choice [0]: "

  read -r response
  case "$response" in
  1) return $DELETE_MODE ;;
  2) return $SKIP_MODE ;;
  *) return $BACKUP_MODE ;;
  esac
}

handle_conflict() {
  local target="$CONFIG_DIR/$1"

  ask_user_action "$1"
  case $? in
  $DELETE_MODE)
    echo -e "${RED}Deleting existing: $1${NC}"
    rm -rf "$target"
    return 0
    ;;
  $SKIP_MODE)
    echo -e "${YELLOW}Skipping: $1${NC}"
    return 1
    ;;
  $BACKUP_MODE)
    local backup_name="$1.bak.$(date +%Y%m%d-%H%M%S)"
    echo -e "${BLUE}Backing up: $1 -> $backup_name${NC}"
    mv "$target" "$CONFIG_DIR/$backup_name"
    return 0
    ;;
  esac
}

create_symlink() {
  echo -e "${GREEN}Creating symlink: $1${NC}"
  ln -sf "$SCRIPT_DIR/config/$1" "$CONFIG_DIR/$1"
}

install_dotfiles() {
  [[ ! -d "$SCRIPT_DIR/config" ]] && {
    echo -e "${RED}Error: config directory not found: $SCRIPT_DIR/config${NC}"
    exit 1
  }

  cd "$SCRIPT_DIR/config"

  for item in *; do
    should_process "$item" || continue

    local target="$CONFIG_DIR/$item"
    echo -e "${BLUE}Processing: $item${NC}"

    if [[ -e "$target" && ! -L "$target" ]]; then
      handle_conflict "$item" || continue
    elif [[ -L "$target" ]]; then
      echo -e "${BLUE}Removing existing symlink: $item${NC}"
      rm "$target"
    fi

    create_symlink "$item"
    echo
  done
}

preview_changes() {
  echo -e "${BLUE}Preview of changes:${NC}"
  echo

  cd "$SCRIPT_DIR/config"
  for item in *; do
    should_process "$item" || continue

    local target="$CONFIG_DIR/$item"
    local status

    if [[ -L "$target" ]]; then
      status="${BLUE}[SYMLINK REPLACE]${NC}"
    elif [[ -e "$target" ]]; then
      status="${YELLOW}[CONFLICT]${NC}"
    else
      status="${GREEN}[NEW]${NC}"
    fi

    echo -e "$status $item"
  done
  echo
}

main() {
  parse_args "$@"

  echo -e "${BLUE}Dotfiles Installer${NC}"
  echo "=================="
  echo

  if [[ "$SILENT_MODE" == "false" ]]; then
    preview_changes
    echo -e "${YELLOW}This will create symlinks from dotfiles/config to ~/.config${NC}"
    echo -e "${YELLOW}Continue? (y/N)${NC}"
    read -r response
    [[ "$response" =~ ^[yY]([eE][sS])?$ ]] || {
      echo "Installation cancelled."
      exit 0
    }
  fi

  install_dotfiles
  echo -e "${GREEN}Installation complete!${NC}"
  [[ $DEFAULT_ACTION -eq $BACKUP_MODE ]] && echo -e "${BLUE}Backed up files are saved with .bak.[timestamp] extensions${NC}"
}

main "$@"
