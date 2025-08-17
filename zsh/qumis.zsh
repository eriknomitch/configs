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

# --------------------------------------------------
########################################################################
# AWS + ECS Zsh Toolkit (long names)
# Save as: ~/.zsh/aws-ecs-tools.zsh
# Then add to ~/.zshrc:  [[ -f "$HOME/.zsh/aws-ecs-tools.zsh" ]] && source "$HOME/.zsh/aws-ecs-tools.zsh"
########################################################################

# ------------------------------- Config -------------------------------

# Profiles that require extra caution (confirmed on use; red prompt badge)
typeset -ga ECSR_PROTECTED_PROFILES
ECSR_PROTECTED_PROFILES=(
  qumis_prod
)

# Optional: profile aliases (short -> real). Keep or leave empty.
# We keep them here for future use, but nothing auto-uses them unless you call
# _aws_profile_resolve yourself.
typeset -gA ECSR_PROFILE_ALIAS
ECSR_PROFILE_ALIAS=(
  [dev]=qumis_dev
  [qa]=qumis_qa
  [uat]=qumis_uat
  [prod]=qumis_prod
)

# Optional: map a profile to its default cluster (name or full ARN) to skip -c
typeset -gA ECSR_DEFAULT_CLUSTER_BY_PROFILE
ECSR_DEFAULT_CLUSTER_BY_PROFILE=(
  [qumis_dev]="arn:aws:ecs:us-east-2:080970846004:cluster/qumis-dev-cluster"
  # [qumis_qa]="arn:aws:ecs:us-east-2:<acct>:cluster/qumis-qa-cluster"
  # [qumis_uat]="arn:aws:ecs:us-east-2:<acct>:cluster/qumis-uat-cluster"
  # [qumis_prod]="arn:aws:ecs:us-east-2:<acct>:cluster/qumis-prod-cluster"
)

# Default profile for aws-sso-and-export if none passed
typeset -g QUMIS_INFRA_AWS_PROFILE="${QUMIS_INFRA_AWS_PROFILE:-}"

# Active profile for this shell session (used by helpers; not exported)
typeset -g ECSR_ACTIVE_PROFILE=""

# ------------------------------- Utils --------------------------------

_ecs_require_bins() {
  local missing=()
  local bin
  for bin in "$@"; do
    command -v "$bin" >/dev/null 2>&1 || missing+=("$bin")
  done
  if (( ${#missing[@]} )); then
    echo "❌ Missing dependencies: ${missing[*]}" >&2
    return 127
  fi
}

_aws_profile_resolve() {
  local p="$1"
  echo "${ECSR_PROFILE_ALIAS[$p]:-$p}"
}

_ecs_in_array() {
  local needle="$1"; shift
  local x
  for x in "$@"; do [[ "$x" == "$needle" ]] && return 0; done
  return 1
}

# Parse -c/--cluster and -p/--profile flags; prints remaining args.
# Sets globals ECS_FLAG_CLUSTER / ECS_FLAG_PROFILE.
_ecs_parse_flags() {
  typeset -g ECS_FLAG_CLUSTER=""
  typeset -g ECS_FLAG_PROFILE=""
  local rest=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -c|--cluster) ECS_FLAG_CLUSTER="$2"; shift 2 ;;
      -p|--profile) ECS_FLAG_PROFILE="$2"; shift 2 ;;
      --) shift; rest+=("$@"); break ;;
      -*) echo "❌ Unknown flag: $1" >&2; return 2 ;;
      *)  rest+=("$1"); shift ;;
    esac
  done
  print -r -- "${rest[@]}"
}

