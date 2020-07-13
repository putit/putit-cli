include_custom_functions() {
  MAIN_SUB_FUNCTION=$(basename -- "$0" | cut -f2 -d"-")
  export PUTIT_CLI_ACTION="${1}"
  if [ -f "${PUTIT_CLI_INSTALL_DIR}/includes/validations/${MAIN_SUB_FUNCTION}-${1}.sh" ]; then
    . ${PUTIT_CLI_INSTALL_DIR}/includes/validations/${MAIN_SUB_FUNCTION}-${1}.sh
  fi
  if [ -f "${PUTIT_CLI_INSTALL_DIR}/includes/display/${MAIN_SUB_FUNCTION}-${1}.sh" ]; then
    . ${PUTIT_CLI_INSTALL_DIR}/includes/display/${MAIN_SUB_FUNCTION}-${1}.sh
  fi
}

generate_usage() {
  local main_sub_function=$(basename -- "$0" | cut -f2 -d"-")
  local usage_file="${PUTIT_CLI_INSTALL_DIR}/includes/usage/${main_sub_function}.txt"
  if [ -f ${usage_file} ]; then 
    printf "[${main_sub_function}] available commands:\n"
    length_longest_command=$(awk -F ";" '{print $1}' ${usage_file} | awk '{ if ( length > x ) { x = length } }END{ print x }')
    # show all usage or only for given cli_command
    OLD_IFS="$IFS"
    while IFS=";" read -r cli_command description; do
      if [ ! -z "${PUTIT_CLI_ACTION+x}" ] && [[ "${cli_command}" =~ ${PUTIT_CLI_ACTION} ]]; then 
        printf "\t%-${length_longest_command}s %-s\n" "$cli_command" "$description"
      elif [  -z "${PUTIT_CLI_ACTION+x}" ]; then  
        printf "\t%-${length_longest_command}s %-s\n" "$cli_command" "$description"
      fi
    done < ${usage_file}
    IFS="$OLD_IFS"
  else 
    log "ERROR" "Wrong usage of command: putit ${main_sub_function}. Missing usage file here, sorry for this we will fix it."
  fi
}

check_bash_ver() {
  PUTIT_BASH_MAJOR_VER=$(bash --version | head -1 | egrep -o "version [0-9]" | awk '{print $2}')
  if [ "${PUTIT_BASH_MAJOR_VER}" != '4' ] || [ "${PUTIT_BASH_MAJOR_VER}" != '3' ]; then 
     log "ERROR" "Unsupported bash version: ${PUTIT_BASH_MAJOR_VER}" 
     exit 1
  fi
}

check_os() {
  regex='centos|ubuntu|redhat|amazon|fedora|debian'
  # platform 
  UNAME=$(uname | tr "[:upper:]" "[:lower:]")
  if [ "${UNAME}" == "linux" ]; then
    # Ubuntu family 
    if [ -f /etc/lsb-release ]; then
      OS_PLATFORM=$(cat /etc/lsb-release | cut -d= -f2 | head -1 | tr "[:upper:]" "[:lower:]")
      # RedHat/CentOS family 
    elif [ -f /etc/system-release ]; then
      OS_PLATFORM=$(cat /etc/system-release | cut -f 1 -d " " | tr "[:upper:]" "[:lower:]" )
    else
      OS_PLATFORM="${UNAME}"
    fi  
  elif [ "${UNAME}" == "darwin" ]; then
    OS_PLATFORM="${UNAME}"
  fi  

  if [[ "$OS_PLATFORM" =~ $regex ]]  ; then
    export PUTIT_CLI_PLATFORM='linux'
  elif [[ "$OS_PLATFORM" =~ darwin ]]; then
    export PUTIT_CLI_PLATFORM='darwin'
  else
    export PUTIT_CLI_PLATFORM='unknown'
    echo "[ERROR] Unsupported OS platfrom: ${OS_PLATFORM}"
    exit 1
  fi  
}

read_password() {
  while true; do
    read -s -p "Password: " password
    echo
    read -s -p "Password (again): " password2
    echo
    if [ "$password" = "$password2" ]; then 
      user_password="${password}"
      user_password_confirmation="${password}"
      break;
    fi
    echo "Password doesn't match, please try again."
  done
}

