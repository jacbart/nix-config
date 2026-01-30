#!/usr/bin/env zsh

# Script to manage broot (left) and helix (right) in tmux with window-based project management

# Get current directory using zoxide
get_zoxide_current_dir() {
  if command -v zoxide >/dev/null 2>&1; then
    zoxide query -l 2>/dev/null || pwd
  else
    pwd
  fi
}

# Navigate to directory using zoxide with fallback to cd
zoxide_cd() {
  local target_dir="$1"
  if command -v zoxide >/dev/null 2>&1; then
    z "$target_dir" 2>/dev/null || cd "$target_dir"
  else
    cd "$target_dir"
  fi
}

# Add current directory to zoxide database
zoxide_add() {
  if command -v zoxide >/dev/null 2>&1; then
    zoxide add "$(get_zoxide_current_dir)" 2>/dev/null
  fi
}

# Get project window name based on git repository or current directory
get_project_window_name() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    # Try remote URL first for uniqueness
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null || git remote get-url main 2>/dev/null)
    if [[ -n "$remote_url" ]]; then
      echo "$remote_url" | sed -E 's/.+\/([^.]+)(\.git)?/\1/'
    else
      basename "$(git rev-parse --show-toplevel)"
    fi
  else
    basename "$(get_zoxide_current_dir)"
  fi
}

# Get IDE session name (constant)
get_ide_session_name() {
  echo "ide"
}

# Check if project window already exists
project_window_exists() {
  local window_name
  window_name=$(get_project_window_name)
  local ide_session
  ide_session=$(get_ide_session_name)
  tmux list-windows -t "$ide_session" -F '#{window_name}' | grep -q "^$window_name$"
}

# Get current git repository root path
get_current_git_root() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    git rev-parse --show-toplevel
  else
    get_zoxide_current_dir
  fi
}

# Create or switch to project window
setup_project_window() {
  local window_name
  window_name=$(get_project_window_name)
  local ide_session
  ide_session=$(get_ide_session_name)
  local current_git_root
  current_git_root=$(get_current_git_root)

  # Add current directory to zoxide database
  zoxide_add

  # Ensure IDE session exists
  if ! tmux has-session -t "$ide_session" 2>/dev/null; then
    tmux new-session -d -s "$ide_session" -n "default"
  fi

  # Check if project window already exists
  if ! project_window_exists; then
    # Create new window for this project
    tmux new-window -d -t "$ide_session" -n "$window_name" -c "$current_git_root"
    setup_ide_layout_in_window "$ide_session:$window_name"
  fi

  # Switch to the project window
  tmux select-window -t "$ide_session:$window_name"
}

# Get pane ID for current pane
get_current_pane_id() {
  tmux display-message -p "#{pane_id}"
}

# Close broot preview panel
close_broot_preview() {
  local current_window
  current_window=$(tmux display-message -p '#{window_name}')
  local ide_session
  ide_session=$(get_ide_session_name)
  local broot_pane
  broot_pane=$(tmux show-option -t "$ide_session:$current_window" -qv "@broot_pane" 2>/dev/null)

  # Fallback to direct pane targeting if custom variable not set
  if [[ -z "$broot_pane" ]]; then
    broot_pane=$(tmux display-message -p -t "$ide_session:$current_window.0" "#{pane_id}")
  fi

  if [[ -n "$broot_pane" ]]; then
    # Enter command mode
    tmux send-keys -t "$broot_pane" ":"
    sleep 0.2
    # Send the close preview command
    tmux send-keys -t "$broot_pane" "close_preview"
    sleep 0.1
    # Send Enter to execute
    tmux send-keys -t "$broot_pane" "Enter"
    # Update state tracking
    tmux set-option -t "$ide_session:$current_window" "@preview_state" "closed"
  fi
}

