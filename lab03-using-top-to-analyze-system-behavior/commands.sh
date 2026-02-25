#!/bin/bash
# Lab 03 - Using top to Analyze System Behavior
# Commands Executed During Lab (sequential, clean, ready to paste)

# ------------------------------
# Task 1.1: Launch and Observe top
# ------------------------------

# Interactive top (observed then quit with q)
top

# Interactive top navigation actions: pressed h, 1, m, then q
top

# Field management view (pressed f, observed, then q)
top

# ------------------------------
# Task 1.3: Install and Run stress for CPU load
# ------------------------------

# Verify stress tool
stress --version

# Attempt yum (not available on RHEL 9)
sudo yum install stress -y

# Fix: Use dnf
sudo dnf install -y stress

# Create CPU load in background
stress --cpu 4 --timeout 300s &

# Observe CPU load in top while stress runs
top

# ------------------------------
# Task 1.4: Create memory load and observe in top
# ------------------------------

stress --vm 2 --vm-bytes 512M --timeout 300s &

# Observe memory in top (pressed M to sort by memory)
top

# ------------------------------
# Task 2.1: Create workload simulation script and run tests
# ------------------------------

# Create script (saved as ~/resource_test.sh)
nano resource_test.sh
chmod +x resource_test.sh

# Run CPU hog and capture PID
./resource_test.sh cpu &
CPU_PID=$!
echo "CPU hog PID: $CPU_PID"

# Run memory hog and capture PID
./resource_test.sh memory &
MEMORY_PID=$!
echo "Memory hog PID: $MEMORY_PID"

# Run I/O hog and capture PID
./resource_test.sh io &
IO_PID=$!
echo "I/O hog PID: $IO_PID"

# Observe workloads in top
top

# ------------------------------
# Task 2.2: top interactive features (filter, highlight, locate)
# ------------------------------

# Filter by user (pressed u, entered root, then q)
top

# Enable colors z and highlight sort column x, then q
top

# Locate a process (pressed L, searched python3), then q
top

# ------------------------------
# Task 2.3: System inefficiency script
# ------------------------------

nano system_monitor.sh
chmod +x system_monitor.sh
./system_monitor.sh

# Install net-tools if netstat missing (only if needed)
sudo dnf install -y net-tools

# ------------------------------
# Task 3.1: Understanding priorities and checking nice values
# ------------------------------

ps -eo pid,ppid,ni,comm --sort=-ni | head -20

# ------------------------------
# Task 3.2: Start processes with different priorities using nice
# ------------------------------

nice -n 19 ./resource_test.sh cpu &
LOW_PRIORITY_PID=$!
echo "Low priority PID: $LOW_PRIORITY_PID"

sudo nice -n -10 ./resource_test.sh cpu &
HIGH_PRIORITY_PID=$!
echo "High priority PID: $HIGH_PRIORITY_PID"

./resource_test.sh cpu &
NORMAL_PRIORITY_PID=$!
echo "Normal priority PID: $NORMAL_PRIORITY_PID"

# Verify CPU allocation differences
ps -o pid,ni,%cpu,comm -p $LOW_PRIORITY_PID,$HIGH_PRIORITY_PID,$NORMAL_PRIORITY_PID

# ------------------------------
# Task 3.3: Modify priorities of running processes using renice
# ------------------------------

ps aux | grep resource_test | head -10

renice 15 $NORMAL_PRIORITY_PID
sudo renice -5 $LOW_PRIORITY_PID

ps -eo pid,ppid,ni,comm | egrep "PID|resource_test|bash" | head -25

# ------------------------------
# Task 3.4: Priority management script
# ------------------------------

nano priority_manager.sh
chmod +x priority_manager.sh

./priority_manager.sh list
./priority_manager.sh monitor

# ------------------------------
# Task 3.5: Performance comparison test
# ------------------------------

nano performance_test.sh
chmod +x performance_test.sh
./performance_test.sh

# ------------------------------
# Task 3.6: Save top configuration + create top monitoring script
# ------------------------------

# Save top configuration (pressed f, then W, then q)
top

ls -la ~/.toprc

nano top_monitor.sh
chmod +x top_monitor.sh
./top_monitor.sh

# ------------------------------
# Troubleshooting checks performed
# ------------------------------

pkill top
htop

sudo renice -10 $NORMAL_PRIORITY_PID
ps -p $NORMAL_PRIORITY_PID

iostat -x 1 5
df -h
ps aux | grep -i zombie

free -h
cat /proc/meminfo | head -15

# ------------------------------
# Best practices script
# ------------------------------

nano monitoring_best_practices.sh
chmod +x monitoring_best_practices.sh
./monitoring_best_practices.sh

ls -la /tmp/system_check.sh /tmp/resource_alert.sh

# ------------------------------
# Lab Cleanup
# ------------------------------

pkill -f resource_test.sh
pkill stress

rm -f resource_test.sh system_monitor.sh priority_manager.sh
rm -f performance_test.sh top_monitor.sh monitoring_best_practices.sh
rm -f system_performance.log
rm -f /tmp/testfile /tmp/system_check.sh /tmp/resource_alert.sh

echo "Lab cleanup completed."
