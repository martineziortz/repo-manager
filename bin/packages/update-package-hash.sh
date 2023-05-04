#!/usr/bin/env bash

package="$*"
bindir=`dirname ${BASH_SOURCE[0]}`
. $bindir'/is-package-modified.sh' "$package"

echo "Adding new hash for $package: $hash"
[ -d "$hash_dir" ] || mkdir "$hash_dir"
echo $hash > $hash_file
