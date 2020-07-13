#!/bin/bash 
display() {
  if [ ! -z ${putit_display_json+x} ]; then 
    cat ${response_file} | jq -r 
  elif [ ! -z ${putit_display_raw_json+x} ]; then 
    cat ${response_file}
  elif [ ! -z ${putit_deploy_status_by_app+x} ]; then
    local csv_file="$(create_tmpfile)"
    #cat ${response_file} | jq -r '["Env", "Version", "Deploy Status", "Deploy Date", "Change Name", "Release Name", "Deploy Logs"], (to_entries | .[] | [.value.env, .value.version, .value.status, .value.deployment_date, .value.change, .value.release, .value.log_url]) | @csv' > "${csv_file}"
    cat ${response_file} | jq -r '["Env", "Version", "Deploy Status", "Deploy Date", "Deploy Logs"], (to_entries | .[] | [.value.env, .value.version, .value.status, .value.deployment_date, .value.log_url]) | @csv' > "${csv_file}"
    display_from_csv_file "${csv_file}"
  elif [ ! -z ${putit_deploy_status_by_env+x} ]; then 
    local csv_file="$(create_tmpfile)"
    cat ${response_file} | jq -r '["Env", "Version", "Deploy Status", "Deploy Date", "Deploy Logs"], ([ .env, .version, .status, .deployment_date, .log_url ]) | @csv' > "${csv_file}" 
    display_from_csv_file "${csv_file}"
  elif [ ! -z ${putit_deploy_status_by_change+x} ]; then 
    local csv_file="$(create_tmpfile)"
    cat ${response_file} | jq -r '["Env", "Version", "Deploy Status", "Deploy Date", "Change Name", "Release Name", "Deploy Logs"], ([ .env, .version, .status, .deployment_date, .change, .release, .log_url ]) | @csv' > "${csv_file}" 
    display_from_csv_file "${csv_file}"
  else
    cat ${response_file} | jq -r '.deploy_status'
  fi 
}
