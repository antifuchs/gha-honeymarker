#!/bin/bash

set -euxo pipefail

function install_binary() {
    go get github.com/honeycombio/honeymarker
}

function marker_url() {
    if [ -z "$INPUT_URL" ] ; then
        echo "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
    else
        echo "$INPUT_URL"
    fi
}

function create_marker() {
    env

    if marker_id=$(honeymarker -k "$INPUT_APIKEY" -d "$INPUT_DATASET" add -t "$INPUT_TYPE" -m "$INPUT_MESSAGE" -u "$(marker_url)" | jq -r .id); then
        echo "HONEYCOMB_MARKER_ID=${marker_id}" >> $GITHUB_ENV
    else
        echo "Failed to run honeymarker"
        exit 1
    fi
}

function update_marker_end() {
    env

    honeymarker -k "$INPUT_APIKEY" -d "$INPUT_DATASET" update -i $HONEYCOMB_MARKER_ID -e $(date '+%s')
}

install_binary
if ! [[ -v HONEYCOMB_MARKER_ID ]] ; then
    create_marker
else
    update_marker_end
fi
