#!/bin/bash

# A script to perform incremental backups using rsync

set -euo pipefail

cleanup() {
  echo "cleaning up..."
  rm -rf "${BACKUP_PATH}"
}

trap 'trap " " SIGTERM; kill 0; wait; cleanup' SIGINT SIGTERM

echo "The script pid is " $$

readonly SOURCE_DIR="/mnt/media/"
readonly BACKUP_DIR="/mnt/backup/media"
readonly DATETIME=$(date '+%Y-%m-%d_%H:%M:%S')
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"

mkdir -p "${BACKUP_DIR}"

rsync -av --exclude-from="exclude-list.txt" \
--delete \
"${SOURCE_DIR}/" \
--link-dest "${LATEST_LINK}" \
"${BACKUP_PATH}" &

child_pid="$!"
wait "${child_pid}"

rm -rf "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
