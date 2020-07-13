#!/bin/bash 
display() {
  if [ ! -z ${putit_display_json+x} ]; then 
    cat ${response_file} | jq -r 
  elif [ ! -z ${putit_display_raw_json+x} ]; then 
    cat ${response_file}
  else 
    cat ${response_file} | jq -r '[ "Name", "Latest Version"], (.[] | [(.name | split(" ") | join("%20")),.versions[-1]]) | @sh' | sed "s/'[[:space:]]/,|,/g" | column -s ',' -t  
  fi 
}
