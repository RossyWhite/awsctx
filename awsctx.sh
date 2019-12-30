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
  export_profile "${1}"
#  save_profile
}

_get_profiles() {
  cat "${AWS_SHARED_CREDENTIALS_FILE}" | awk -F"[][]" 'NF>2 {print $2}'
}

_choose_profile_interactive() {
  local choice
  choice="$(_get_profiles | fzf --ansi --no-preview)"
  _export_profile "${choice}"
}


awsctx() {
  if [[ "$#" -gt 1 ]]; then
    echo "error: too many arguments" >&2
    _usage
  elif [[ "$#" -eq 1 ]]; then
    if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
      _usage
    elif [[ "${1}" =~ ^-(.*) ]]; then
      echo "error: unrecognized flag \"${1}\"" >&2
      _usage
    else
      _export_profile "${1}"
    fi
  elif [[ "$#" -eq 0 ]]; then
    if [[ -t 1 &&  -z "${KUBECTX_IGNORE_FZF:-}" && "$(type fzf &>/dev/null; echo $?)" -eq 0 ]]; then
      _choose_profile_interactive
    else
      _get_profiles
    fi
  else
    _usage
  fi
}


_export_profile "default"