#!/bin/bash
# Lab 20 - Comprehensive Performance Tuning Review
# Commands Executed During Lab (sequential, no explanations)

# ------------------------------------------------------------
# Task 1.1 - Gather Historical Performance Data
# ------------------------------------------------------------

sudo mkdir -p /opt/performance-review
cd /opt/performance-review
sudo mkdir -p {cpu-data,memory-data,disk-data,network-data,reports}

ls -la

sudo cp /var/log/sa/sa* ./cpu-data/
ls -la cpu-data/ | head -20

sar -u -f /var/log/sa/sa$(date -d "1 day ago" +%d) > cpu-data/cpu-utilization-yesterday.txt
sar -r -f /var/log/sa/sa$(date -d "1 day ago" +%d) > memory-data/memory-utilization-yesterday.txt
sar -d -f /var/log/sa/sa$(date -d "1 day ago" +%d) > disk-data/disk-io-yesterday.txt
sar -n DEV -f /var/log/sa/sa$(date -d "1 day ago" +%d) > network-data/network-stats-yesterday.txt

ls -la cpu-data/*.txt memory-data/*.txt disk-data/*.txt network-data/*.txt

# ------------------------------------------------------------
# Task 1.2 - Create Real-Time Performance Baseline
# ------------------------------------------------------------

nano monitor-system.sh
chmod +x monitor-system.sh
sudo ./monitor-system.sh

ls -la cpu-data | grep 20260225_191012

which stress-ng || sudo dnf install -y stress-ng

nano generate-load.sh
chmod +x generate-load.sh
sudo ./generate-load.sh
sudo rm -f /tmp/testfile

# ------------------------------------------------------------
# Task 1.3 - Collect Detailed Process Performance Data
# ------------------------------------------------------------

which perf || sudo dnf install -y perf

sudo perf record -g -a sleep 60
sudo perf report --stdio > cpu-data/perf-report-$(date +%Y%m%d_%H%M%S).txt
sudo perf stat -a -d sleep 30 2> cpu-data/perf-stat-$(date +%Y%m%d_%H%M%S).txt

ps aux --sort=-%cpu | head -20 > cpu-data/top-cpu-processes.txt
ps aux --sort=-%mem | head -20 > memory-data/top-memory-processes.txt
ps aux | grep -E "(zombie|defunct)" > reports/problematic-processes.txt
wc -l reports/problematic-processes.txt

# ------------------------------------------------------------
# Task 2.1 - CPU Performance Analysis
# ------------------------------------------------------------

which bc || sudo dnf install -y bc

nano analyze-cpu.sh
chmod +x analyze-cpu.sh
./analyze-cpu.sh

# ------------------------------------------------------------
# Task 2.2 - Memory Performance Analysis
# ------------------------------------------------------------

nano analyze-memory.sh
chmod +x analyze-memory.sh
./analyze-memory.sh

# ------------------------------------------------------------
# Task 2.3 - Disk I/O Performance Analysis
# ------------------------------------------------------------

nano analyze-disk.sh
chmod +x analyze-disk.sh
./analyze-disk.sh

# ------------------------------------------------------------
# Task 3.1 - CPU Optimization
# ------------------------------------------------------------

nano optimize-cpu.sh
chmod +x optimize-cpu.sh
sudo ./optimize-cpu.sh

# ------------------------------------------------------------
# Task 3.2 - Memory Optimization
# ------------------------------------------------------------

nano optimize-memory.sh
chmod +x optimize-memory.sh
sudo ./optimize-memory.sh

# ------------------------------------------------------------
# Task 3.3 - Disk I/O Optimization
# ------------------------------------------------------------

nano optimize-disk.sh
chmod +x optimize-disk.sh
sudo ./optimize-disk.sh

# ------------------------------------------------------------
# Task 3.4 - System-Wide Optimization
# ------------------------------------------------------------

nano optimize-system.sh
chmod +x optimize-system.sh
sudo ./optimize-system.sh

# ------------------------------------------------------------
# Task 4.1 - Performance Testing and Validation
# ------------------------------------------------------------

sudo dnf install -y sysstat stress-ng

nano performance-test.sh
chmod +x performance-test.sh
sudo ./performance-test.sh

sleep 10
sudo ls -la /opt/performance-review/test-results | head

# ------------------------------------------------------------
# Task 4.2 - Generate Performance Comparison Report
# ------------------------------------------------------------

nano generate-final-report.sh
chmod +x generate-final-report.sh
./generate-final-report.sh

# ------------------------------------------------------------
# Task 4.3 - Create Ongoing Monitoring Setup
# ------------------------------------------------------------

nano setup-monitoring.sh
chmod +x setup-monitoring.sh
sudo ./setup-monitoring.sh

crontab -l