# Toggle preview panel
toggle_preview_panel() {
  local current_window
  current_window=$(tmux display-message -p '#{window_name}')
  local ide_session
  ide_session=$(get_ide_session_name)
  local broot_pane
  broot_pane=$(tmux show-option -t "$ide_session:$current_window" -qv "@broot_pane" 2>/dev/null)
  local current_state
  current_state=$(tmux show-option -t "$ide_session:$current_window" -qv "@preview_state" 2>/dev/null || echo "open")

  # Fallback to direct pane targeting if custom variable not set
  if [[ -z "$broot_pane" ]]; then
    broot_pane=$(tmux display-message -p -t "$ide_session:$current_window.0" "#{pane_id}")
  fi

  if [[ -n "$broot_pane" ]]; then
    # Enter command mode
    tmux send-keys -t "$broot_pane" ":"
    sleep 0.2
    # Send the toggle preview command
    tmux send-keys -t "$broot_pane" "toggle_preview"
    sleep 0.1
    # Send Enter to execute
    tmux send-keys -t "$broot_pane" "Enter"

    # Update state tracking
    if [[ "$current_state" == "open" ]]; then
      tmux set-option -t "$ide_session:$current_window" "@preview_state" "closed"
    else
      tmux set-option -t "$ide_session:$current_window" "@preview_state" "open"
    fi
  fi
}

# Universal navigation function
navigate_pane() {
  local direction="$1"
  local current_pane_id
  current_pane_id=$(get_current_pane_id)
  local current_type
  current_type=$(get_pane_type "$current_pane_id")

  case "$direction" in
  "left")
    tmux select-pane -L
    ;;
  "right")
    tmux select-pane -R
    ;;
  "up")
    tmux select-pane -U
    ;;
  "down")
    tmux select-pane -D
    ;;
  esac
}

# Get pane type (broot/helix) using tmux custom variables
get_pane_type() {
  local pane_id="$1"
  if [[ -z "$pane_id" ]]; then
    pane_id=$(get_current_pane_id)
  fi

  # Get pane tracking from current window
  local current_window
  current_window=$(tmux display-message -p '#{window_name}')
  local ide_session
  ide_session=$(get_ide_session_name)
  local broot_pane
  broot_pane=$(tmux show-option -t "$ide_session:$current_window" -qv "@broot_pane" 2>/dev/null)
  local helix_pane
  helix_pane=$(tmux show-option -t "$ide_session:$current_window" -qv "@helix_pane" 2>/dev/null)

  # Fallback to direct pane detection
  if [[ -z "$broot_pane" || -z "$helix_pane" ]]; then
    broot_pane=$(tmux display-message -p -t "$ide_session:$current_window.0" "#{pane_id}")
    helix_pane=$(tmux display-message -p -t "$ide_session:$current_window.1" "#{pane_id}")
  fi

  if [[ "$pane_id" == "$broot_pane" ]]; then
    echo "broot"
  elif [[ "$pane_id" == "$helix_pane" ]]; then
    echo "helix"
  else
    echo "unknown"
  fi
}

# Toggle between broot and helix panes
toggle_panes() {
  local current_pane_id
  current_pane_id=$(get_current_pane_id)
  local current_type
  current_type=$(get_pane_type "$current_pane_id")
  local broot_pane
  broot_pane=$(tmux show-option -qv "@broot_pane" 2>/dev/null)
  local helix_pane
  helix_pane=$(tmux show-option -qv "@helix_pane" 2>/dev/null)

  if [[ "$current_type" == "broot" && -n "$helix_pane" ]]; then
    tmux select-pane -t "$helix_pane"
  elif [[ "$current_type" == "helix" && -n "$broot_pane" ]]; then
    tmux select-pane -t "$broot_pane"
  elif [[ -n "$helix_pane" ]]; then
    # If current type is unknown, default to helix
    tmux select-pane -t "$helix_pane"
  elif [[ -n "$broot_pane" ]]; then
    tmux select-pane -t "$broot_pane"
  fi
}

