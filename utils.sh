#!/usr/bin/env bash
#Read named parameters
while [ $# -gt 0 ]; do
    if [[ $1 == "--"* ]]; then
        parameter="${1/--/}"
        declare $parameter="$2"
    fi
    shift
done

#Read properties
function get_prop {
  grep "${2}" ${1}.properties|cut -d'=' -f 2-10
}

