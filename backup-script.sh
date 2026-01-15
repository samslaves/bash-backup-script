#!/bin/bash

# A script to perform incremental backups using rsync

set -euo pipefail

cleanup() {
  echo "Cleaning up incomplete backup..."
  if [[ -d "${BACKUP_PATH}" ]]; then
    rm -rf "${BACKUP_PATH}"
  fi
}

trap 'trap " " SIGTERM; kill 0; wait; cleanup' SIGINT SIGTERM EXIT

echo "The script pid is $$"

readonly SOURCE_DIR="/mnt/media/"
readonly BACKUP_DIR="/mnt/backup/media"
readonly DATETIME=$(date '+%Y-%m-%d_%H-%M-%S')
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"
readonly LATEST_LINK="${BACKUP_DIR}/latest"
readonly EXCLUDE_FILE="exclude-list.txt"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Check if exclude file exists
EXCLUDE_OPTION=""
if [[ -f "${EXCLUDE_FILE}" ]]; then
  EXCLUDE_OPTION="--exclude-from=${EXCLUDE_FILE}"
fi

# Build rsync command with or without link-dest
if [[ -d "${LATEST_LINK}" ]]; then
  echo "Performing incremental backup (using previous backup as reference)..."
  rsync -av ${EXCLUDE_OPTION} \
    --delete \
    --link-dest="${LATEST_LINK}" \
    "${SOURCE_DIR}/" \
    "${BACKUP_PATH}" &
else
  echo "Performing first backup (no previous backup found)..."
  rsync -av ${EXCLUDE_OPTION} \
    --delete \
    "${SOURCE_DIR}/" \
    "${BACKUP_PATH}" &
fi

child_pid="$!"
wait "${child_pid}"

# Update the latest symlink
rm -f "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"

# If we got here, backup succeeded - disable cleanup trap
trap - EXIT

echo "Backup completed successfully: ${BACKUP_PATH}"
