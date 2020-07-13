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
                  release-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_release_name=${val}
                      ;;
                  change-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_change_name=${val}
                      ;;
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
                  env-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_environment_name=${val}
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
  # obligatory paramas goes here and default values if they have ones
  
  # if change and release names are set make sure that other options are not set. 
  if [ ! -z ${putit_change_name+x} ] && [ ! -z ${putit_release_name+x} ] && ([ -z ${putit_application_name+x} ] && [ -z ${putit_application_version+x} ] && [ -z ${putit_environment_name+x} ]); then 
    putit_deploy_way='change' 
  # if app-name, app-version, env-name are set make sure that change & release names are not set
  elif [ ! -z ${putit_application_name+x} ] && [ ! -z ${putit_application_version+x} ] && [ ! -z ${putit_environment_name+x} ] && ([ -z ${putit_change_name+x} ] && [ -z ${putit_release_name+x} ]); then 
    putit_deploy_way='application' 
  else 
    get_help
    exit 1
  fi
}
