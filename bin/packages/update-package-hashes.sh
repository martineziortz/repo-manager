#!/usr/bin/env bash

bindir=`dirname ${BASH_SOURCE[0]}`

for package in `$bindir/get-modified-packages.sh`; do
  $bindir'/update-package-hash.sh' "$package"
done
