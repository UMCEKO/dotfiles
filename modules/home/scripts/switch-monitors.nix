{ pkgs }:

pkgs.writeShellScriptBin "switch-monitors" ''
  set -euo pipefail

  # Configuration
  PROFILES_DIR="$HOME/.config/hypr/monitors"
  CURRENT_LINK="$PROFILES_DIR/current.conf"
  STATE_FILE="$HOME/.cache/hypr_monitor_profile"

  # Colors
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'

  print_msg() {
      local color=$1
      local message=$2
      echo -e "''${color}''${message}''${NC}"
  }

  usage() {
      cat << EOF
  Usage: $(basename "$0") [OPTIONS] [PROFILE]

  Options:
    -h, --help        Show this help message
    -l, --list        List available monitor profiles
    -c, --current     Show current active profile
    -s, --set PROFILE Set specific profile (with or without .conf)
    --no-reload       Don't reload Hyprland after switching

  Examples:
    $(basename "$0")                    # Rotate to next profile
    $(basename "$0") --set laptop-only  # Switch to specific profile
    $(basename "$0") --list            # Show all profiles
  EOF
  }

  # Get profiles including both symlinks and regular files
  get_profiles() {
      if [[ ! -d "$PROFILES_DIR" ]]; then
          return 1
      fi
      
      # Use find with both -type f and -type l, but exclude current.conf
      find "$PROFILES_DIR" -maxdepth 1 \( -type f -o -type l \) -name '*.conf' ! -name 'current.conf' -printf '%f\n' | sort
  }

  list_profiles() {
      local profiles current_profile
      
      if ! profiles=($(get_profiles)); then
          print_msg "$RED" "Error: Profiles directory does not exist: $PROFILES_DIR"
          return 1
      fi
      
      if [[ ''${#profiles[@]} -eq 0 ]]; then
          print_msg "$YELLOW" "No monitor profiles found in $PROFILES_DIR"
          print_msg "$YELLOW" "Expected *.conf files (can be symlinks or regular files)"
          return 1
      fi
      
      current_profile=$(get_current_profile_name)
      
      print_msg "$BLUE" "Available monitor profiles:"
      for profile in "''${profiles[@]}"; do
          if [[ "$profile" == "$current_profile" ]]; then
              echo "  * $profile (active)"
          else
              echo "    $profile"
          fi
      done
  }

  get_current_profile_name() {
      if [[ -L "$CURRENT_LINK" ]]; then
          local target
          target=$(readlink "$CURRENT_LINK")
          basename "$target"
      else
          echo "none"
      fi
  }

  show_current() {
      local current
      current=$(get_current_profile_name)
      if [[ "$current" == "none" ]]; then
          print_msg "$YELLOW" "No active monitor profile (current.conf missing)"
      else
          print_msg "$GREEN" "Current active profile: $current"
      fi
  }

  ensure_directories() {
      mkdir -p "$PROFILES_DIR"
      mkdir -p "$(dirname "$STATE_FILE")"
  }

  reload_hyprland() {
      if command -v hyprctl >/dev/null 2>&1; then
          print_msg "$BLUE" "Reloading Hyprland configuration..."
          if hyprctl reload 2>/dev/null; then
              print_msg "$GREEN" "Hyprland configuration reloaded"
          else
              print_msg "$YELLOW" "Warning: hyprctl reload failed"
          fi
      else
          print_msg "$YELLOW" "hyprctl not found - please reload Hyprland manually"
      fi
  }

  get_current_index() {
      local profiles=("$@")
      local current_profile
      current_profile=$(get_current_profile_name)
      
      # If no current profile, check state file
      if [[ "$current_profile" == "none" ]]; then
          if [[ -f "$STATE_FILE" ]]; then
              local saved_index
              saved_index=$(cat "$STATE_FILE" 2>/dev/null || echo "-1")
              echo "$saved_index"
          else
              echo "-1"
          fi
          return
      fi
      
      # Find index of current profile
      for i in "''${!profiles[@]}"; do
          if [[ "''${profiles[i]}" == "$current_profile" ]]; then
              echo "$i"
              return
          fi
      done
      
      # Current profile not found in available profiles, return -1
      echo "-1"
  }

  ensure_current_exists() {
      local profiles=("$@")
      
      if [[ ! -e "$CURRENT_LINK" && ''${#profiles[@]} -gt 0 ]]; then
          # Look for default.conf first
          for profile in "''${profiles[@]}"; do
              if [[ "$profile" == "default.conf" ]]; then
                  print_msg "$YELLOW" "Creating current.conf -> default.conf"
                  ln -sfn "$PROFILES_DIR/default.conf" "$CURRENT_LINK"
                  return
              fi
          done
          
          # No default.conf, use first available
          print_msg "$YELLOW" "Creating current.conf -> ''${profiles[0]}"
          ln -sfn "$PROFILES_DIR/''${profiles[0]}" "$CURRENT_LINK"
      fi
  }

  switch_to_profile() {
      local target_profile="$1"
      local reload_after="$2"
      
      # Add .conf if not present
      if [[ "$target_profile" != *.conf ]]; then
          target_profile="''${target_profile}.conf"
      fi
      
      local target_path="$PROFILES_DIR/$target_profile"
      
      if [[ ! -e "$target_path" ]]; then
          print_msg "$RED" "Error: Profile '$target_profile' not found in $PROFILES_DIR"
          return 1
      fi
      
      # Atomically switch
      ln -sfn "$target_path" "$CURRENT_LINK"
      
      print_msg "$GREEN" "Switched to monitor profile: $target_profile"
      
      if [[ "$reload_after" == "true" ]]; then
          reload_hyprland
      fi
  }

  rotate_profile() {
      local reload_after="$1"
      local profiles current_index next_index
      
      ensure_directories
      
      if ! profiles=($(get_profiles)); then
          print_msg "$RED" "Error: Cannot access profiles directory: $PROFILES_DIR"
          return 1
      fi
      
      if [[ ''${#profiles[@]} -eq 0 ]]; then
          print_msg "$RED" "Error: No monitor profiles found in $PROFILES_DIR"
          print_msg "$YELLOW" "Create some .conf files in that directory first"
          return 1
      fi
      
      ensure_current_exists "''${profiles[@]}"
      
      current_index=$(get_current_index "''${profiles[@]}")
      next_index=$(( (current_index + 1) % ''${#profiles[@]} ))
      
      local next_profile="''${profiles[$next_index]}"
      
      # Update state file
      echo "$next_index" > "$STATE_FILE"
      
      # Switch profile
      switch_to_profile "$next_profile" "$reload_after"
      print_msg "$BLUE" "Profile $((next_index + 1)) of ''${#profiles[@]}"
  }

  main() {
      local reload_after="true"
      local action="rotate"
      local target_profile=""
      
      # Parse arguments
      while [[ $# -gt 0 ]]; do
          case $1 in
              -h|--help)
                  usage
                  exit 0
                  ;;
              -l|--list)
                  list_profiles
                  exit $?
                  ;;
              -c|--current)
                  show_current
                  exit 0
                  ;;
              -s|--set)
                  if [[ -z "''${2:-}" ]]; then
                      print_msg "$RED" "Error: --set requires a profile name"
                      exit 1
                  fi
                  action="set"
                  target_profile="$2"
                  shift
                  ;;
              --no-reload)
                  reload_after="false"
                  ;;
              -*)
                  print_msg "$RED" "Unknown option: $1"
                  usage
                  exit 1
                  ;;
              *)
                  # Treat as profile name if no action set yet
                  if [[ "$action" == "rotate" ]]; then
                      action="set"
                      target_profile="$1"
                  else
                      print_msg "$RED" "Unexpected argument: $1"
                      usage
                      exit 1
                  fi
                  ;;
          esac
          shift
      done
      
      case "$action" in
          rotate)
              rotate_profile "$reload_after"
              ;;
          set)
              ensure_directories
              local profiles
              if ! profiles=($(get_profiles)); then
                  print_msg "$RED" "Error: Cannot access profiles directory: $PROFILES_DIR"
                  exit 1
              fi
              
              if [[ ''${#profiles[@]} -eq 0 ]]; then
                  print_msg "$RED" "Error: No monitor profiles found in $PROFILES_DIR"
                  exit 1
              fi
              
              ensure_current_exists "''${profiles[@]}"
              switch_to_profile "$target_profile" "$reload_after"
              
              # Update state file to reflect the new selection
              for i in "''${!profiles[@]}"; do
                  local profile_name="''${profiles[i]}"
                  if [[ "$target_profile" == "$profile_name" ]] || [[ "''${target_profile%.conf}" == "''${profile_name%.conf}" ]]; then
                      echo "$i" > "$STATE_FILE"
                      break
                  fi
              done
              ;;
      esac
  }

  main "$@"
''
