#!/usr/bin/env bash

package="$1"
destination="$2"

bindir=`dirname ${BASH_SOURCE[0]}`

. $bindir'/package-include.sh'

if [[ ! -d "$destination" ]]; then
    error "Destination $destination does not exist"
    exit 1
fi

repo_files=$($bindir/get-package-files.sh "$package" 1 | xargs -I{} echo "$destination"'/{}')

out=$(python3 $bindir/../check-hashed-file-status.py \
     -c "$($bindir/get-package-hash.sh "$package")" \
     -d "$hash_dir" -- $repo_files)


if [[ $(echo $out | jq '.["has-latest"]') -eq 0 ]]; then

    IFS=$'\n'
    for pf in $(yq -r '.files' "$package_config" -o props); do
        package_file=$package_dir/files/${pf% = *}
        dest_file=$destination/${pf#* = }
        dest_dir=$(dirname "$dest_file")
        if [[ ! -d "$dest_dir" ]]; then
            mkdir -p "$dest_dir"
        fi

        echo "Copying $package_file to $dest_file"

        cp "$package_file" "$dest_file"
    done

fi
