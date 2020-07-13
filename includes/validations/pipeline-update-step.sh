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
                  pipeline-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_pipeline_name=${val}
                      ;;  
                  step-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_step_name=${val}
                      ;;  
                  step-new-name)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_step_new_name=${val}
                      ;;  
                  step-order-action)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_step_order_action=${val}
                      ;;  
                  step-position)
                      val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                      #echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2
                      putit_pipeline_position=${val}
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
  if [ -z ${putit_step_name+x} ] || [ -z ${putit_pipeline_name+x} ]; then
    get_help
    exit 1
  fi
}
