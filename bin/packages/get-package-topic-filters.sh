#!/usr/bin/env bash

package="$*"

. `dirname ${BASH_SOURCE[0]}`'/package-include.sh'

if [[ -z $package ]]; then
    error "No package provided"
    exit 0
fi

yq  -0 '.filter.topics[]' $package_config | xargs -0 -I{} echo 'index("{}")' | paste -sd','
