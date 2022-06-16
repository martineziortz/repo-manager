#!/usr/bin/env bash

owner=dbd-net
gh search repos --topic="${1}" --owner="${owner}" --no-archived -L 1000 --json=name,url,defaultBranch
