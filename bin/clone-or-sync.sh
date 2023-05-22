#!/usr/bin/env bash
# Will either clone a fresh repository or update the repository if it exists.
# Usage: clone-or-sync.sh dbd-net misc-repo-manager temp/misc-repo-manager
# This can hit API limits so should be used with an access token instead of the default token.

org_name=$1
repo_name=$2
repo_dir=$3

if [[ -d "$repo_dir/$repo_name" ]]; then
    cd "$repo_dir/$repo_name" && gh repo sync --force
else
    gh repo clone "$org_name/$repo_name" "$repo_dir/$repo_name" -- --depth 1 --single-branch
fi
