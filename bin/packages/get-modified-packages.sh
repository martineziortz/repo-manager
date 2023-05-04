#!/usr/bin/env bash

bindir=`dirname ${BASH_SOURCE[0]}`

. "$bindir/package-include.sh"

packages=$($bindir/get-packages.sh)

for package in $packages; do
    $bindir/is-package-modified.sh "$package"
    if [[ $? -eq 0 ]]; then
       echo $package
    fi
done
