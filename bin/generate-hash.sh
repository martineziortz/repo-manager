#!/usr/bin/env bash
# Takes a list of files and generates a hash to track changes.
# Output should match the generate-hash.py python script when given files in a sorted order.

shasum -- "$@" | awk '{print $1}' | shasum | awk '{print $1}'