# Setup IDE layout in a specific window
setup_ide_layout_in_window() {
  local target_window="$1"
  local current_git_root
  current_git_root=$(get_current_git_root)

  # Create 20/80 split in the target window
  tmux split-window -h -p 85 -t "$target_window"

  # Add delay to allow shells to initialize
  sleep 1

  # Start broot on left panel (20%) - pane 0
  local broot_pane
  broot_pane=$(tmux display-message -p -t "$target_window.0" "#{pane_id}")
  tmux set-option -t "$target_window" "@broot_pane" "$broot_pane"
  tmux set-option -t "$target_window" "@preview_state" "open"
  tmux send-keys -t "$target_window.0" "br && exit" Enter

  # Add delay before starting helix
  sleep 1

  # Start helix on right panel (80%) - pane 1
  local helix_pane
  helix_pane=$(tmux display-message -p -t "$target_window.1" "#{pane_id}")
  tmux set-option -t "$target_window" "@helix_pane" "$helix_pane"
  tmux send-keys -t "$target_window.1" "hx && exit" Enter

  # Add final delay to ensure helix is fully initialized
  sleep 2

  tmux select-pane -t "$target_window.0"
}

# Main setup function - creates or switches to project window
setup_ide_layout() {
  setup_project_window
}

# Ensure existing window has correct IDE structure
ensure_ide_structure() {
  local target_window="$1"
  local current_panes
  current_panes=$(tmux list-panes -t "$target_window" | wc -l)

  # If window doesn't have expected 2-pane layout, recreate it
  if [[ "$current_panes" != "2" ]]; then
    # Kill existing window and recreate
    tmux kill-window -t "$target_window"
    setup_project_window
    return
  fi

  # Set up pane tracking if not already set
  local broot_pane
  local helix_pane
  broot_pane=$(tmux show-option -t "$target_window" -qv "@broot_pane" 2>/dev/null)
  helix_pane=$(tmux show-option -t "$target_window" -qv "@helix_pane" 2>/dev/null)

  if [[ -z "$broot_pane" || -z "$helix_pane" ]]; then
    # Check if panes exist before trying to get their IDs
    if tmux display-message -t "$target_window.0" &>/dev/null && tmux display-message -t "$target_window.1" &>/dev/null; then
      broot_pane=$(tmux display-message -p -t "$target_window.0" "#{pane_id}")
      helix_pane=$(tmux display-message -p -t "$target_window.1" "#{pane_id}")
      tmux set-option -t "$target_window" "@broot_pane" "$broot_pane"
      tmux set-option -t "$target_window" "@helix_pane" "$helix_pane"
      tmux set-option -t "$target_window" "@preview_state" "open"
    fi
  fi
}

# Ensure helix exists and is running
ensure_helix_exists() {
  local current_window
  current_window=$(tmux display-message -p '#{window_name}')
  local ide_session
  ide_session=$(get_ide_session_name)
  local helix_pane
  helix_pane=$(tmux show-option -t "$ide_session:$current_window" -qv "@helix_pane" 2>/dev/null)

  if [[ -n "$helix_pane" ]]; then
    # Check if helix is still running in the pane
    local pane_content
    pane_content=$(tmux capture-pane -p -t "$helix_pane" | head -5)
    if ! echo "$pane_content" | grep -q "hx"; then
      # Restart helix if not running
      tmux send-keys -t "$helix_pane" "hx && exit" Enter
    fi
  fi
}

# Open file in existing helix pane with smart focus and preview management
open_in_helix() {
  local file="$1"
  local line="$2"
  local current_pane_id
  current_pane_id=$(get_current_pane_id)
  local current_type
  current_type=$(get_pane_type "$current_pane_id")
  local current_window
  current_window=$(tmux display-message -p '#{window_name}')
  local ide_session
  ide_session=$(get_ide_session_name)
  local helix_pane
  helix_pane=$(tmux show-option -t "$ide_session:$current_window" -qv "@helix_pane" 2>/dev/null)

  # Fallback to direct pane targeting if custom variable not set
  if [[ -z "$helix_pane" ]]; then
    helix_pane=$(tmux display-message -p -t "$ide_session:$current_window.1" "#{pane_id}")
  fi

  if [[ -n "$helix_pane" ]]; then
    # Close broot preview panel first
    close_broot_preview

    # Ensure helix is running
    ensure_helix_exists

    # Open file in helix
    if [[ -n "$line" ]]; then
      tmux send-keys -t "$helix_pane" "Escape"
      sleep 0.5
      tmux send-keys -t "$helix_pane" ":goto $file:$line" Enter
    else
      tmux send-keys -t "$helix_pane" "Escape"
      sleep 0.5
      tmux send-keys -t "$helix_pane" ":open $file" Enter
    fi

    # Smart switch: only switch to helix if not already there
    if [[ "$current_type" != "helix" ]]; then
      tmux select-pane -t "$helix_pane"
    fi
  fi
}

