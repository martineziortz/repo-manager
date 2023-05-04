#!/usr/bin/env bash

package="$*"

. `dirname ${BASH_SOURCE[0]}`'/package-include.sh'

yq  -0 '.filter.topics[]' $package_config | xargs -0 -I{} echo 'index("{}")' | paste -sd','
