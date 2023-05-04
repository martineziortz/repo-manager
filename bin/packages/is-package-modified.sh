#!/usr/bin/env bash

package="$*"
bindir=`dirname ${BASH_SOURCE[0]}`

. $bindir'/package-include.sh'

hash=$($bindir/get-package-hash.sh "$package")
hash_file="$hash_dir/$hash.sha1"

[[ ! -f $hash_file ]] || exit 1
