#!/bin/bash
echo "Generating system load for testing..."

# CPU load
stress-ng --cpu 2 --timeout 15s --metrics-brief >/dev/null 2>&1 &
CPU_PID=$!

# Memory pressure
stress-ng --vm 1 --vm-bytes 256M --timeout 15s --metrics-brief >/dev/null 2>&1 &
VM_PID=$!

# Quick disk write burst (100MB)
dd if=/dev/zero of=/tmp/pcp_disk_test.bin bs=1M count=100 conv=fdatasync >/dev/null 2>&1
rm -f /tmp/pcp_disk_test.bin

wait $CPU_PID 2>/dev/null
wait $VM_PID 2>/dev/null

echo "Load generation complete"
