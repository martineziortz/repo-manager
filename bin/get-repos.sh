#!/usr/bin/env bash

repo_limit=500

gh repo list dbd-net \
    --no-archived \
    --visibility private \
    --source \
    --no-archived \
    -L$repo_limit \
    --json name,repositoryTopics \
    --jq '[ (.[] | { (.name): [.repositoryTopics[]?.name] }) ] | add'