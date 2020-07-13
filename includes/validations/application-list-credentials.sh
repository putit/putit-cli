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
                  app-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2;
                      putit_application_name=${val}
                      ;;
                  env-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_environment_name=${val}
                      ;;
                  raw-json)
                      local regex="\-\-.*"
                      if [ -z ${!OPTIND+x} ] || [[ ${!OPTIND} =~ ${regex} ]]; then
                        putit_display_raw_json='true'
                      fi  
                      ;;
                  json)
                      local regex="\-\-.*"
                      if [ -z ${!OPTIND+x} ] || [[ ${!OPTIND} =~ ${regex} ]]; then
                        putit_display_json='true'
                      fi  
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
  if [ -z ${putit_application_name+x} ] || [ -z ${putit_environment_name+x} ]; then
    get_help
    exit 1
  fi
}
