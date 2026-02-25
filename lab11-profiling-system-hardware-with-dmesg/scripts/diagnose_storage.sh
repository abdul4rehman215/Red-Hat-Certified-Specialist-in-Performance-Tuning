#!/bin/bash
echo "=== Storage Diagnostics ==="
echo
echo "1. Checking for I/O errors:"
dmesg | grep -i "i/o error\|input/output error" | tail -10
echo
echo "2. Checking for SMART errors:"
dmesg | grep -i "smart\|reallocated\|pending" | tail -5
echo
echo "3. Checking for filesystem errors:"
dmesg | grep -i "filesystem.*error\|ext4.*error\|xfs.*error" | tail -10
echo
echo "4. Checking for device timeouts:"
dmesg | grep -i "timeout" | grep -i "ata\|scsi\|disk" | tail -10
echo
echo "5. Recent storage-related messages:"
dmesg --since="1 hour ago" | grep -E "sd[a-z]|nvme|ata" | tail -10