log() {
  local sub_command=$(basename "$0" | cut -d'-' -f2)
  local level=$1
  local msg=$2
  if [ -z ${APP_USER+x} ]; then
    local app_user='-'
  else 
    local app_user="${APP_USER}"
  fi
  local log_event_to_rsyslog="[${app_user}] [$level] [$sub_command] $msg"
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

create_tmpfile() {
  if [ "${PUTIT_CLI_PLATFORM}" == 'darwin' ]; then 
    local tmpfile="$(mktemp -t ${APP_USER}.${APP_USER_GID}XXXXXXXXXXXXXXXXX 2>/dev/null)"
  else
    local dir_temp_prefix="/tmp"
    mkdir -p ${dir_temp_prefix}
    local tmpfile="$(mktemp -p ${dir_temp_prefix} -t ${APP_USER}.${APP_USER_GID}XXXXXXXXXXXXXXXXX 2>/dev/null)"
  fi
      
  if [ -f ${tmpfile} ]; then 
    echo "${tmpfile}"
  else 
    log "ERROR" "Can't create temp file: ${tmpfile}, exiting..."
    exit 1
  fi
}

create_tmpdir() {
  if [ "${PUTIT_CLI_PLATFORM}" == 'darwin' ]; then 
    local tmpdir="$(mktemp -d -t ${APP_USER}.${APP_USER_GID}XXXXXXXXXXXXXXXXX 2>/dev/null)"
  else
    local dir_temp_prefix="/tmp"
    mkdir -p ${dir_temp_prefix}
    local tmpdir="$(mktemp -p ${dir_temp_prefix} -d -t ${APP_USER}.${APP_USER_GID}XXXXXXXXXXXXXXXXX 2>/dev/null)"    
  fi

  if [ -d ${tmpdir} ]; then 
    echo "${tmpdir}"
  else 
    log "ERROR" "Can't create temp dir: ${tmpdir}, exiting..."
    exit 1
  fi
}

clean_tmp() {
  # get last element of array and remove it
  declare -a files=$@
  for last_arg in $files; do :; done
  local files=${files[@]//force/}

  if [ -z ${PUTIT_DEBUG_CLI+x} ] || [[ "${last_arg}" == "force" ]]; then
    for to_remove in ${files}; do 
      if [ -f "${to_remove}" ]; then 
          rm -f "${to_remove}"
          log "DEBUG" "Removed temp file: $to_remove"
      elif [ -d "${to_remove}" ]; then 
          # only place where we use temp dir structure is step import for git. If it won't come anywhere else remove commented lines
          #rm -fr ${to_remove} || log "ERROR" "Can't remove temp dir: $to_remove"
          #log "DEBUG" "Removed temp dir: $to_remove"
          log "WARN" "$to_remove it's directory will skip it."
      else 
          true
      fi
    done
  else
    log "DEBUG" "Debug is on, skiping tmpfiles clean."
  fi
}

is_env_present() {
  local app_name=$1
  local env_name=$2
  is_env=$(${PUTIT_CURL} /dev/null -I ${PUTIT_URL}/application/${app_name}/envs/${env_name})
  if [ ! -z ${is_env+x} ] && [ "${is_env}" == "200" ]; then 
    true
  else
    log "ERROR" "No such environment: ${env_name} for application: ${app_name}"
    exit 1
  fi
}

is_empty_json_array() {
  response_file="${1}"
  array_name="${2}"
  json_length=$(jq ".${array_name} | length" ${response_file})
  if [ ${json_length} -eq 0 ]; then 
    true
  else
    false
  fi
}

is_empty_response() {
  response_file="${1}"
  
  log "DEBUG" "Begining of checking if response file ${response_file} contains body and it's a valid JSON."  
  if [[ ! -z ${response_file+x} && -f ${response_file} ]]; then
    # can't use local here becaue of capturing exit code
    json_length=$(jq -e length ${response_file} 2>/dev/null)
    exit_code=$?
  fi
  # response is valid json and it's empty
  if [[ "${json_length}" -eq "0" && ${exit_code} -eq 0 ]]; then
    log "DEBUG" "Response file body is in JSON format but it's empty: ${response_file}"  
    true
  # response is not a valid json
  elif [[ ${exit_code} -ne 0 ]]; then
    log "ERROR" "Response file is not in JSON format: ${response_file}."  
    exit 1
  # response is valid json but not empty array 
  else
    log "DEBUG" "Response file is not empty and it's in JSON format: ${response_file}."
    false
  fi 
}

display_from_csv_file() {
  local csv_file="$1"
  if [ -f ${csv_file} ]; then 
    putit_cli_display -file "${csv_file}" 
    clean_tmp "${csv_file}"
  else 
    log "ERROR" "Missing csv_file: ${csv_file}, please try again."
  fi  
}

send_request() {
  request_cmd=${1}
  response_file="${2}"

  log "DEBUG" "${request_cmd}"

  # send request to putit core or auth server, if it fails just echo to pass 000 status code further
  response_code=$(${request_cmd} || echo)
  # when there is respone file with some content 
  if ([[ ! -z ${response_file+x} && -f ${response_file} && -s ${response_file} ]]) && [ ! -z ${response_code} ]; then
    # catch 5XX errors witch saved some output to response_file 
    if [[ $response_code =~ ^5[0-9][0-9]$ ]]; then 
      log "ERROR" "HTTP code from server: ${response_code}, response message: $(cat ${response_file} | jq -r .msg 2>/dev/null)"
      exit 1
    # catch 4XX errors witch saved some outout to response_file
    elif [[ $response_code =~ ^4[0-9][0-9]$ ]]; then 
      log "ERROR" "HTTP code from server: ${response_code}, response message: $(cat ${response_file} | jq -r .msg 2>/dev/null)"
      exit 1
    # catch 2XX correct responses witch saved some output to response_file
    elif [[ $response_code =~ ^2[0-9][0-9]$ ]]; then
      log "DEBUG" "HTTP code from server: ${response_code}, response body in file: ${response_file}"
    fi
  # error if we got 401 
  elif [[ $response_code == 401 ]]; then  
    log "ERROR" "Authorization required - missing or invalid auth token. Please login first."
    exit 1
  # errors when there was not output saved to response_file
  elif [[ $response_code =~ ^(5[0-9][0-9]|4[0-9][0-9])$ ]]; then
    log "ERROR" "HTTP code from server: ${response_code}, sorry no additional information could be provided."
    exit 1
  # 2XX reponse and there is no response_file
  elif [[ $response_code =~ ^(2[0-9][0-9])$ ]]; then
      log "DEBUG" "HTTP code from server: ${response_code}, sorry no additional information could be provided."
  # if curl failed, will be catch here
  elif [ "$response_code" == '000' ]; then   
      log "ERROR" "Request to server has failed, please make sure that servers: ${PUTIT_URL} and ${PUTIT_AUTH_URL} are up and running."
      exit 1
  elif [ "$2" == "/dev/stdout" ]; then 
      log "INFO" "Display on stdout"
  else 
      log "ERROR" "Unknown error while processing request: ${request_cmd}"
      exit 1
  fi
  if [ ! -z ${payload_file+x} ]; then
    clean_tmp "${payload_file}"
  fi
}
