#!/usr/bin/env bash

packages_dir=$(realpath `dirname ${BASH_SOURCE[0]}`'/../../packages')
package_config=
package_dir=

error() {
    echo "$*" >&2
}

assert_packages_folder_exists() {
    local packages_dir="$*"
    if [[ ! -d "$packages_dir" ]]; then
      error "Packages folder is missing"
      exit 1
    fi
}

assert_package_folder_exists() {
    local package="$*"
    local package_dir=`get_package_folder "$package"`
    if [[ ! -d "$package_dir" ]]; then
      error "Package $package does not exist"
      exit 2
    fi
}

assert_package_config_exists() {
    local package_config=`get_package_config_file "$*"`
    if [[ ! -f "$package_config" ]]; then
      error "Package config for $package does not exist at $package_config"
      exit 3
    fi
}

get_package_folder() {
    echo "$packages_dir/$*"
}

get_package_config_file() {
    echo `get_package_folder "$*"`"/$*.yml"
}

get_package_hash_dir() {
    local package="$*"
    hash_dir=`dirname ${BASH_SOURCE[0]}`"/../../hashes/$package"
    if [[ ! -d "$hash_dir" ]]; then
        mkdir -p "$hash_dir"
    fi
    echo "$hash_dir"
}

assert_packages_folder_exists "$packages_dir"

if [[ ! -z "${package}" ]]; then
    assert_package_folder_exists $package
    assert_package_config_exists $package

    package_config=`get_package_config_file $package`
    package_dir=`get_package_folder $package`
    hash_dir=`get_package_hash_dir $package`
fi