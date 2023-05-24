#!/usr/bin/env bash

PROJECT_ROOT='/var/www/static.dbd.net'

RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
CYAN="\e[1;36m"
COFF="\e[0m"

indent() { sed 's/^/  /'; }
info() { echo -e "$1"; }
warn() { echo -e "${YELLOW}${1}${COFF}"; }
error() { echo -e "${RED}${1}${COFF}" >&2; exit 1; }
usage() { echo; echo 'Usage: release-game.sh bitbird 1.8 (environment [default staging]) (organization [default dbd-net])'; echo; }

install_release() {
    local device="$1"
    local source="$2"
    local dest="$GAMES_DIR/$device"

    [ -d "$GAMES_DIR" ] || {
        warn 'Game directory not found.' | indent
        info "Creating: $GAMES_DIR" | indent
        mkdir -p "$GAMES_DIR"
    }
    info "Installed for: ${GREEN}${device}${COFF}" | indent
    ln -sfn "$source" "$dest"
}

update_game() {
    local file="$1"
    local noext=$(basename "$file" '.tar.gz')
    local extract_to="$(readlink -f $EXTRACT_DIR)/$noext"
    local archive_path="$DOWNLOAD_DIR/$file"

    info "Installing release [${YELLOW}${file}${COFF}]"
    [ -f "$archive_path" ] || error "File missing! Checked for $archive_path"

    device=$(echo "${file,,}" | awk -F '--' '{print $2}')
    [ ! -z "$device" ] || error "Error: No device type"

    info "Detected device: ${GREEN}${device}${COFF}" | indent

    [ -d "$extract_to" ] || mkdir -p "$extract_to"
    info "Extracting archive" | indent
    tar -xzf "$archive_path" -C "$extract_to"

    if [ "$device" == 'desktop' ] || [ "$device" == 'mobile' ]; then
        install_release "$device" "$extract_to"
    elif [ "$device" == 'general' ]; then
        install_release 'desktop' "$extract_to"
        install_release 'mobile' "$extract_to"
    else
        error "Error: Unknown device type: $device"
    fi
}

GAME="$1"
RELEASE_TAG="$2"
ENVIRONMENT="${3:-staging}"
ENVIRONMENT="${ENVIRONMENT,,}"
ORG="${4:-dbd-net}"
REPO="$ORG/unity-$GAME"

GAME_ROOT="$PROJECT_ROOT/web/games"
GAMES_DIR="$GAME_ROOT/$GAME/$ENVIRONMENT"
DOWNLOAD_DIR="$PROJECT_ROOT/games/$GAME/archives"
EXTRACT_DIR="$PROJECT_ROOT/games/$GAME/builds"

[ ! -z "$GAME" ] || { usage; error 'Error: Game is required!'; }
[ ! -z "$RELEASE_TAG" ] || { usage; error 'Error: Tag is required!'; }
[ ! -z "$ENVIRONMENT" ] || { usage; error 'Error: Environment is required!'; }
([ "$ENVIRONMENT" == 'staging' ] || [ "$ENVIRONMENT" == 'production' ]) || { error 'Error: Environment must be staging or production'; }
[ ! -z "$ORG" ] || { usage; error 'Error: Organization is required!'; }

info "Updating ${GREEN}${GAME}${COFF} to ${YELLOW}${RELEASE_TAG}${COFF} for ${CYAN}${ENVIRONMENT}${COFF}"
info

if ! gh auth status >/dev/null 2>&1; then
    info 'You must configure the gh cli: https://cli.github.com/'
    error 'Error! GH CLI must be authenticated.'
fi

gh release download --skip-existing -R "$REPO" -p '*--*--*--*--*.tar.gz' -D "$DOWNLOAD_DIR" "$RELEASE_TAG"
for file in $(gh release view -R "$REPO" --json assets --jq '.assets[].name' "$RELEASE_TAG");
do
    update_game "$file"
done
