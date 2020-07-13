#!/bin/bash 
display() {
  if [ ! -z ${putit_display_json+x} ]; then 
    cat ${response_file} | jq -r 
  elif [ ! -z ${putit_display_raw_json+x} ]; then 
    cat ${response_file}
  else 
    local csv_file="$(create_tmpfile)"
    cat ${response_file} | jq -r '["Name", "Updated", "Description"], (.[] | [.name, .updated_at, .description]) | @csv' > "${csv_file}" 
    display_from_csv_file "${csv_file}"
  fi 
}