# List all open project windows
list_project_windows() {
  local ide_session
  ide_session=$(get_ide_session_name)
  if tmux has-session -t "$ide_session" 2>/dev/null; then
    tmux list-windows -t "$ide_session" -F '#{window_name}'
  else
    echo "No IDE session found"
  fi
}

# Switch to specific project window using zoxide
switch_to_project() {
  local project_name="$1"
  local ide_session
  ide_session=$(get_ide_session_name)

  if tmux has-session -t "$ide_session" 2>/dev/null; then
    if tmux display-message -t "$ide_session:$project_name" &>/dev/null; then
      tmux select-window -t "$ide_session:$project_name"
      # Use zoxide to navigate to the project directory if available
      if command -v zoxide >/dev/null 2>&1; then
        local project_dir
        project_dir=$(tmux display-message -p -t "$ide_session:$project_name" '#{pane_current_path}')
        if [[ -n "$project_dir" ]]; then
          zoxide add "$project_dir" 2>/dev/null
        fi
      fi
    else
      echo "Project window '$project_name' not found"
      echo "Available projects:"
      list_project_windows
    fi
  else
    echo "No IDE session found"
  fi
}

# Attach to IDE session
attach_to_ide_session() {
  local ide_session
  ide_session=$(get_ide_session_name)

  # Attach to session
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$ide_session"
  else
    tmux attach-session -t "$ide_session"
  fi
}

arg=${1:-}

# Handle command line arguments
case "$arg" in
"nav-left")
  navigate_pane "left"
  ;;
"nav-right")
  navigate_pane "right"
  ;;
"nav-up")
  navigate_pane "up"
  ;;
"nav-down")
  navigate_pane "down"
  ;;
"toggle-preview")
  toggle_preview_panel
  ;;
"exit")
  # Quick exit with optional confirmation
  if [[ "$2" == "--force" ]]; then
    # Force exit without confirmation
    tmux kill-session -t "$(get_ide_session_name)"
  else
    # Exit with confirmation (using tmux's built-in confirm)
    tmux confirm-before -p "kill-session?" "kill-session -t $(get_ide_session_name)"
  fi
  ;;
"help")
  echo "IDE Script Usage:"
  echo "  ide                    - Create/attach to project window (current directory)"
  echo "  ide [file]             - Create/attach and open file in helix"
  echo "  ide open <file>       - Open file in existing project window"
  echo "  ide list               - List all open project windows"
  echo "  ide switch <project>  - Switch to specific project window"
  echo "  ide nav-left/right/up/down - Navigate between panes"
  echo "  ide toggle-preview    - Toggle broot preview panel"
  echo "  ide exit               - Exit IDE session"
  echo "  ide exit --force      - Exit IDE session without confirmation"
  echo "  ide help               - Show this help message"
  echo ""
  echo "Zoxide Integration:"
  echo "  - Automatically tracks project directories"
  echo "  - Uses zoxide for smart directory navigation"
  echo "  - Maintains zoxide database when switching projects"
  ;;
"open")
  if [[ $# -gt 1 ]]; then
    file="$2"
    line="${3:-}"
    # Ensure session exists before trying to open file
    setup_ide_layout
    open_in_helix "$file" "$line"
  fi
  ;;
"list")
  list_project_windows
  ;;
"switch")
  if [[ $# -gt 1 ]]; then
    switch_to_project "$2"
  else
    echo "Usage: ide switch <project_name>"
    echo "Available projects:"
    list_project_windows
  fi
  ;;
*)
  # Default: setup project window and attach
  setup_ide_layout

  # Always treat current directory as first argument
  file="."

  # Only try to open if it's a file, not directory
  if [[ -f "$file" ]]; then
    open_in_helix "$file"
  fi

  # Attach to IDE session
  attach_to_ide_session
  ;;
esac
