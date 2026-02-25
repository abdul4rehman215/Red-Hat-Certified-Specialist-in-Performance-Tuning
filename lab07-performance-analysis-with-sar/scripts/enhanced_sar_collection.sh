#!/bin/bash
# Enhanced SAR Data Collection Script
LOG_DIR="/var/log/sysstat"
DATE=$(date +%Y%m%d)
TIME=$(date +%H%M%S)

# Collect comprehensive system data
echo "Starting enhanced data collection at $(date)"

# CPU data every 30 seconds for 10 minutes
sar -u 30 20 > ${LOG_DIR}/cpu_detailed_${DATE}_${TIME}.log &

# Memory data every 30 seconds for 10 minutes
sar -r 30 20 > ${LOG_DIR}/memory_detailed_${DATE}_${TIME}.log &

# Disk I/O data every 30 seconds for 10 minutes
sar -d 30 20 > ${LOG_DIR}/disk_detailed_${DATE}_${TIME}.log &

# Network data every 30 seconds for 10 minutes
sar -n DEV 30 20 > ${LOG_DIR}/network_detailed_${DATE}_${TIME}.log &

echo "Enhanced collection started. Data will be saved to ${LOG_DIR}"
