#!/usr/bin/env bash

package="$1"
dest_paths_only="${2:-0}"

. `dirname ${BASH_SOURCE[0]}`'/package-include.sh'

if [[ -z "$package" ]]; then
    error "No package provided"
    exit 3
fi

if [[ 1 -eq $dest_paths_only ]]; then
    yq -r '.files | .[]' "${package_config}"
else
    yq -r '.files | keys | "'${package_dir}'/files/" + .[]' "${package_config}"
fi
