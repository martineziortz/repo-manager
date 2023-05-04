#!/usr/bin/env bash

repos_file="$1"
shift
repo="$*"

bindir=`dirname ${BASH_SOURCE[0]}`

grep -w -f <(./bin/packages/get-repo-packages.sh "$repos_file" "$repo") <(./bin/packages/get-modified-packages.sh)
