#!/bin/bash
# Lab 05 - Analyzing Disk Performance with iostat
# Commands Executed During Lab (sequential, clean, ready to paste)

# ------------------------------
# Task 1.1: Verify iostat/sysstat + run basic checks
# ------------------------------

iostat -V
rpm -q sysstat

iostat
iostat -x

# ------------------------------
# Task 1.2: Continuous monitoring + device-specific monitoring
# ------------------------------

# Continuous (ran a few refreshes, then Ctrl+C)
iostat -x 2

# Attempted legacy devices (failed on NVMe-based VM)
iostat -x 2 /dev/sda /dev/sdb

# Identify actual devices
lsblk

# Correct device-specific monitoring (ran a few samples, then Ctrl+C)
iostat -x 2 nvme0n1 nvme1n1

# ------------------------------
# Task 1.2 (Script): Disk monitoring script
# ------------------------------

nano disk_monitor.sh
chmod +x disk_monitor.sh
./disk_monitor.sh
ls -la disk_performance_*.log | tail -1

# ------------------------------
# Task 1.3: iostat metrics reference guide
# ------------------------------

nano iostat_metrics_guide.txt
cat iostat_metrics_guide.txt

# ------------------------------
# Task 2.1: Synthetic I/O workload generator
# ------------------------------

nano io_workload_generator.sh
chmod +x io_workload_generator.sh

# Terminal 1: monitor during workload (stopped with Ctrl+C after observation)
iostat -x 2

# Terminal 2: run workload
./io_workload_generator.sh mixed

# ------------------------------
# Task 2.2: Automated bottleneck detection
# ------------------------------

nano bottleneck_analyzer.sh
chmod +x bottleneck_analyzer.sh
./bottleneck_analyzer.sh
ls -lh bottleneck_analysis_*.log | tail -1

# ------------------------------
# Task 2.3: Baseline measurement (idle vs loaded)
# ------------------------------

nano baseline_measurement.sh
chmod +x baseline_measurement.sh
./baseline_measurement.sh
cat baseline_20260225_151505/baseline_report.txt

# ------------------------------
# Task 3.1: Check current/available schedulers + scheduler guide
# ------------------------------

nano check_schedulers.sh
chmod +x check_schedulers.sh
./check_schedulers.sh

nano scheduler_guide.txt
cat scheduler_guide.txt

# ------------------------------
# Task 3.2: Scheduler performance testing
# ------------------------------

nano scheduler_performance_test.sh
chmod +x scheduler_performance_test.sh

lsblk

# Attempted wrong device (sda), then corrected to nvme0n1
sudo ./scheduler_performance_test.sh sda
sudo ./scheduler_performance_test.sh nvme0n1

# ------------------------------
# Task 3.3: Apply scheduler optimization + persist with udev
# ------------------------------

nano optimize_schedulers.sh
chmod +x optimize_schedulers.sh
sudo ./optimize_schedulers.sh

nano make_persistent.sh
chmod +x make_persistent.sh
sudo ./make_persistent.sh

sudo cat /etc/udev/rules.d/60-io-schedulers.rules

# ------------------------------
# Task 3.4: Validate optimization
# ------------------------------

nano validate_optimization.sh
chmod +x validate_optimization.sh
./validate_optimization.sh
ls -la validation_20260225_153420

# ------------------------------
# Troubleshooting: permission + scheduler availability + safer cache drop + ionice
# ------------------------------

# Verify available schedulers (post-change)
cat /sys/block/nvme0n1/queue/scheduler

# Safer method for writing scheduler config
echo kyber | sudo tee /sys/block/nvme0n1/queue/scheduler

# Use ionice to reduce I/O priority during heavy tests
ionice -c 3 ./io_workload_generator.sh mixed

# Safe cache drop (sudo + tee)
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
