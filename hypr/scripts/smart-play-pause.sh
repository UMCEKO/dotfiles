#!/bin/bash
ORDER_FILE="$HOME/.cache/media_play_order"
STATE_FILE="$HOME/.cache/media_current_state"

# Function to get current player states
get_current_states() {
    declare -A current_states
    for player in $(playerctl -l 2>/dev/null); do
        status=$(playerctl -p "$player" status 2>/dev/null)
        if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
            current_states["$player"]="$status"
        fi
    done
    
    # Return as player:state lines
    for player in "${!current_states[@]}"; do
        echo "$player:${current_states[$player]}"
    done
}

# Function to update play order when something starts playing
update_play_order() {
    local player="$1"
    local timestamp=$(date +%s)
    
    # Remove player from existing order
    if [ -f "$ORDER_FILE" ]; then
        grep -v "^$player:" "$ORDER_FILE" > "$ORDER_FILE.tmp" 2>/dev/null
        mv "$ORDER_FILE.tmp" "$ORDER_FILE"
    fi
    
    # Add player to end of order with timestamp
    echo "$player:$timestamp" >> "$ORDER_FILE"
    echo "DEBUG: Added $player to play order at $timestamp" >&2
}

# Function to get most recently started player from a list
get_most_recent_from_list() {
    local players=("$@")
    local most_recent=""
    local latest_time=0
    
    if [ ! -f "$ORDER_FILE" ]; then
        # No order file - just return the last player in the list
        echo "${players[-1]}"
        return
    fi
    
    while IFS=':' read -r player timestamp; do
        if [[ " ${players[*]} " =~ " $player " ]] && [ "$timestamp" -gt "$latest_time" ]; then
            latest_time="$timestamp"
            most_recent="$player"
        fi
    done < "$ORDER_FILE"
    
    if [ -n "$most_recent" ]; then
        echo "$most_recent"
    else
        # Fallback to last player in list
        echo "${players[-1]}"
    fi
}

# Main logic
current_states=$(get_current_states)
playing_players=()
paused_players=()

# Parse current states
while IFS=':' read -r player state; do
    [ -z "$player" ] && continue
    case "$state" in
        "Playing") playing_players+=("$player") ;;
        "Paused") paused_players+=("$player") ;;
    esac
done <<< "$current_states"

echo "DEBUG: Playing: ${playing_players[*]}" >&2
echo "DEBUG: Paused: ${paused_players[*]}" >&2

# Load previous states to detect newly started players
declare -A prev_states
if [ -f "$STATE_FILE" ]; then
    while IFS=':' read -r player state; do
        prev_states["$player"]="$state"
    done < "$STATE_FILE"
fi

# Check for newly started players and update their order
for player in "${playing_players[@]}"; do
    if [ "${prev_states[$player]}" != "Playing" ]; then
        echo "DEBUG: $player just started playing" >&2
        update_play_order "$player"
    fi
done

# Save current states for next run
echo "$current_states" > "$STATE_FILE"

# Simple control logic
if [ ${#playing_players[@]} -gt 0 ]; then
    # Something is playing - pause the most recent one
    target=$(get_most_recent_from_list "${playing_players[@]}")
    echo "DEBUG: Pausing most recent playing: $target" >&2
    playerctl -p "$target" pause
    
else
    # Nothing playing - resume the most recent paused if it exists
    if [ ${#paused_players[@]} -gt 0 ]; then
        target=$(get_most_recent_from_list "${paused_players[@]}")
        echo "DEBUG: Resuming most recent paused: $target" >&2
        playerctl -p "$target" play
    else
        # No paused players, apply default behavior
        echo "DEBUG: No paused players, using default playerctl behavior" >&2
        playerctl play-pause
    fi
fi

# Debug: show current play order
echo "DEBUG: Current play order:" >&2
if [ -f "$ORDER_FILE" ]; then
    cat "$ORDER_FILE" >&2
else
    echo "No order file yet" >&2
fi
