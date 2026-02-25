#!/bin/bash
echo "Generating CPU load..."
# CPU intensive task
stress-ng --cpu 2 --timeout 300s &
echo "Generating memory load..."
# Memory intensive task
stress-ng --vm 1 --vm-bytes 512M --timeout 300s &
echo "Generating disk I/O load..."
# Disk I/O intensive task
dd if=/dev/zero of=/tmp/testfile bs=1M count=1000 &
echo "Load generation started. Will run for 5 minutes."
wait
echo "Load generation completed."
