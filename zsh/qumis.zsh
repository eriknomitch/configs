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

########################################################################
# AWS + ECS Zsh Toolkit (long names, array-safe)
# Save as: ~/.zsh/aws-ecs-tools.zsh
# Add to ~/.zshrc:
#   [[ -f "$HOME/.zsh/aws-ecs-tools.zsh" ]] && source "$HOME/.zsh/aws-ecs-tools.zsh"
########################################################################

# ------------------------------- Config -------------------------------

# Profiles that require extra caution (confirmed on use; red prompt badge)
typeset -ga ECSR_PROTECTED_PROFILES
ECSR_PROTECTED_PROFILES=( qumis_prod )

# Optional: profile aliases (short -> real). Not auto-used unless you call _aws_profile_resolve.
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
  local missing=() bin
  for bin in "$@"; do command -v "$bin" >/dev/null 2>&1 || missing+=("$bin"); done
  (( ${#missing[@]} )) && { print -ru2 -- "❌ Missing dependencies: ${missing[*]}"; return 127; }
}

_aws_profile_resolve() {
  local p="$1"; print -r -- "${ECSR_PROFILE_ALIAS[$p]:-$p}"
}

_ecs_in_array() {
  local needle="$1"; shift
  local x; for x in "$@"; do [[ "$x" == "$needle" ]] && return 0; done
  return 1
}

# Parse -c/--cluster and -p/--profile into globals:
#   ECS_FLAG_CLUSTER, ECS_FLAG_PROFILE, ECS_FLAG_REST (array of remaining args)
typeset -ga ECS_FLAG_REST
_ecs_parse_flags() {
  typeset -g ECS_FLAG_CLUSTER=""
  typeset -g ECS_FLAG_PROFILE=""
  ECS_FLAG_REST=()

  while (( $# > 0 )); do
    case "$1" in
      -c|--cluster)
        [[ -z "$2" ]] && { print -ru2 -- "❌ -c/--cluster requires a value"; return 2; }
        ECS_FLAG_CLUSTER="$2"; shift 2 ;;
      -p|--profile)
        [[ -z "$2" ]] && { print -ru2 -- "❌ -p/--profile requires a value"; return 2; }
        ECS_FLAG_PROFILE="$2"; shift 2 ;;
      --)
        shift; ECS_FLAG_REST+=("$@"); return 0 ;;
      -*)
        print -ru2 -- "❌ Unknown flag: $1"; return 2 ;;
      *)
        ECS_FLAG_REST+=("$1"); shift ;;
    esac
  done
  return 0
}

_ecs_whoami_banner() {
  local prof="$1" acct arn
  acct=$(AWS_PROFILE="$prof" aws sts get-caller-identity --query Account --output text 2>/dev/null)
  arn=$(AWS_PROFILE="$prof" aws sts get-caller-identity --query Arn --output text 2>/dev/null)
  if [[ -n "$acct" && "$acct" != "None" ]]; then
    print -r -- "🔑 AWS profile: $prof   Account: $acct"
    print -r -- "   ARN: $arn"
  else
    print -r -- "🔑 AWS profile: $prof   (unable to resolve account — are you logged in?)"
  fi
}

# Resolve cluster: explicit -> env var -> per-profile map -> discover by service
_ecs_resolve_cluster() {
  local cluster_in="$1" service="$2"
  if [[ -n "$cluster_in" ]]; then print -r -- "$cluster_in"; return 0; fi
  if [[ -n "$ECSR_DEFAULT_CLUSTER" ]]; then print -r -- "$ECSR_DEFAULT_CLUSTER"; return 0; fi
  if [[ -n "$ECSR_ACTIVE_PROFILE" ]]; then
    local mapped="${ECSR_DEFAULT_CLUSTER_BY_PROFILE[$ECSR_ACTIVE_PROFILE]}"
    [[ -n "$mapped" ]] && { print -r -- "$mapped"; return 0; }
  fi
  [[ -z "$service" ]] && { print -ru2 -- "❌ No cluster specified and no service provided for discovery."; return 1; }

  local clusters ds svc_stat running_count found=""
  clusters="$(_aws ecs list-clusters --output json | jq -r '.clusterArns[]?' 2>/dev/null)"
  [[ -z "$clusters" ]] && { print -ru2 -- "❌ No ECS clusters found."; return 1; }

  local c
  for c in $clusters; do
    ds="$(_aws ecs describe-services --cluster "$c" --services "$service" --output json 2>/dev/null)" || ds=""
    [[ "$(jq -r '.services | length' <<<"$ds")" == "0" ]] && continue
    svc_stat="$(jq -r '.services[0].status // empty' <<<"$ds")"
    running_count="$(jq -r '.services[0].runningCount // 0' <<<"$ds")"
    if [[ "$svc_stat" == "ACTIVE" ]]; then
      found="$c"; (( running_count > 0 )) && { print -r -- "$found"; return 0; }
    fi
  done
  [[ -z "$found" ]] && { print -ru2 -- "❌ Could not find an ACTIVE ECS service named '${service}' in any cluster."; return 1; }
  print -r -- "$found"
}

