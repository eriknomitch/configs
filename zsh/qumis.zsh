source-if-exists $HOME/.repositories/qumis-cli/shell/qumis.sh

function qumis_load() {
  local projects=("qumis-api" "qumis-web" "qumis-llm-service")

  for project in "${projects[@]}"; do
    echo "Loading $project in detached mode..."
    tmuxp load -d "$project"
  done

  echo "All tmuxp sessions are being loaded in the background (detached)."
}

function qumis-tmux() {

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

function qumis-open-linear() {
  # Get the current branch name
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  if [[ -z "$branch" ]]; then
    echo "Not in a Git repository or no current branch."
    return 1
  fi

  # Extract the issue key (e.g., ENG-644) from the branch name
  if [[ "$branch" =~ [a-zA-Z]+/eng-([0-9]+) ]]; then
    local ticket_num=${match[1]}
    local ticket_id="ENG-${ticket_num}"
  else
    echo "Branch name does not match expected format (e.g., erik/eng-644)."
    return 1
  fi

  # Format a basic slug (you can customize this logic)
  local slug="add-mastra"  # optionally make this dynamic

  # Construct the Linear URL
  local url="https://linear.app/qumis/issue/${ticket_id}/${slug}"

  echo "Opening: $url"
  open "$url"
}

function qumis-open-pr() {
  if ! gh pr view --web 2>/dev/null; then
    echo "No PR found for the current branch."
    return 1
  fi
}
