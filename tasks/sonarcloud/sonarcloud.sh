#!/usr/bin/env bash

repo="${1}"
owner=dbd-net
bindir="${BASH_SOURCE%/*}/../../bin"
tmpdir="${BASH_SOURCE%/*}/../../tmp/${repo}/sonarcloud"
repodir="${BASH_SOURCE%/*}/../../repos"
localpropertyfile="sonarcloud.properties"
remotepropertyfile=".sonarcloud.properties"
propertypath="${tmpdir}/${remotepropertyfile}"
currenthash=`shasum "${BASH_SOURCE%/*}/${localpropertyfile}" | awk '{print $1}'`
match=0
found=0

# Checks if the given hash matches any of the hashes we have stored.
hash_match_any() {
    echo "Repo hash is $1"
    for filename in hashes/*.sha1;
    do
        [[ -e "$filename" ]] || continue
        echo "Checking hash of properties file against ${filename}"

        file_hash=`awk '{print $1}' "${filename}"`

        if [[ "${file_hash}" == "${1}" ]];
        then
            return 1
        fi
    done

    return 0
}

# Compares the hash of two files.
file_hash_compare() {
    hash_1=`shasum "${1}" | awk '{print $1}'`
    hash_2=`shasum "${2}" | awk '{print $1}'`
    if [[ "${hash_1}" == "${hash_2}" ]];
    then
        return 1
    fi
    return 0
}

if [[ -z "${repo}" ]];
then
    echo "Repo required"
    exit 1
fi

if [[ ! -d "${tmpdir}" ]];
then
    mkdir -p "${tmpdir}"
fi

"${bindir}/fetch-repo-file.sh" "${owner}/${repo}" "${remotepropertyfile}" > "${propertypath}"

# If we were able to get a file from the report then we should check its hashes
if [[ -e "${propertypath}" ]];
then
    found=1
    repohash=`shasum "${propertypath}" | awk '{print $1}'`

    if [[ "${repohash}" == "${currenthash}" ]];
    then
        echo "Repository already has latest file"
        exit 0
    fi

    hash_match_any "${repohash}"
    if [[ $? -eq 1 ]];
    then
        echo "Existing file recognized"
        match=1
    fi
fi

if [[ ! -d "${repodir}/${repo}" ]];
then
    gh repo clone "${owner}/${repo}" "${repodir}/${repo}"
fi

if [[ ! -d "${repodir}/${repo}" ]];
then
    echo "Unable to clone repo"
    exit 1
fi

echo "Copying file into repository"
cp "${BASH_SOURCE%/*}/${localpropertyfile}" "${repodir}/${repo}/${remotepropertyfile}"

# If there was a file, but there was not a matching hash, then the repo has a
# custom configuration. We should make a branch and submit a PR instead of
# overwriting the custom code.
if [[ $match -eq 0 ]];
then
    git -C "${repodir}/${repo}" checkout -b "sonar-${currenthash}"
fi

git -C "${repodir}/${repo}" add "${remotepropertyfile}"
git -C "${repodir}/${repo}" commit -m "Updating Sonarcloud configuration"

if [[ $match -eq 0 ]];
then
    git -C "${repodir}/${repo}" push origin "sonar-${currenthash}"
    cd "${repodir}/${repo}"
    gh pr create -f -t "Updating Sonarcloud configuration"
    cd -
else
    git -C "${repodir}/${repo}" push
fi

exit 0