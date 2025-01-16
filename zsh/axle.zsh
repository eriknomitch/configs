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
    # If the mount point does not exist, create it
    if [[ ! -d ~/.axle ]]; then
      echo "Creating local directory ~/.axle..."
      mkdir -p ~/.axle
    fi
    # Attempt to mount the remote directory using sshfs
    echo "Mounting axle:/home/erik/.axle to ~/.axle with sshfs..."
    sshfs axle:/home/erik/.axle ~/.axle
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
    fusermount -u ~/.axle  # Use fusermount to unmount the directory
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

function _axle_usage() {
  # Function to display usage instructions for the axle command
  echo "Usage: axle <command>"
  echo "Commands:"
  echo "  ssh      Connect to axle via SSH"
  echo "  mount    Mount axle:/home/erik/.axle to ~/.axle with sshfs"
  echo "  unmount  Unmount ~/.axle if mounted"
  echo "  help     Show this usage information"
}

function axle() {
  # Main function to handle user input and delegate to specific commands
  local command=$1  # The first argument passed to the function

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

