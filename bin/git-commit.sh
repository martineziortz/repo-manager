#!/usr/bin/env bash
# Commits to a repository as the github-actions[bot] user
# This is used for streamlining the commit process when a package is updated.
#
# Usage: git-commit.sh path/to/repo 'My message here'

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