_ecs_whoami_banner() {
  local prof="$1"
  local acct arn
  acct=$(AWS_PROFILE="$prof" aws sts get-caller-identity --query Account --output text 2>/dev/null)
  arn=$(AWS_PROFILE="$prof" aws sts get-caller-identity --query Arn --output text 2>/dev/null)
  if [[ -n "$acct" && "$acct" != "None" ]]; then
    echo "🔑 AWS profile: $prof   Account: $acct"
    echo "   ARN: $arn"
  else
    echo "🔑 AWS profile: $prof   (unable to resolve account — are you logged in?)"
  fi
}

# Resolve cluster: explicit -> env var -> per-profile map -> discover by service
_ecs_resolve_cluster() {
  local cluster_in="$1"
  local service="$2"

  if [[ -n "$cluster_in" ]]; then
    echo "$cluster_in"
    return 0
  fi

  if [[ -n "$ECSR_DEFAULT_CLUSTER" ]]; then
    echo "$ECSR_DEFAULT_CLUSTER"
    return 0
  fi

  if [[ -n "$ECSR_ACTIVE_PROFILE" ]]; then
    local mapped="${ECSR_DEFAULT_CLUSTER_BY_PROFILE[$ECSR_ACTIVE_PROFILE]}"
    if [[ -n "$mapped" ]]; then
      echo "$mapped"
      return 0
    fi
  fi

  if [[ -z "$service" ]]; then
    echo "❌ No cluster specified and no service provided for discovery." >&2
    return 1
  fi

  local clusters ds svc_stat running_count found=""
  clusters="$(_aws ecs list-clusters --output json | jq -r '.clusterArns[]?' 2>/dev/null)"
  if [[ -z "$clusters" ]]; then
    echo "❌ No ECS clusters found." >&2
    return 1
  fi

  local c
  for c in $clusters; do
    ds="$(_aws ecs describe-services --cluster "$c" --services "$service" --output json 2>/dev/null)" || ds=""
    [[ "$(jq -r '.services | length' <<<"$ds")" == "0" ]] && continue
    svc_stat="$(jq -r '.services[0].status // empty' <<<"$ds")"
    running_count="$(jq -r '.services[0].runningCount // 0' <<<"$ds")"
    if [[ "$svc_stat" == "ACTIVE" ]]; then
      found="$c"
      (( running_count > 0 )) && { echo "$found"; return 0; }
    fi
  done

  if [[ -z "$found" ]]; then
    echo "❌ Could not find an ACTIVE ECS service named '${service}' in any cluster." >&2
    return 1
  fi

  echo "$found"
}

# AWS CLI wrapper: prefers ECSR_ACTIVE_PROFILE, then command flag
_aws() {
  local prof="${ECSR_ACTIVE_PROFILE:-$ECS_FLAG_PROFILE}"
  if [[ -n "$prof" ]]; then
    if _ecs_in_array "$prof" "${ECSR_PROTECTED_PROFILES[@]}"; then
      print -r -- "🔒 [protected:${prof}] aws $*" >&2
    fi
    AWS_PROFILE="$prof" aws "$@"
  else
    aws "$@"
  fi
}

# --------------------------- Prompt Badge -----------------------------

# Right-side prompt badge showing active profile (safe; no glob patterns)
_ecs_update_rprompt() {
  local p="$ECSR_ACTIVE_PROFILE"
  local badge=""
  if [[ -n "$p" ]]; then
    if _ecs_in_array "$p" "${ECSR_PROTECTED_PROFILES[@]}"; then
      badge="%F{red}[AWS:${p}]%f"
    else
      badge="%F{blue}[AWS:${p}]%f"
    fi
  fi
  RPROMPT="$badge"
}

# Install the hook once
if ! typeset -f _ecs_precmd_hook_installed >/dev/null; then
  _ecs_precmd_hook_installed() { :; }
  autoload -Uz add-zsh-hook 2>/dev/null || true
  add-zsh-hook precmd _ecs_update_rprompt 2>/dev/null || true
fi

# ------------------------- SSO + Sessions -----------------------------

