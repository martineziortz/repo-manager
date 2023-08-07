#!/usr/bin/env bash

repository="$1"
author="$2"
message="$3"
skip=0

function is_automated_build() {
    if [[ "$message" == "[BUILD] "* ]]; then
        return 0
    fi
    return 1
}

function is_triggered_by_github() {
    if [[ "$author" == "github-actions[bot]" || "$author" == "dependabot[bot]" ]]; then
        return 0
    fi
    return 1
}

function is_app_project() {
    repo_suffix="${repository#*/}" # Extract the part after the slash
    if [[ "$repo_suffix" == "app-"* ]]; then
        return 0
    fi
    return 1
}

function is_app_build() {
    if is_app_project && is_automated_build; then
        return 0
    fi
    return 1
}

(is_automated_build || is_triggered_by_github) && skip=1

# If it's an app build we want to allow build automations to trigger.
is_app_build && skip=0

exit $skip
