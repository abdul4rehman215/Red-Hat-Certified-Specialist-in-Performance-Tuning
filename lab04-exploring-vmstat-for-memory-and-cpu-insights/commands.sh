#!/bin/bash
# Lab 04 - Exploring vmstat for Memory and CPU Insights
# Commands Executed During Lab (sequential, clean, ready to paste)

# ------------------------------
# Task 1.1: Verify vmstat and review docs/help
# ------------------------------

which vmstat

# Manual opened then exited (interactive)
man vmstat

vmstat --help

# ------------------------------
# Task 1.2: Basic vmstat snapshot
# ------------------------------

vmstat

# ------------------------------
# Task 1.3: Continuous monitoring
# ------------------------------

# Continuous updates every 2 seconds (ran ~30 seconds; stopped with Ctrl+C)
vmstat 2

# Fixed count: 5 reports, 3 seconds apart
vmstat 3 5

# ------------------------------
# Task 2.1: Memory load test using script
# ------------------------------

nano memory_test.sh
chmod +x memory_test.sh

# Terminal 1: start vmstat monitoring
vmstat 1

# Terminal 2: run memory test
./memory_test.sh

# ------------------------------
# Task 2.2: Swap monitoring and swap pressure test
# ------------------------------

free -h
swapon --show

nano swap_test.sh
chmod +x swap_test.sh

# Terminal 1: monitor swap activity
vmstat 1

# Terminal 2: run swap pressure test
./swap_test.sh

# ------------------------------
# Task 2.3: Memory analysis report script
# ------------------------------

nano memory_analysis.sh
chmod +x memory_analysis.sh
./memory_analysis.sh

# ------------------------------
# Task 3.1: Baseline CPU monitoring + CPU load generator
# ------------------------------

vmstat 2 10

nano cpu_test.sh
chmod +x cpu_test.sh

# Terminal 1: monitor
vmstat 1

# Terminal 2: run CPU test
./cpu_test.sh

# ------------------------------
# Task 3.2: I/O wait analysis
# ------------------------------

nano io_test.sh
chmod +x io_test.sh

# Terminal 1: monitor I/O wait
vmstat 1

# Terminal 2: run I/O test
./io_test.sh

# ------------------------------
# Task 3.3: CPU analysis report script
# ------------------------------

nano cpu_analysis.sh
chmod +x cpu_analysis.sh
./cpu_analysis.sh

# ------------------------------
# Task 4.1: Disk / partition statistics with vmstat
# ------------------------------

vmstat -d
vmstat -d 3 5

# Attempted (failed because VM uses NVMe, not sda1)
vmstat -p /dev/sda1 2 5

# Identify correct partition
lsblk

# Correct partition stats
vmstat -p /dev/nvme0n1p1 2 5

# ------------------------------
# Task 4.2: Deep memory statistics and trend export
# ------------------------------

vmstat -s | head -25

nano memory_trend.sh
chmod +x memory_trend.sh
./memory_trend.sh

# ------------------------------
# Task 4.3: System baseline script
# ------------------------------

nano system_baseline.sh
chmod +x system_baseline.sh
./system_baseline.sh

ls -lh system_baseline_*.txt
head -25 system_baseline_20260225_143620.txt

# ------------------------------
# Task 5.1: Performance issue simulator
# ------------------------------

nano performance_simulator.sh
chmod +x performance_simulator.sh

# ------------------------------
# Task 5.2: Real-time dashboard + run simulator
# ------------------------------

nano monitor_dashboard.sh
chmod +x monitor_dashboard.sh

# Terminal 1: run dashboard
./monitor_dashboard.sh

# Terminal 2: run simulator (selected option 2 in lab)
./performance_simulator.sh

# ------------------------------
# Task 6: Troubleshooting examples
# ------------------------------

vmstat -V
sudo vmstat 1 3
