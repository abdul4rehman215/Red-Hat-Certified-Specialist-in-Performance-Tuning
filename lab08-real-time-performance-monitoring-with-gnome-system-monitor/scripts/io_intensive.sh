#!/bin/bash
echo "Starting I/O-intensive process..."
while true; do
 dd if=/dev/zero of=/tmp/test_file bs=1M count=100 2>/dev/null
 rm -f /tmp/test_file
 sleep 1
done
