#!/bin/bash 
display() {
  if [ ! -z ${putit_display_json+x} ]; then 
    cat ${response_file} | jq -r 
  elif [ ! -z ${putit_display_raw_json+x} ]; then 
    cat ${response_file}
  else 
    local csv_file="$(create_tmpfile)"
    cat ${response_file} | jq -r '["Change Name", "Date", "Status", "Applications"],(.[] | [.name, .end_date, .status, ([(.applications_with_versions[] | reduce . as $avw (""; . + $avw.application_with_version.name + ": " + $avw.application_with_version.version + " on environments: " + (reduce $avw.envs[] as $env (""; . + $env.name + " "))))] | join(", "))])
    | @csv' > "${csv_file}"
    display_from_csv_file "${csv_file}"
  fi 
}


