#!/bin/bash

parse_args() {
  optspec=":h-:"
  while getopts "$optspec" optchar; do
      case "${optchar}" in
          -)
              case "${OPTARG}" in
                  json)
                      local regex="\-\-.*"
                      if [ -z ${!OPTIND+x} ] || [[ ${!OPTIND} =~ ${regex} ]]; then
                        putit_display_json='true'
                      fi
                      ;;
                  raw-json)
                      local regex="\-\-.*"
                      if [ -z ${!OPTIND+x} ] || [[ ${!OPTIND} =~ ${regex} ]]; then
                        putit_display_raw_json='true'
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
}
