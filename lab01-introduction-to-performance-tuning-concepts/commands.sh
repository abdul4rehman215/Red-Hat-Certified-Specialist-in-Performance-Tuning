#!/bin/bash
# Lab 01 - Introduction to Performance Tuning Concepts
# Commands Executed During Lab (sequential, clean, ready to paste)

# ------------------------------
# Task 1: Baseline Setup
# ------------------------------

sudo dnf update -y

sudo dnf install -y htop iotop sysstat perf stress-ng bc lsof

sudo systemctl enable sysstat
sudo systemctl start sysstat
systemctl status sysstat --no-pager -l

# Create baseline monitoring script
nano ~/performance_baseline.sh
chmod +x ~/performance_baseline.sh
~/performance_baseline.sh

# ------------------------------
# Task 2: CPU Bottleneck Detection
# ------------------------------

# Monitor CPU interactively (observed then exited)
htop

# CPU stress test
stress-ng --cpu 4 --timeout 60s --metrics-brief

# Monitor CPU statistics
sar -u 1 10

# Create CPU bottleneck detection script
nano ~/detect_cpu_bottleneck.sh
chmod +x ~/detect_cpu_bottleneck.sh
~/detect_cpu_bottleneck.sh

# ------------------------------
# Task 2: Memory Bottleneck Detection
# ------------------------------

free -h
swapon --show

sar -r 1 5

dmesg | grep -i "killed process"

# Create memory bottleneck detection script
nano ~/detect_memory_bottleneck.sh
chmod +x ~/detect_memory_bottleneck.sh
~/detect_memory_bottleneck.sh

# ------------------------------
# Task 2: Disk I/O Bottleneck Detection
# ------------------------------

# Monitor disk I/O interactively (observed then exited)
sudo iotop

iostat -x 1 5

df -h

# Create disk bottleneck detection script
nano ~/detect_disk_bottleneck.sh
chmod +x ~/detect_disk_bottleneck.sh
~/detect_disk_bottleneck.sh

# ------------------------------
# Task 3: CPU Tuning Strategies
# ------------------------------

# Attempt cpufreq sysfs checks (not available on this cloud VM)
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Install cpupower via kernel-tools
sudo dnf install -y kernel-tools

# Check CPU frequency/governor details
cpupower frequency-info

# Set performance governor
sudo cpupower frequency-set -g performance

# Verify current policy
cpupower frequency-info | grep "current policy"

# Create CPU governor automation script
nano ~/set_cpu_governor.sh
chmod +x ~/set_cpu_governor.sh
~/set_cpu_governor.sh

# Process priority and CPU affinity practice
stress-ng --cpu 1 --timeout 300s &
STRESS_PID=$!

ps -o pid,ni,comm -p $STRESS_PID

sudo renice +10 $STRESS_PID
ps -o pid,ni,comm -p $STRESS_PID

sudo taskset -cp 0,1 $STRESS_PID
taskset -cp $STRESS_PID

kill $STRESS_PID

# Create CPU optimization script (created, not run in lab)
nano ~/optimize_cpu.sh
chmod +x ~/optimize_cpu.sh

# CPU performance monitoring script
nano ~/monitor_cpu_performance.sh
chmod +x ~/monitor_cpu_performance.sh

# Quick test run (~15 seconds)
sudo timeout 15s ~/monitor_cpu_performance.sh

sudo tail -n 5 /var/log/cpu_performance.log

# ------------------------------
# Task 4: Memory Tuning Strategies
# ------------------------------

sysctl vm.swappiness
sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio
sysctl vm.vfs_cache_pressure

sudo nano /etc/sysctl.d/99-memory-tuning.conf

sudo sysctl -p /etc/sysctl.d/99-memory-tuning.conf

echo "Updated memory settings:"
sysctl vm.swappiness vm.dirty_ratio vm.dirty_background_ratio vm.vfs_cache_pressure

# Memory analysis script
nano ~/analyze_memory.sh
chmod +x ~/analyze_memory.sh
~/analyze_memory.sh

# Memory cleanup script
nano ~/cleanup_memory.sh
chmod +x ~/cleanup_memory.sh
~/cleanup_memory.sh

# ------------------------------
# Task 5: Disk I/O Tuning Strategies
# ------------------------------

mount | grep -E "ext4|xfs"

cat /sys/block/*/queue/scheduler

# Disk optimization script
nano ~/optimize_disk.sh
chmod +x ~/optimize_disk.sh
~/optimize_disk.sh

# Disk monitoring + analysis scripts
nano ~/monitor_disk_io.sh
chmod +x ~/monitor_disk_io.sh

nano ~/analyze_disk_io.sh
chmod +x ~/analyze_disk_io.sh
~/analyze_disk_io.sh

# Filesystem tuning script
nano ~/tune_filesystem.sh
chmod +x ~/tune_filesystem.sh
~/tune_filesystem.sh

# ------------------------------
# Comprehensive Performance Testing
# ------------------------------

nano ~/performance_test_suite.sh
chmod +x ~/performance_test_suite.sh

~/performance_test_suite.sh

sed -n '1,120p' ~/performance_results/performance_summary_20260225_113401.txt
