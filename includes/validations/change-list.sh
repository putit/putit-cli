#!/bin/bash
# now issue single string comment
parse_args() {
  optspec=":h-:"
  while getopts "$optspec" optchar; do
      case "${optchar}" in
          -)
              case "${OPTARG}" in
                  release-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_release_name=${val}
                      ;;
                  change-status)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_change_status=${val}
                      ;;  
                  change-upcoming)
                      local regex="\-\-.*"
                      if [ -z ${!OPTIND+x} ] || [[ ${!OPTIND} =~ ${regex} ]]; then
                        putit_change_upcoming=true
                      else
                        get_help
                        exit 1
                      fi  
                      ;;  
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
  # obligatory paramas goes here and default values if they have one
}
