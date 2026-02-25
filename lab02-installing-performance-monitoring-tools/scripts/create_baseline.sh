#!/bin/bash
BASELINE_DIR="/tmp/performance_baseline"
mkdir -p $BASELINE_DIR
echo "Creating performance baseline..."
# CPU baseline
echo "Collecting CPU baseline..."
sar -u 1 60 > $BASELINE_DIR/cpu_baseline.txt &
# Memory baseline
echo "Collecting memory baseline..."
sar -r 1 60 > $BASELINE_DIR/memory_baseline.txt &
# Disk I/O baseline
echo "Collecting disk I/O baseline..."
iostat -x 1 60 > $BASELINE_DIR/disk_baseline.txt &
# Network baseline
echo "Collecting network baseline..."
sar -n DEV 1 60 > $BASELINE_DIR/network_baseline.txt &
wait
echo "Baseline collection complete. Files saved in $BASELINE_DIR"
ls -la $BASELINE_DIR
