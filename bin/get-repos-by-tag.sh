#!/usr/bin/env bash

owner=dbd-net
gh search repos --topic="${1}" --owner="${owner}" --archived=0 -L 1000 --json=name,url,defaultBranch --jq='.[].name'
