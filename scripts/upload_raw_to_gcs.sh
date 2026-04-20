#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROJECT_ID="${PROJECT_ID:-bikeflow-sp-dezoomcamp}"
RAW_BUCKET="${RAW_BUCKET:-bikeflow-sp-dezoomcamp-raw}"
GCS_RAW_PREFIX="${GCS_RAW_PREFIX:-raw}"
LOCAL_RAW_DIR="${LOCAL_RAW_DIR:-${REPO_ROOT}/data/raw}"

STATION_INFORMATION_LOCAL_DIR="${LOCAL_RAW_DIR}/station_information"
STATION_STATUS_LOCAL_DIR="${LOCAL_RAW_DIR}/station_status"

STATION_INFORMATION_GCS_URI="gs://${RAW_BUCKET}/${GCS_RAW_PREFIX}/station_information"
STATION_STATUS_GCS_URI="gs://${RAW_BUCKET}/${GCS_RAW_PREFIX}/station_status"

require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Missing required command: ${command_name}" >&2
        exit 1
    fi
}

require_directory() {
    local directory="$1"

    if [[ ! -d "${directory}" ]]; then
        echo "Missing required local directory: ${directory}" >&2
        exit 1
    fi
}

require_command "gcloud"
require_directory "${STATION_INFORMATION_LOCAL_DIR}"
require_directory "${STATION_STATUS_LOCAL_DIR}"

echo "Raw upload destination:"
echo "  project: ${PROJECT_ID}"
echo "  bucket: gs://${RAW_BUCKET}"
echo "  prefix: ${GCS_RAW_PREFIX}"
echo "  station_information: ${STATION_INFORMATION_GCS_URI}"
echo "  station_status: ${STATION_STATUS_GCS_URI}"
echo "  local raw dir: ${LOCAL_RAW_DIR}"
echo "  remote deletes: disabled"

gcloud storage rsync \
    "${STATION_INFORMATION_LOCAL_DIR}" \
    "${STATION_INFORMATION_GCS_URI}" \
    --recursive \
    --project="${PROJECT_ID}"

gcloud storage rsync \
    "${STATION_STATUS_LOCAL_DIR}" \
    "${STATION_STATUS_GCS_URI}" \
    --recursive \
    --exclude=".*\.inprogress(\..*)?$" \
    --project="${PROJECT_ID}"

echo "Raw upload completed."
