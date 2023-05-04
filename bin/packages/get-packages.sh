#!/usr/bin/env bash

. `dirname ${BASH_SOURCE[0]}`'/package-include.sh'

for package in `find $packages_dir -maxdepth 1 -mindepth 1 -type d -exec basename {} \;`; do
    assert_package_config_exists "$package"
    echo $package
done
