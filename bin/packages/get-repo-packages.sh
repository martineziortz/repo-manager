#!/usr/bin/env bash

repos_file="$1"
shift
repo="$*"

if [[ ! -f "$repos_file" ]]; then
    error "Repos file does not exist: $repos_file"
    exit 0
fi

bindir=`dirname ${BASH_SOURCE[0]}`

. $bindir'/package-include.sh'

for package in $(./bin/packages/get-packages.sh); do
    topic_filter=$(./$bindir/get-package-topic-filters.sh "$package")
    jq -e -r '.["'$repo'"] | select(. | ['$topic_filter'] | all )' "$repos_file" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo "$package"
    fi
done
