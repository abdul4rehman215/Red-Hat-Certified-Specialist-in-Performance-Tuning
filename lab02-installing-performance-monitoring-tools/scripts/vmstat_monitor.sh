#!/bin/bash
echo "=== VM Statistics Monitor ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo ""
echo "Current Memory and CPU Usage:"
vmstat 1 1
echo ""
echo "Disk Statistics:"
vmstat -d
