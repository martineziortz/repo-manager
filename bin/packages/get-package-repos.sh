#!/usr/bin/env bash

repos_file="$1"
shift
package="$*"

if [[ ! -f "$repos_file" ]]; then
    error "Repos file does not exist: $repos_file"
    exit 0
fi

bindir=`dirname ${BASH_SOURCE[0]}`

. $bindir'/package-include.sh'

topic_filter=$(./$bindir/get-package-topic-filters.sh "$package")
jq -r 'with_entries( select( .value | ['$topic_filter'] | all ) ) | keys[]' "$repos_file"
