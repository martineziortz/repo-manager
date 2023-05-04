#!/usr/bin/env bash

package="$*"

. `dirname ${BASH_SOURCE[0]}`'/package-include.sh'

if [[ -z $package ]]; then
    error "No package provided"
    exit 0
fi

python3 ./bin/generate-hash.py -- `./bin/packages/get-package-files.sh "${package}"`