# Login with SSO and export env creds into current shell (optionally pass profile)
aws-sso-and-export() {
  local profile="${1:-$QUMIS_INFRA_AWS_PROFILE}"
  if [[ -z "$profile" ]]; then
    echo "Usage: aws-sso-and-export <profile>"
    return 2
  fi
  _ecs_require_bins aws || return $?

  echo "🔐 aws sso login --profile ${profile}"
  if ! aws sso login --profile "$profile"; then
    echo "❌ SSO login failed for profile: ${profile}"
    return 1
  fi

  echo "📤 Exporting temporary credentials into this shell..."
  local exports
  if ! exports="$(aws configure export-credentials --profile "$profile" --format env)"; then
    echo "❌ Failed to obtain credentials for profile: ${profile}"
    return 1
  fi

  eval "$exports"
  export AWS_PROFILE="$profile"
  echo "✅ Exported creds for '${profile}'. Expiration: ${AWS_CREDENTIAL_EXPIRATION:-unknown}"
}

# Session-aware wrapper:
#   aws-session use  <profile>          # SSO login, set session profile (badge)
#   aws-session shell <profile>         # SSO login, subshell with profile
#   aws-session run  <profile> -- CMD   # SSO login, run one command with profile
aws-session() {
  _ecs_require_bins aws || return $?

  local mode="$1"; shift || true
  case "$mode" in
    use|shell|run) ;;
    *)
      cat <<'USAGE'
Usage:
  aws-session use  <profile>              # SSO login, set session profile (current shell)
  aws-session shell <profile>             # SSO login, open subshell with profile
  aws-session run  <profile> -- <cmd...>  # SSO login, run one command with profile
