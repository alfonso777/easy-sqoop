#!/usr/bin/env bash
#Read named parameters from console that starts with --
while [ $# -gt 0 ]; do
    if [[ $1 == "--"* ]]; then
        parameter="${1/--/}"
        declare $parameter="$2"
    fi
    shift
done

#Read property {2} from configuration file {1}
function get_prop {
  grep "${2}" ${1}.properties|cut -d'=' -f 2-10
}

