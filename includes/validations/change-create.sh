#!/bin/bash
# now issue single string comment

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
                  change-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_change_name=${val}
                      ;;
                  env-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_change_env_name=${val}
                      ;;
                  release-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_release_name=${val}
                      ;;
                  start-date)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_change_start_date=${val}
                      ;;
                  end-date)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_change_end_date=${val}
                      ;;
                  description)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_change_description=${val}
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
  if [ -z ${putit_release_name+x} ] || [ -z ${putit_change_name+x} ]; then
    get_help
    exit 1
  fi 
  if [ -z ${putit_change_start_date+x} ]; then 
    putit_change_start_date=$(date --date="now" -u +"%Y-%m-%dT%H:%M:%SZ")
  fi
  if [ -z ${putit_change_end_date+x} ]; then
    putit_change_end_date=$(date --date="+2 days" -u +"%Y-%m-%dT%H:%M:%SZ")
  fi
  if [ -z ${putit_change_description+x} ]; then 
    local date=`date '+%Y-%m-%d %H:%M:%S %Z'`
    putit_change_description="Change: ${putit_change_name}, for release: ${putit_release_name} created at ${date}"
  fi 
}