USAGE
      return 2
      ;;
  esac

  local prof="$1"
  if [[ -z "$prof" ]]; then
    echo "❌ Missing <profile>"
    return 2
  fi
  shift || true

  # Confirm if protected
  if _ecs_in_array "$prof" "${ECSR_PROTECTED_PROFILES[@]}"; then
    echo "⚠️  You're targeting PROTECTED profile: '$prof'."
    local _ecs_confirm
    vared -p "Type the profile name to confirm: " -c _ecs_confirm 2>/dev/null || read "?Type the profile name to confirm: " _ecs_confirm
    [[ "$_ecs_confirm" != "$prof" ]] && { echo "❌ Not switching."; return 1; }
  fi

  echo "🔐 aws sso login --profile ${prof}"
  if ! aws sso login --profile "$prof"; then
    echo "❌ SSO login failed for profile: ${prof}"
    return 1
  fi

  case "$mode" in
    use)
      ECSR_ACTIVE_PROFILE="$prof"
      _ecs_whoami_banner "$prof"
      _ecs_update_rprompt
      echo "✅ Session profile set: $prof (prompt badge updated)"
      ;;
    shell)
      echo "🧭 Starting subshell with AWS_PROFILE=$prof"
      _ecs_whoami_banner "$prof"
      ECSR_ACTIVE_PROFILE="$prof" AWS_PROFILE="$prof" zsh
      echo "🔚 Left subshell for profile: $prof"
      ;;
    run)
      [[ "$1" == "--" ]] && shift
      if [[ $# -eq 0 ]]; then
        echo "❌ Usage: aws-session run <profile> -- <command...>"
        return 2
      fi
      _ecs_whoami_banner "$prof"
      ECSR_ACTIVE_PROFILE="$prof" AWS_PROFILE="$prof" "$@"
      ;;
  esac
}

# --------------------------- ECS Commands -----------------------------

# Run a command in the newest running task for a service (ECS Exec)
# Usage: ecs-run [-c <cluster>] [-p <profile>] <service> <command...>
ecs-run() {
  _ecs_require_bins aws jq || return $?
  local parsed; parsed="$(_ecs_parse_flags "$@")" || return $?
  set -- $parsed
  if [[ $# -lt 2 ]]; then
    echo "Usage: ecs-run [-c <cluster>] [-p <profile>] <service> <command...>"
    return 1
  fi

  local service="$1"; shift
  local cmd="$*"

  echo "🔎 Discovering cluster for service '${service}'..."
  local cluster; cluster="$(_ecs_resolve_cluster "$ECS_FLAG_CLUSTER" "$service")" || return $?
  echo "📍 Cluster: $cluster"

  local who_prof="${ECSR_ACTIVE_PROFILE:-$ECS_FLAG_PROFILE:-${AWS_PROFILE:-}}"
  if [[ -n "$who_prof" ]]; then
    _ecs_whoami_banner "$who_prof"
  fi

  echo "📦 Locating running task for '${service}'..."
  local task_arns desc selected_task_arn container_name
  task_arns="$(_aws ecs list-tasks --cluster "$cluster" --service-name "$service" --desired-status RUNNING --output json | jq -r '.taskArns[]?' 2>/dev/null)"
  if [[ -z "$task_arns" ]]; then
    echo "❌ No RUNNING tasks found for service '${service}' in '${cluster}'." >&2
    return 1
  fi

  desc="$(_aws ecs describe-tasks --cluster "$cluster" --tasks $task_arns --output json 2>/dev/null)" || {
    echo "❌ Failed to describe tasks." >&2
    return 1
  }
  selected_task_arn="$(jq -r '.tasks | sort_by(.startedAt) | last | .taskArn // empty' <<<"$desc")"
  if [[ -z "$selected_task_arn" ]]; then
    echo "❌ Could not select a task." >&2
    return 1
  fi
  echo "🆕 Task: $selected_task_arn"

  container_name="$(jq -r --arg svc "$service" '
    ( .tasks | sort_by(.startedAt) | last ) as $t
    | ([$t.containers[] | select(.name==$svc) | .name] + [$t.containers[0].name])[0]
  ' <<<"$desc")"
  if [[ -z "$container_name" || "$container_name" == "null" ]]; then
    echo "❌ Could not determine container name for task." >&2
    return 1
  fi
  echo "🧱 Container: $container_name"

  echo "🚀 Executing: $cmd"
  _aws ecs execute-command \
    --cluster "$cluster" \
    --task "$selected_task_arn" \
    --container "$container_name" \
    --interactive \
    --command "$cmd"
}

# List service names in a cluster
# Usage: ecs-services [-c <cluster>] [-p <profile>]
ecs-services() {
  _ecs_require_bins aws jq || return $?
  local parsed; parsed="$(_ecs_parse_flags "$@")" || return $?
  set -- $parsed
  local cluster; cluster="$(_ecs_resolve_cluster "$ECS_FLAG_CLUSTER")" || return $?
  _aws ecs list-services --cluster "$cluster" | jq -r '.serviceArns[]? | split("/")[-1]'
}

# List clusters (ARNs)
# Usage: ecs-clusters [-p <profile>]
ecs-clusters() {
  _ecs_require_bins aws jq || return $?
  local parsed; parsed="$(_ecs_parse_flags "$@")" || return $?
  set -- $parsed
  _aws ecs list-clusters | jq -r '.clusterArns[]?'
}

# Convenience: list clusters for several profiles at once
ecs-clusters-all() {
  _ecs_require_bins aws jq || return $?
  local profiles=("$@")
  if [[ ${#profiles[@]} -eq 0 ]]; then
    # default list from aliases if none provided
    profiles=( "${(@k)ECSR_PROFILE_ALIAS}" )
  fi
  local p real acct
  for p in "${profiles[@]}"; do
    real="$(_aws_profile_resolve "$p")"
    echo "=== $p ($real) ==="
    acct=$(AWS_PROFILE="$real" aws sts get-caller-identity --query Account --output text 2>/dev/null)
    echo "Account: ${acct:-unknown}"
    AWS_PROFILE="$real" aws ecs list-clusters | jq -r '.clusterArns[]?'
    echo
  done
}
