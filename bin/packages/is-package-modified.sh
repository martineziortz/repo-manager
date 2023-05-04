#!/usr/bin/env bash

package="$*"
bindir=`dirname ${BASH_SOURCE[0]}`

. $bindir'/package-include.sh'

if [[ -z "$package" ]]; then
    error "No package provided"
    exit 3
fi

hash=$($bindir/get-package-hash.sh "$package")
hash_file="$hash_dir/$hash.sha1"

[[ ! -f $hash_file ]] || exit 1
