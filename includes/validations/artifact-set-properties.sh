#!/bin/bash

parse_args() {
  if [ $# -eq 0 ]; then 
    get_help
    exit 1
  fi   
  optspec=":h-:"
  while getopts "$optspec" optchar; do
      case "${optchar}" in
          -)
              case "${OPTARG}" in
                  art-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2;
                      putit_artifact_name=${val}
                      ;;
                  art-version)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_artifact_version=${val}
                      ;;
                  properties)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      declare -g -A putit_artifact_properties
                      putit_artifact_properties_key=$(echo ${val} | cut -f1 -d=)
                      putit_artifact_properties_value=$(echo ${val} | cut -f2 -d=)
                      local regex="${artifact_properties_regex}"
                      validate $putit_artifact_properties_key $putit_artifact_properties_value
                      putit_artifact_properties["${putit_artifact_properties_key}"]+="${putit_artifact_properties_value}"
                      #echo "Parsing option: '--${OPTARG}', key: ${putit_artifact_properties_key} value: '${putit_artifact_properties_value}'" >&2
                      ;;
                  help)
                      get_help
                      exit 1
                      ;;
                  *) 
                      echo "${optspec:0:1} ${OPTARG}" 
                      #if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                      if [ "$OPTERR" = 1 ]; then
                          echo -e "Unknown option --${OPTARG}\n" >&2
                          get_help  
                          exit 1
                      fi
                      ;;
              esac;;
          h) 
              get_help
              exit 1
              ;;
          *)
              if [ "$OPTERR" = 1 ] || [ "${optspec:0:1}" = ":" ]; then
                  echo "Non-option argument: '-${OPTARG}'" >&2
                  exit 1
              fi
              ;;
      esac
  done
  # obligatory paramas goes here  
  if [ -z ${putit_artifact_name+x} ] || [ -z ${putit_artifact_version+x} ]; then
    get_help
    exit 1
  fi

  # due to the fact that in bash associative array can not be passed to between function we are using file for that.
  putit_artifact_properties_file="$(create_tmpfile)"
  for key in "${!putit_artifact_properties[@]}"; do 
    local key="$(echo ${key} | tr -d ' ')" 
    local value="$(echo ${putit_artifact_properties[$key]} | tr -d ' ')" 
    echo $key
    echo $value
  done | 
  jq -n -R 'reduce inputs as $i ({}; . + { ($i): (input|(tonumber? // .)) })' > $putit_artifact_properties_file
  # end of converting properties into json format

}
