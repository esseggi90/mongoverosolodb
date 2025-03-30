#!/bin/bash

# MongoDB Backup and Restore Script
# Usage:
#   - Backup: ./backup-restore.sh backup <connection-string> <output-directory>
#   - Restore: ./backup-restore.sh restore <connection-string> <backup-file>

# Skip execution when the script is sourced during container initialization
# This prevents the script from running with "numactl" as the first argument
if [[ "$1" == "numactl" || "$0" != "$BASH_SOURCE" ]]; then
    exit 0
fi

set -e

function show_usage {
    echo "Usage:"
    echo "  Backup:  ./backup-restore.sh backup <connection-string> <output-directory>"
    echo "  Restore: ./backup-restore.sh restore <connection-string> <backup-file>"
    exit 1
}

# Check if at least 3 arguments were provided
if [ $# -lt 3 ]; then
    show_usage
fi

ACTION=$1
CONNECTION_STRING=$2
TARGET=$3
DB_NAME="mangandoDB"

case "$ACTION" in
    backup)
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_FILE="$TARGET/mongodb_backup_$TIMESTAMP.gz"
        
        echo "Backing up MongoDB to $BACKUP_FILE..."
        mongodump --uri="$CONNECTION_STRING" --gzip --archive="$BACKUP_FILE"
        
        if [ $? -eq 0 ]; then
            echo "Backup completed successfully."
            echo "Backup file: $BACKUP_FILE"
        else
            echo "Backup failed."
            exit 1
        fi
        ;;
    
    restore)
        if [ ! -f "$TARGET" ]; then
            echo "Error: Backup file not found: $TARGET"
            exit 1
        fi
        
        echo "Restoring MongoDB from $TARGET..."
        mongorestore --uri="$CONNECTION_STRING" --gzip --archive="$TARGET"
        
        if [ $? -eq 0 ]; then
            echo "Restore completed successfully."
        else
            echo "Restore failed."
            exit 1
        fi
        ;;
    
    *)
        echo "Error: Unknown action '$ACTION'"
        show_usage
        ;;
esac 