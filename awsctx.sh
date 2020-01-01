#!/bin/bash

AWS_SHARED_CREDENTIALS_FILE="${AWS_SHARED_CREDENTIALS_FILE:-$HOME/.aws/credentials}"
#AWSCTX="${XDG_CACHE_HOME:-$HOME/.aws}/awsctx"


_usage() {
  echo "this is usage"
}

_export_profile() {
  export AWS_PROFILE="${1}"
}

_set_profile() {
  _export_profile "${1}"
  echo Switched to profile \""${1}"\"
#  save_profile
}

_get_profiles() {
   sed -n 's/\[\(.*\)\]/\1/p' ${AWS_SHARED_CREDENTIALS_FILE}
}

_list_profiles() {
  local cur prof_list=()
  cur="${AWS_PROFILE-default}"
  prof_list=($(_get_profiles))

  for p in "${prof_list[@]}"; do
    if [[ "${p}" == "${cur}" ]]; then
      echo "${p}" # TODO
    else
      echo "${p}"
    fi
  done
}

_choose_profile_interactive() {
  local choice
  choice=`FZF_DEFAULT_COMMAND="sed -ne 's/\[\(.*\)\]/\1/p' \${AWS_SHARED_CREDENTIALS_FILE} | sed -e 's/default/gggggggggggggggggggg/g'" \
    fzf --ansi`
  _set_profile "${choice}"
}


awsctx() {
  SELF_CMD="$0"

  if [[ "$#" -gt 1 ]]; then
    echo "error: too many arguments" >&2
    _usage
  elif [[ "$#" -eq 1 ]]; then
    if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
      _usag
    elif [[ "${1}" =~ ^-(.*) ]]; then
      echo "error: unrecognized flag \"${1}\"" >&2
      _usage
    else
      _export_profile "${1}"
    fi
  elif [[ "$#" -eq 0 ]]; then
    if [[ -t 1 &&  -z "${AWSCTX_IGNORE_FZF:-}" && "$(type fzf &>/dev/null; echo $?)" -eq 0 ]]; then
      _choose_profile_interactive
    else
      _list_profiles
    fi
  else
    _usage
  fi
}

_export_profile "default"
