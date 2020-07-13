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
                  app-version)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2;
                      putit_application_version=${val}
                      ;;
                  art-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_artifact_name=${val}
                      ;;
                  art-version)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_artifact_version=${val}
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
  if [ -z ${putit_application_name+x} ] || [ -z ${putit_artifact_name+x} ] || [ -z ${putit_artifact_version+x} ] || [ -z ${putit_application_version+x} ]; then
    get_help
    exit 1
  fi
}
