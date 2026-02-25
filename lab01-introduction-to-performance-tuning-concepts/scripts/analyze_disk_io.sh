#!/bin/bash
echo "=== DISK I/O ANALYSIS ==="
echo "Current I/O Statistics:"
iostat -x 1 1
echo ""
echo "Top I/O Intensive Processes:"
iotop -b -n 1 | head -15
echo ""
echo "Disk Usage by Mount Point:"
df -h
echo ""
echo "Inode Usage:"
df -i
echo ""
echo "Files with High I/O Activity:"
sudo lsof | awk '{print $2}' | sort | uniq -c | sort -rn | head -10
echo ""
echo "Block Device Information:"
lsblk -f
