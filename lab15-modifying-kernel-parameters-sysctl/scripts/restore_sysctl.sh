#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: $0 <backup_file>"
  echo "Available backups:"
  ls -la /tmp/sysctl_backup_*.conf 2>/dev/null || echo "No backups found"
  exit 1
fi

BACKUP_FILE="$1"
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file not found: $BACKUP_FILE"
  exit 1
fi

echo "Restoring sysctl settings from: $BACKUP_FILE"
sudo sysctl -p "$BACKUP_FILE"
echo "Settings restored successfully"
