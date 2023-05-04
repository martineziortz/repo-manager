#!/usr/bin/env bash

package="$*"

. `dirname ${BASH_SOURCE[0]}`'/package-include.sh'

python3 ./bin/generate-hash.py -- `./bin/packages/get-package-files.sh "${package}"`