function _axle_ssh() {
  # Function to connect to the remote host "axle" via SSH
  echo "Connecting to axle via SSH..."
  ssh axle
}

function _axle_mount() {
  # Function to mount the remote directory axle:/home/erik/.axle to ~/.axle locally

  # Check if the directory is already mounted by inspecting the output of the mount command
  if mount | grep -E "axle:/home/erik/.axle on /Users/erik/.axle"; then
    echo "~/.axle is already mounted."
  else
    # If the mount point exists, check if it is empty
    if [[ -d ~/.axle ]]; then
      if [[ -z $(ls -A ~/.axle) ]]; then
        echo "Cleaning up existing empty ~/.axle directory..."
        rmdir ~/.axle
      else
        echo "Error: ~/.axle directory is not empty. Please clean it manually."
        return 1
      fi
    fi
    # Create a fresh mount point
    echo "Creating local directory ~/.axle..."
    mkdir -p ~/.axle

    # Attempt to mount the remote directory using sshfs with performance-enhancing options
    echo "Mounting axle:/home/erik/.axle to ~/.axle with sshfs..."
    sshfs axle:/home/erik/.axle ~/.axle \
      -o cache=yes \
      -o kernel_cache \
      -o compression=no \
      -o large_read \
      -o auto_cache \
      -o reconnect \
      -o Ciphers=arcfour \
      -o ServerAliveInterval=15 \
      -o ServerAliveCountMax=3
    if [[ $? -eq 0 ]]; then
      # Check the exit status to confirm if the mount was successful
      echo "Mount successful."
    else
      echo "Mount failed."
    fi
  fi
}

function _axle_unmount() {
  # Function to unmount the ~/.axle directory if it is currently mounted

  # Check if the directory is mounted by inspecting the output of the mount command
  if mount | grep -E "axle:/home/erik/.axle on /Users/erik/.axle"; then
    echo "Unmounting ~/.axle..."
    umount ~/.axle  # Use umount to unmount the directory on macOS
    if [[ $? -eq 0 ]]; then
      # Check the exit status to confirm if the unmount was successful
      echo "Unmount successful."
    else
      echo "Unmount failed."
    fi
  else
    # Notify the user if the directory is not mounted
    echo "~/.axle is not mounted."
  fi
}

function _axle_remount() {
  # Function to remount the ~/.axle directory

  # Check if the directory is currently mounted
  if mount | grep -E "axle:/home/erik/.axle on /Users/erik/.axle"; then
    echo "Remounting ~/.axle..."
    umount ~/.axle
    if [[ $? -eq 0 ]]; then
      # Unmount succeeded, attempt to remount
      _axle_mount
    else
      echo "Failed to unmount ~/.axle. Remount aborted."
    fi
  else
    # If not mounted, simply mount the directory
    echo "~/.axle is not currently mounted. Mounting now..."
    _axle_mount
  fi
}

function _axle_sync_start() {
  # Function to start Mutagen sync sessions
  echo "Starting Mutagen daemon..."
  mutagen daemon start

  echo "Creating Mutagen sync sessions..."
  mutagen sync create --name=hikari /Users/erik/.repositories/hikari axle:~/.axle/hikari
  mutagen sync create --name=rose-pybackend /Users/erik/.repositories/rose-pybackend axle:~/.axle/rose-pybackend
}

function _axle_sync_stop() {
  # Function to stop Mutagen sync sessions
  echo "Terminating Mutagen sync sessions..."
  mutagen sync terminate hikari
  mutagen sync terminate rose-pybackend

  echo "Stopping Mutagen daemon..."
  mutagen daemon stop
}

function _axle_sync() {
  # Function to handle Mutagen sync commands
  local action=$1

  case $action in
    start)
      _axle_sync_start
      ;;

    stop)
      _axle_sync_stop
      ;;

    *)
      echo "Unknown sync action: $action"
      echo "Valid actions are: start, stop"
      ;;
  esac
}

function _axle_usage() {
  # Function to display usage instructions for the axle command
  echo "Usage: axle <command>"
  echo "Commands:"
  echo "  ssh      Connect to axle via SSH"
  echo "  mount    Mount axle:/home/erik/.axle to ~/.axle with sshfs"
  echo "  unmount  Unmount ~/.axle if mounted"
  echo "  remount  Unmount and remount ~/.axle"
  echo "  sync     Manage Mutagen sync sessions (start, stop)"
  echo "  help     Show this usage information"
}

function axle() {
  # Main function to handle user input and delegate to specific commands
  local command=$1  # The first argument passed to the function
  local subcommand=$2  # The second argument passed to the function (for sync)

  case $command in
    ssh)
      # Delegate to the SSH function
      _axle_ssh
      ;;

    mount)
      # Delegate to the mount function
      _axle_mount
      ;;

    unmount)
      # Delegate to the unmount function
      _axle_unmount
      ;;

    remount)
      # Delegate to the remount function
      _axle_remount
      ;;

    sync)
      # Delegate to the sync function with a subcommand
      _axle_sync $subcommand
      ;;

    help|--help|-h)
      # Delegate to the usage function to display help information
      _axle_usage
      ;;

    "")
      # Default to SSH if no arguments are provided
      _axle_ssh
      ;;

    *)
      # Handle unknown commands and show usage instructions
      echo "Unknown command: $command"
      _axle_usage
      ;;
  esac
}

