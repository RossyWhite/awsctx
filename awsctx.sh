#!/bin/bash

AWS_SHARED_CREDENTIALS_FILE="${AWS_SHARED_CREDENTIALS_FILE:-$HOME/.aws/credentials}"
AWSCTX="${XDG_CACHE_HOME:-$HOME/.aws}/awsctx"

_usage() {
  echo "this is usage"
}

_export_profile() {
  export AWS_PROFILE="${1}"
}

_persist_profile() {
  echo "${1}" > "${AWSCTX}"
}

_set_profile() {
  _export_profile "${1}"
  _persist_profile "${1}"
  echo Switched to profile \""${1}"\"
}

_list_profiles() {
  local cmd
  cmd="$(_get_fzf_command)"
  eval "${cmd}"
}

_get_fzf_command() {
    echo "sed -ne 's/\[\(.*\)\]/\1/p' ${AWS_SHARED_CREDENTIALS_FILE} | sed -e 's/^\(${AWS_PROFILE}\)$/$(tput setab 0)$(tput setaf 3)\1$(tput sgr0)/g'"
}

_choose_profile_interactive() {
  local choice
  fzf_command="$(_get_fzf_command)"
  choice=`FZF_DEFAULT_COMMAND="${fzf_command}" fzf --ansi`
   _set_profile "${choice}"
}


awsctx() {
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
      _set_profile "${1}"
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

if [[ -f "${AWSCTX}" ]]; then
  cached="$(cat ${AWSCTX})"
  if [[ -n "${cached}" ]]; then
    _export_profile "${cached}"
  fi
fi
