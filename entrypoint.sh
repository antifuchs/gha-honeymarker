#!/bin/bash

set -euxo pipefail

function marker_url() {
    if [ -z "$INPUT_URL" ] ; then
        echo "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
    else
        echo "$INPUT_URL"
    fi
}

function create_markers() {
    for dataset in $INPUT_DATASETS; do
        if marker_id=$(honeymarker -k "$INPUT_APIKEY" -d "$dataset" add -t "$INPUT_TYPE" -m "$INPUT_MESSAGE" -u "$(marker_url)" | jq -r .id); then
            echo "[\"${dataset}\", \"${marker_id}\"]"
        else
            echo "Failed to run honeymarker for dataset ${dataset}" >&2
            exit 1
        fi
    done  | jq --slurp -jc . | jq -R . > ./marker_ids.json
    (echo "HONEYCOMB_MARKER_IDS=$(cat ./marker_ids.json)") >> $GITHUB_ENV
}

function update_markers_end() {
    jq -nr 'env | .HONEYCOMB_MARKER_IDS | fromjson | fromjson | .[]| @tsv' | while read dataset marker_id ; do
        honeymarker -k "$INPUT_APIKEY" -d "$dataset" update -i "$marker_id" -e $(date '+%s') -t "$INPUT_TYPE" -m "$INPUT_MESSAGE" -u "$(marker_url)"
    done
}

if ! [[ -v HONEYCOMB_MARKER_IDS ]] ; then
    create_markers
else
    update_markers_end
fi
