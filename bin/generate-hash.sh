#!/usr/bin/env bash

shasum -- "$@" | awk '{print $1}' | shasum | awk '{print $1}'