# AWS CLI wrapper: prefers ECSR_ACTIVE_PROFILE, then command flag
_aws() {
  local prof="${ECSR_ACTIVE_PROFILE:-$ECS_FLAG_PROFILE}"
  if [[ -n "$prof" ]]; then
    _ecs_in_array "$prof" "${ECSR_PROTECTED_PROFILES[@]}" && print -ru2 -- "🔒 [protected:${prof}] aws $*"
    AWS_PROFILE="$prof" aws "$@"
  else
    aws "$@"
  fi
}

# --------------------------- Prompt Badge -----------------------------

_ecs_update_rprompt() {
  local p="$ECSR_ACTIVE_PROFILE" badge=""
  if [[ -n "$p" ]]; then
    if _ecs_in_array "$p" "${ECSR_PROTECTED_PROFILES[@]}"; then
      badge="%F{red}[AWS:${p}]%f"
    else
      badge="%F{blue}[AWS:${p}]%f"
    fi
  fi
  RPROMPT="$badge"
}
if ! typeset -f _ecs_precmd_hook_installed >/dev/null; then
  _ecs_precmd_hook_installed() { :; }
  autoload -Uz add-zsh-hook 2>/dev/null || true
  add-zsh-hook precmd _ecs_update_rprompt 2>/dev/null || true
fi

# ------------------------- SSO + Sessions -----------------------------

aws-sso-and-export() {
  local profile="${1:-$QUMIS_INFRA_AWS_PROFILE}"
  [[ -z "$profile" ]] && { print -ru2 -- "Usage: aws-sso-and-export <profile>"; return 2; }
  _ecs_require_bins aws || return $?

  print -r -- "🔐 aws sso login --profile ${profile}"
  aws sso login --profile "$profile" || { print -ru2 -- "❌ SSO login failed for profile: ${profile}"; return 1; }

  print -r -- "📤 Exporting temporary credentials into this shell..."
  local exports
  exports="$(aws configure export-credentials --profile "$profile" --format env)" || { print -ru2 -- "❌ Failed to obtain credentials for profile: ${profile}"; return 1; }
  eval "$exports"
  export AWS_PROFILE="$profile"
  print -r -- "✅ Exported creds for '${profile}'. Expiration: ${AWS_CREDENTIAL_EXPIRATION:-unknown}"
}

# Session-aware wrapper:
#   aws-session use  <profile>
#   aws-session shell <profile>
#   aws-session run  <profile> -- CMD
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
  aws-session run  <profile> -- <command...>  # SSO login, run one command with profile
