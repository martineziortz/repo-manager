#!/usr/bin/env bash

gh api "repos/${1}/contents/${2}" \
    -H "Accept: application/vnd.github.VERSION.raw" 2> /dev/null