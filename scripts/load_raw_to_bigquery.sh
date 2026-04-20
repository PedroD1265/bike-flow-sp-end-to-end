#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-bikeflow-sp-dezoomcamp}"
BQ_LOCATION="${BQ_LOCATION:-southamerica-east1}"
BQ_DATASET="${BQ_DATASET:-bikeflow_raw}"
RAW_BUCKET="${RAW_BUCKET:-bikeflow-sp-dezoomcamp-raw}"
GCS_RAW_PREFIX="${GCS_RAW_PREFIX:-raw}"

STATION_INFORMATION_TABLE="${PROJECT_ID}:${BQ_DATASET}.station_information_raw"
STATION_STATUS_TABLE="${PROJECT_ID}:${BQ_DATASET}.station_status_raw"

STATION_INFORMATION_PATTERN="gs://${RAW_BUCKET}/${GCS_RAW_PREFIX}/station_information/**/station_information.ndjson"
STATION_STATUS_PATTERN="gs://${RAW_BUCKET}/${GCS_RAW_PREFIX}/station_status/**/part-*"

STATION_INFORMATION_SCHEMA="station_id:STRING,external_id:STRING,station_name:STRING,short_name:STRING,lat:FLOAT,lon:FLOAT,address:STRING,capacity:INTEGER,is_charging_station:BOOLEAN,is_virtual_station:BOOLEAN,ingested_at:TIMESTAMP"
STATION_STATUS_SCHEMA="station_id:STRING,num_vehicles_available:INTEGER,num_docks_available:INTEGER,last_reported:TIMESTAMP,is_installed:BOOLEAN,is_renting:BOOLEAN,is_returning:BOOLEAN,ingested_at:TIMESTAMP"

require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Missing required command: ${command_name}" >&2
        exit 1
    fi
}

list_gcs_objects() {
    local pattern="$1"

    gcloud storage ls "${pattern}" --project="${PROJECT_ID}" 2>/dev/null \
        | grep -v '\.inprogress' \
        | sort || true
}

require_non_empty_objects() {
    local object_name="$1"
    local pattern="$2"
    shift 2
    local objects=("$@")

    if [[ "${#objects[@]}" -eq 0 ]]; then
        echo "No finalized GCS objects found for ${object_name}." >&2
        echo "Checked pattern: ${pattern}" >&2
        exit 1
    fi
}

join_by_comma() {
    local IFS=","
    echo "$*"
}

load_table_replace() {
    local table="$1"
    local source_uris="$2"
    local schema="$3"

    echo "Replacing table ${table} from finalized GCS objects."
    bq --project_id="${PROJECT_ID}" --location="${BQ_LOCATION}" load \
        --replace \
        --source_format=NEWLINE_DELIMITED_JSON \
        "${table}" \
        "${source_uris}" \
        "${schema}"
}

require_command "gcloud"
require_command "bq"

echo "Raw BigQuery load destination:"
echo "  project: ${PROJECT_ID}"
echo "  bucket: gs://${RAW_BUCKET}"
echo "  prefix: ${GCS_RAW_PREFIX}"
echo "  dataset: ${PROJECT_ID}.${BQ_DATASET}"
echo "  replace table: ${STATION_INFORMATION_TABLE}"
echo "  replace table: ${STATION_STATUS_TABLE}"
echo "  load mode: full replacement of current raw tables (--replace)"

mapfile -t station_information_objects < <(list_gcs_objects "${STATION_INFORMATION_PATTERN}")
mapfile -t station_status_objects < <(list_gcs_objects "${STATION_STATUS_PATTERN}")

require_non_empty_objects "station_information" "${STATION_INFORMATION_PATTERN}" "${station_information_objects[@]}"
require_non_empty_objects "station_status" "${STATION_STATUS_PATTERN}" "${station_status_objects[@]}"

echo "Finalized object counts:"
echo "  station_information: ${#station_information_objects[@]}"
echo "  station_status: ${#station_status_objects[@]}"

load_table_replace \
    "${STATION_INFORMATION_TABLE}" \
    "$(join_by_comma "${station_information_objects[@]}")" \
    "${STATION_INFORMATION_SCHEMA}"

load_table_replace \
    "${STATION_STATUS_TABLE}" \
    "$(join_by_comma "${station_status_objects[@]}")" \
    "${STATION_STATUS_SCHEMA}"

echo "Raw BigQuery load completed."
