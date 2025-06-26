function qumis_load() {
  local projects=("qumis-api" "qumis-web" "qumis-llm-service")

  for project in "${projects[@]}"; do
    echo "Loading $project in detached mode..."
    tmuxp load -d "$project"
  done

  echo "All tmuxp sessions are being loaded in the background (detached)."
}

function qumis() {

  case "$1" in
    "start")
      qumis_start
      ;;
    "stop")
      qumis_stop
      ;;
    "load")
      qumis_load
      ;;
    *)
      echo "Usage: qumis {start|stop|load}"
      ;;
  esac
}
