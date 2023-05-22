#!/usr/bin/env bash
# Get a list of all repositories and their topics
# This can hit API rate limits so should be used with an access key instead of the default token.

repo_limit=500

gh repo list dbd-net \
    --no-archived \
    --visibility private \
    --source \
    --no-archived \
    -L$repo_limit \
    --json name,repositoryTopics \
    --jq '[ (.[] | { (.name): [.repositoryTopics[]?.name] }) ] | add'