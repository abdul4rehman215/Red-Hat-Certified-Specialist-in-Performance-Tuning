#!/bin/bash
echo "=== Storage Hardware Detection Analysis ==="
echo
echo "1. Storage Device Detection:"
dmesg | grep -E "sd[a-z]|nvme|ata" | head -10
echo
echo "2. Storage Controller Information:"
dmesg | grep -i "ahci\|scsi.*host"
echo
echo "3. Storage Errors/Warnings:"
dmesg | grep -i "error\|fail\|warn" | grep -i "disk\|ata\|scsi\|storage"
echo
echo "4. Filesystem Messages:"
dmesg | grep -i "ext4\|xfs\|filesystem" | head -5
