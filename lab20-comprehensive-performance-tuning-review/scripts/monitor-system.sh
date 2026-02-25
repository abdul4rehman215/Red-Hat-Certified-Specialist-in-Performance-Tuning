#!/bin/bash
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGDIR="/opt/performance-review"
echo "Starting comprehensive system monitoring at $(date)"
# CPU monitoring with top
top -b -n 5 -d 2 > ${LOGDIR}/cpu-data/top-baseline-${TIMESTAMP}.txt &
# Memory and CPU with sar (5-minute intervals, 12 samples = 1 hour)
sar -u -r 300 12 > ${LOGDIR}/cpu-data/sar-cpu-memory-${TIMESTAMP}.txt &
# Disk I/O monitoring
iostat -x 300 12 > ${LOGDIR}/disk-data/iostat-baseline-${TIMESTAMP}.txt &
# Network monitoring
sar -n DEV 300 12 > ${LOGDIR}/network-data/sar-network-${TIMESTAMP}.txt &
echo "Monitoring started. Data will be collected for 1 hour."
echo "Log files created with timestamp: ${TIMESTAMP}"
