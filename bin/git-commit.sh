#!/usr/bin/env bash

repo_dir="$1"
shift
message="$*"

username='github-actions[bot]'
email='41898282+github-actions[bot]@users.noreply.github.com'
author="$username <$email>"

pushd "$repo_dir"

git add --no-all .

if [ -n "$(git diff --staged)" ]; then

    git -c user.name="$username" \
    -c user.email="$email" \
    commit \
    --no-verify \
    --signoff \
    --author="$author" \
    --message="$message"

    git push
fi

popd
