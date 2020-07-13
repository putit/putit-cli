#!/bin/bash
artifact_name_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){1,64}$"
app_name_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[%_-]|\.){1,32}$"
pipeline_name_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){1,32}$"
env_name_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){1,32}$"
pipeline_order_actions_regex="^(insert_at|move_lower|move_higher|move_to_bottom|move_to_top)$"
int_regex="^[0-]|\.{1,10}$"
release_name_regex="^[a-zA-Z0-9_\. -]|\.+$"
change_name_regex="^[a-zA-Z0-9_\. -]|\.+$"
description_regex="^[a-zA-Z0-9_\. -]|\.+$"
application_version_regex="^[a-zA-Z0-9_\.-]+$"
artifact_version_regex="^[a-zA-Z0-9_\.-]+$"
artifact_extension_regex="^flat|maven|git|github|sftp$"

putit_application_semver_term_regex="^major|minor|patch$"
putit_application_semver_build_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){1,32}$"
putit_application_semver_prefix_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){1,32}$"
putit_artifact_semver_term_regex="^major|minor|patch$"
putit_artifact_semver_build_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){1,32}$"
putit_artifact_semver_prefix_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){1,32}$"
artifact_properties_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-\/]|[\.]){1,64}$"
application_properties_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-\/]|[\.]){1,64}$"
putit_username_regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-]|\.{2,4}$"
putit_sshkey_bits_regex="^1024|2048|4096$"
putit_sshkey_type_regex="^DSA|RSA$"
putit_deployuser_username_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){3,32}$"
release_status_regex="^open|closed$"
putit_change_status_regex="^working|waiting_for_approvals|approved|in_deployment|deployed|failed|unknown|closed$"
putit_change_upcoming_regex="^true|false$"
putit_deploy_status_regex="^success|unknown|failure$"
putit_step_name_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){1,32}$"
putit_ip_regex="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
putit_fqdn_regex="^(([a-zA-Z0-]|\.|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"
putit_host_name_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){1,32}$"
putit_sshkey_name_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){3,32}$"
putit_credential_name_regex="^([[:upper:]]|[[:lower:]]|[[:digit:]]|[_-]|\.){3,32}$"

function validate() {
  is_valid=0
  for input_string in `seq 1 $#`; do
    if [[ ${!input_string} =~ ${regex} ]]; then
      is_valid=1
    else 
      log "ERROR" "[validation]: ${!input_string} doesn't match pattern: ${regex}."
      is_valid=0
    fi
    # if at least one or args is not valid exit 
    if [ $is_valid -eq 0 ]; then
      input_is_valid=0
      exit 64
    fi
  done
  input_is_valid=1
}
validate_args_num() {
  declare -a args_nr=$1
  local min_number=$2
  local max_number=$3
  if [ ${args_nr} -ne ${min_number} ] && [ ${args_nr} -ne ${max_number} ]; then
    get_help
    exit 1
  fi
}