USAGE
      return 2 ;;
  esac

  local prof="$1"; [[ -z "$prof" ]] && { print -ru2 -- "❌ Missing <profile>"; return 2; }
  shift || true

  if _ecs_in_array "$prof" "${ECSR_PROTECTED_PROFILES[@]}"; then
    print -r -- "⚠️  You're targeting PROTECTED profile: '$prof'."
    local _ecs_confirm
    vared -p "Type the profile name to confirm: " -c _ecs_confirm 2>/dev/null || read "?Type the profile name to confirm: " _ecs_confirm
    [[ "$_ecs_confirm" != "$prof" ]] && { print -r -- "❌ Not switching."; return 1; }
  fi

  print -r -- "🔐 aws sso login --profile ${prof}"
  aws sso login --profile "$prof" || { print -ru2 -- "❌ SSO login failed for profile: ${prof}"; return 1; }

  case "$mode" in
    use)
      ECSR_ACTIVE_PROFILE="$prof"
      _ecs_whoami_banner "$prof"
      _ecs_update_rprompt
      print -r -- "✅ Session profile set: $prof (prompt badge updated)" ;;
    shell)
      print -r -- "🧭 Starting subshell with AWS_PROFILE=$prof"
      _ecs_whoami_banner "$prof"
      ECSR_ACTIVE_PROFILE="$prof" AWS_PROFILE="$prof" zsh
      print -r -- "🔚 Left subshell for profile: $prof" ;;
    run)
      [[ "$1" == "--" ]] && shift
      (( $# == 0 )) && { print -ru2 -- "❌ Usage: aws-session run <profile> -- <command...>"; return 2; }
      _ecs_whoami_banner "$prof"
      ECSR_ACTIVE_PROFILE="$prof" AWS_PROFILE="$prof" "$@" ;;
  esac
}

# --------------------------- ECS Commands -----------------------------

# Run a command in the newest running task for a service (ECS Exec)
# Usage:
#   ecs-run [-c <cluster>] [-p <profile>] <service> -- <command...>
#   ecs-run [-c <cluster>] [-p <profile>] <service> <command...>
ecs-run() {
  _ecs_require_bins aws jq || return $?

  _ecs_parse_flags "$@" || return $?
  set -- "${ECS_FLAG_REST[@]}"

  if (( $# < 2 )); then
    print -ru2 -- "Usage: ecs-run [-c <cluster>] [-p <profile>] <service> [--] <command...>"
    return 1
  fi

  local service="$1"; shift
  [[ "$1" == "--" ]] && shift
  (( $# == 0 )) && { print -ru2 -- "Usage: ecs-run [-c <cluster>] [-p <profile>] <service> [--] <command...>"; return 1; }

  local -a cmd_argv; cmd_argv=("$@")
  local cmd_str="${(j: :)cmd_argv}"

  print -r -- "🔎 Discovering cluster for service '${service}'..."
  local cluster; cluster="$(_ecs_resolve_cluster "$ECS_FLAG_CLUSTER" "$service")" || return $?
  print -r -- "📍 Cluster: $cluster"

  local who_prof="${ECSR_ACTIVE_PROFILE:-$ECS_FLAG_PROFILE:-${AWS_PROFILE:-}}"
  [[ -n "$who_prof" ]] && _ecs_whoami_banner "$who_prof"

  print -r -- "📦 Locating running task for '${service}'..."
  local task_arns desc selected_task_arn container_name
  task_arns="$(_aws ecs list-tasks --cluster "$cluster" --service-name "$service" --desired-status RUNNING --output json | jq -r '.taskArns[]?' 2>/dev/null)"
  [[ -z "$task_arns" ]] && { print -ru2 -- "❌ No RUNNING tasks found for service '${service}' in '${cluster}'."; return 1; }

  desc="$(_aws ecs describe-tasks --cluster "$cluster" --tasks $task_arns --output json 2>/dev/null)" || { print -ru2 -- "❌ Failed to describe tasks."; return 1; }
  selected_task_arn="$(jq -r '.tasks | sort_by(.startedAt) | last | .taskArn // empty' <<<"$desc")"
  [[ -z "$selected_task_arn" ]] && { print -ru2 -- "❌ Could not select a task."; return 1; }
  print -r -- "🆕 Task: $selected_task_arn"

  container_name="$(jq -r --arg svc "$service" '
    ( .tasks | sort_by(.startedAt) | last ) as $t
    | ([$t.containers[] | select(.name==$svc) | .name] + [$t.containers[0].name])[0]
  ' <<<"$desc")"
  [[ -z "$container_name" || "$container_name" == "null" ]] && { print -ru2 -- "❌ Could not determine container name for task."; return 1; }
  print -r -- "🧱 Container: $container_name"

  print -r -- "🚀 Executing: $cmd_str"
  _aws ecs execute-command \
    --cluster "$cluster" \
    --task "$selected_task_arn" \
    --container "$container_name" \
    --interactive \
    --command "$cmd_str"
}

# List service names in a cluster
# Usage: ecs-services [-c <cluster>] [-p <profile>]
ecs-services() {
  _ecs_require_bins aws jq || return $?
  _ecs_parse_flags "$@" || return $?
  set -- "${ECS_FLAG_REST[@]}"
  local cluster; cluster="$(_ecs_resolve_cluster "$ECS_FLAG_CLUSTER")" || return $?
  _aws ecs list-services --cluster "$cluster" | jq -r '.serviceArns[]? | split("/")[-1]'
}

# List clusters (ARNs)
# Usage: ecs-clusters [-p <profile>]
ecs-clusters() {
  _ecs_require_bins aws jq || return $?
  _ecs_parse_flags "$@" || return $?
  set -- "${ECS_FLAG_REST[@]}"
  _aws ecs list-clusters | jq -r '.clusterArns[]?'
}

# Convenience: list clusters for several profiles at once
ecs-clusters-all() {
  _ecs_require_bins aws jq || return $?
  local profiles=("$@")
  (( ${#profiles[@]} == 0 )) && profiles=( "${(@k)ECSR_PROFILE_ALIAS}" )
  local p real acct
  for p in "${profiles[@]}"; do
    real="$(_aws_profile_resolve "$p")"
    print -r -- "=== $p ($real) ==="
    acct=$(AWS_PROFILE="$real" aws sts get-caller-identity --query Account --output text 2>/dev/null)
    print -r -- "Account: ${acct:-unknown}"
    AWS_PROFILE="$real" aws ecs list-clusters | jq -r '.clusterArns[]?'
    print -r -- ""
  done
}
