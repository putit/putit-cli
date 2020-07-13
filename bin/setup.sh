#!/bin/bash
set -ue 

abspath() {
  # generate absolute path from relative path
  # $1     : relative filename
  # return : absolute path
  if [ -d "$1" ]; then
    # dir
    (cd "$1"; pwd)
  elif [ -f "$1" ]; then
    # file
    if [[ $1 == */* ]]; then
      echo "$(cd "${1%/*}"; pwd)/${1##*/}"
    else
      echo "$(pwd)/$1"
    fi
  fi
}

function load_common_functions {
  local bin_dir="$(dirname $(abspath $0))"
  local common_functions_file="${bin_dir%bin}includes/common-functions.sh"
  if [ -f ${common_functions_file} ]; then 
    . ${common_functions_file}
  else 
    echo "[ERROR] Unable to load common_functions.sh file."
    exit 1
  fi  
}

log() {
  local sub_command=$(basename "$0" | cut -d'-' -f2)
  local level=$1
  local msg=$2
  local log_event_to_rsyslog="[$level] [$sub_command] $msg"
  local log_event_to_console="[$level] [$sub_command] $msg"
  local logger="logger -t putit-cli"
 
  # drop debug messages when PUTIT_DEBUG_CLI is not set 
  if [ $level == 'DEBUG' ] && [ -z ${PUTIT_DEBUG_CLI+x} ]; then 
    echo > /dev/null 
  # when putit should NOT log on console but it shoud log into rsyslog
  elif [[ ! -z ${PUTIT_CLI_DISABLE_LOG_CONSOLE+x} && "${PUTIT_CLI_DISABLE_LOG_CONSOLE}" == "1" && ! -z ${PUTIT_CLI_LOG_RSYSLOG+x} && "${PUTIT_CLI_LOG_RSYSLOG}" == "1" ]] ; then 
    ${logger} "$log_event_to_file"
  # when console log is not disabled and rsyslog log is enabled 
  elif  [[ ! -z ${PUTIT_CLI_LOG_RSYSLOG+x} && "${PUTIT_CLI_LOG_RSYSLOG}" == "1"  ]]; then
    echo "$log_event_to_console"
    ${logger} "$log_event_to_rsyslog" 
  # all the rest - log into console
  else 
    echo "$log_event_to_console"
  fi
}

check_binaries() {
  local bin_name=$1
  log "INFO" "Checking if ${bin_name} is installed..."
  if  type ${bin_name} >/dev/null 2>&1 ; then 
    log "INFO" "Found ${bin_name}."
  # here comes binaries that putit team can provide
  elif [ "${bin_name}" == 'jo' ] || [ "${bin_name}" == 'jq' ]; then 
    fetch_file ${bin_name}
  else
    log "ERROR" "Missing $bin_name. Please install."
    exit 1
  fi
}

# set putit gem home and add putit gem bin to the path
set_vars() {
  APP_USER=$(whoami)
  APP_GROUP="${APP_USER}"
  SCRIPT_NAME=$(basename $0)
  ARCH=$(uname -m)

  local script_dir=$(dirname $(abspath $0))
  export PUTIT_APP_DIR="${script_dir%/bin}"
  export PUTIT_LOG_DIR="${PUTIT_APP_DIR}/log"
  export PUTIT_CLI_CONF="${PUTIT_APP_DIR}/conf/putit-cli.conf"
  export PUTIT_CLI_CONF_DEFAULT="${PUTIT_APP_DIR}/conf/putit-cli.conf.default"
  export PUTIT_LOG_FILE="${PUTIT_APP_DIR}/log/install.log"

  log "DEBUG" "Set \$APP_USER: $APP_USER"
  log "DEBUG" "Set \$APP_GROUP: $APP_GROUP"
  log "DEBUG" "Set \$PUTIT_APP_DIR: $PUTIT_APP_DIR"

  log "INFO" "Variables are set up."
}

fetch_file() {
  local file_found=0
  local file_name=$1
  local file_dest_path="${PUTIT_APP_DIR}/bin/${file_name}"
  local putit_download_url="https://download.putit.io/bin/$ARCH"
  
  # check if file is alrady not under the ${$PUTIT_APP_DIR}/bin
  if [ ! -f ${file_dest_path} ]; then  
    http_code=$(curl -q --write-out %{http_code} -L --silent --fail ${putit_download_url}/${file_name} --output ${file_dest_path}) || log "ERROR" "Unable to fetch: $file_name."
    if [ ! -z ${http_code+x} ] && [ ${http_code} -eq 200 ]; then
      log "INFO" "[${SCRIPT_NAME}] File: ${file_name} has been saved as ${file_dest_path}."
      chmod 0755 ${file_dest_path}
      log "INFO" "Permissions 0755 set for ${file_dest_path}"
    else
      log "ERROR" "Unable to fetch $file_name from $putit_download_url, please try again later or contact with support@putit.io"
      exit 1
    fi
  else
    log "INFO" "$file_name exist: ${file_dest_path}"
    chmod 0750 ${file_dest_path}
    log "INFO" "Permissions 0750 set for ${file_dest_path}"
  fi
}

set_config() {
  if [ -f ${PUTIT_CLI_CONF} ]; then 
    log "INFO" "Config file: ${PUTIT_CLI_CONF} already exisit."  
  elif [ ! -f ${PUTIT_CLI_CONF} ] && [ -f ${PUTIT_CLI_CONF_DEFAULT} ]; then
    log "INFO" "Copying default config as a currnet one."
    /bin/cp ${PUTIT_CLI_CONF_DEFAULT} ${PUTIT_CLI_CONF}
    if [[ ${PUTIT_CLI_PLATFORM} == 'darwin' ]]; then 
      echo "DARWIN"
      sed -i'.orignal' -e s,/opt/putit/putit-cli,$PUTIT_APP_DIR, ${PUTIT_CLI_CONF}
    else  
      sed -e s,/opt/putit/putit-cli,$PUTIT_APP_DIR, -i ${PUTIT_CLI_CONF}
    fi  
  else 
    log "ERROR" "${PUTIT_CLI_CONF} doesn't exisit and default one: ${PUTIT_CLI_CONF_DEFAULT} is missing."
    exit 1
  fi
}

set_PATH() {
  local is_set=$(grep -c "$PUTIT_APP_DIR" ${HOME}/.bash_profile)
  log "INFO" "Setting PATH variable..."
  if [ "${is_set}" == "0" ]; then
    if [[ ${PUTIT_CLI_PLATFORM} == 'darwin' ]]; then
      sed -i'.orignal' -e "s,PATH=\(.*\),PATH=\1:${PUTIT_APP_DIR}/bin,"g $HOME/.bash_profile
    else
      sed -e "s,PATH=\(.*\),PATH=\1:${PUTIT_APP_DIR}/bin,"g -i $HOME/.bash_profile
    fi
  fi
}

set_vars
load_common_functions
check_os
check_binaries 'curl'
check_binaries 'jo'
check_binaries 'jq'
set_config
set_PATH

log "INFO" "Please add into your \$PATH: ${PUTIT_APP_DIR}/bin"
echo -e "For example in $HOME/.bash_profile:\n"
echo -e "\texport PATH=${PUTIT_APP_DIR}/bin:\$PATH\n"
