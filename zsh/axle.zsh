function _axle_ssh() {
  echo "Connecting to axle via SSH..."
  ssh axle
}

function _axle_mount() {
  if mount | grep -q "~/.axle"; then
    echo "~/.axle is already mounted."
  else
    echo "Mounting axle:/home/erik/.axle to ~/.axle with sshfs..."
    sshfs axle:/home/erik/.axle ~/.axle
    if [[ $? -eq 0 ]]; then
      echo "Mount successful."
    else
      echo "Mount failed."
    fi
  fi
}

function _axle_unmount() {
  if mount | grep -q "~/.axle"; then
    echo "Unmounting ~/.axle..."
    fusermount -u ~/.axle
    if [[ $? -eq 0 ]]; then
      echo "Unmount successful."
    else
      echo "Unmount failed."
    fi
  else
    echo "~/.axle is not mounted."
  fi
}

function _axle_usage() {
  echo "Usage: axle <command>"
  echo "Commands:"
  echo "  ssh      Connect to axle via SSH"
  echo "  mount    Mount axle:/home/erik/.axle to ~/.axle with sshfs"
  echo "  unmount  Unmount ~/.axle if mounted"
  echo "  help     Show this usage information"
}

function axle() {
  local command=$1

  case $command in
    ssh)
      _axle_ssh
      ;;

    mount)
      _axle_mount
      ;;

    unmount)
      _axle_unmount
      ;;

    help|--help|-h|"")
      _axle_usage
      ;;

    *)
      echo "Unknown command: $command"
      _axle_usage
      ;;
  esac
}

