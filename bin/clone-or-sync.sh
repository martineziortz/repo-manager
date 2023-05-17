#!/usr/bin/env bash

org_name=$1
repo_name=$2
repo_dir=$3

if [[ -d "$repo_dir/$repo_name" ]]; then
    cd "$repo_dir/$repo_name" && gh repo sync --force
else
    gh repo clone "$org_name/$repo_name" "$repo_dir/$repo_name" -- --depth 1 --single-branch
fi
