#!/bin/bash
# Lab 17 - Analyzing Application Performance with ps
# Commands Executed During Lab (sequential, no explanations)

# ------------------------------------------------------------
# Task 1.1 - Basic ps Command Usage
# ------------------------------------------------------------

pwd
ps aux
ps auxf
ps ux

# ------------------------------------------------------------
# Task 1.2 - Advanced ps Command Options
# ------------------------------------------------------------

ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu
ps -eo pid,user,cmd,pcpu,pmem,time --sort=-pcpu | head -20
ps -eLf | head -15

# ------------------------------------------------------------
# Task 1.3 - Creating Sample Workloads for Analysis
# ------------------------------------------------------------

nano cpu_intensive.sh
chmod +x cpu_intensive.sh
ls -l cpu_intensive.sh

which bc || sudo yum install -y bc
./cpu_intensive.sh &
CPU_PID=$!
echo "CPU-intensive process started with PID: $CPU_PID"

nano memory_intensive.py
chmod +x memory_intensive.py
ls -l memory_intensive.py

python3 memory_intensive.py &
MEM_PID=$!
echo "Memory-intensive process started with PID: $MEM_PID"

# ------------------------------------------------------------
# Task 2.1 - Real-time Process Monitoring
# ------------------------------------------------------------

watch -n 2 'ps aux --sort=-%cpu | head -20'
watch -n 2 'ps aux --sort=-%mem | head -20'

nano process_monitor.sh
chmod +x process_monitor.sh
ls -l process_monitor.sh
./process_monitor.sh

# ------------------------------------------------------------
# Task 2.2 - Detailed Process Analysis
# ------------------------------------------------------------

ps -p $CPU_PID -o pid,ppid,cmd,pcpu,pmem,etime,time
ps -p $CPU_PID -o pid,stat,wchan,cmd

nano track_process.sh
chmod +x track_process.sh
ls -l track_process.sh
./track_process.sh $CPU_PID

# ------------------------------------------------------------
# Task 2.3 - Identifying Performance Bottlenecks
# ------------------------------------------------------------

nano identify_issues.sh
chmod +x identify_issues.sh
ls -l identify_issues.sh
./identify_issues.sh

# ------------------------------------------------------------
# Task 3.1 - Process Priority Management
# ------------------------------------------------------------

ps -eo pid,ni,cmd --sort=pid | head -20
sudo renice 10 $CPU_PID
echo "Changed priority for PID $CPU_PID"
ps -p $CPU_PID -o pid,ni,cmd

nice -n 15 ./cpu_intensive.sh &
LOW_PRIORITY_PID=$!
echo "Started low-priority process with PID: $LOW_PRIORITY_PID"

# ------------------------------------------------------------
# Task 3.2 - Safe Process Termination
# ------------------------------------------------------------

nano safe_terminate.sh
chmod +x safe_terminate.sh
ls -l safe_terminate.sh

./safe_terminate.sh $CPU_PID TERM
./safe_terminate.sh $MEM_PID TERM

if ps -p $CPU_PID > /dev/null 2>&1; then
  ./safe_terminate.sh $CPU_PID KILL
fi

if ps -p $LOW_PRIORITY_PID > /dev/null 2>&1; then
  ./safe_terminate.sh $LOW_PRIORITY_PID KILL
fi

# ------------------------------------------------------------
# Task 3.3 - Process Management Best Practices
# ------------------------------------------------------------

nano process_manager.sh
chmod +x process_manager.sh
ls -l process_manager.sh

./process_manager.sh --top
./process_manager.sh --report
ls -l process_report_20260225_154512.txt
./process_manager.sh --search "python"

# ------------------------------------------------------------
# Task 4.1 - Process Resource Tracking
# ------------------------------------------------------------

nano resource_tracker.sh
chmod +x resource_tracker.sh
ls -l resource_tracker.sh

python3 -c "import time; [time.sleep(0.1) for _ in range(1000)]" &
TEST_PID1=$!
dd if=/dev/zero of=/tmp/testfile bs=1M count=100 2>/dev/null &
TEST_PID2=$!

timeout 60 ./resource_tracker.sh

kill $TEST_PID1 $TEST_PID2 2>/dev/null
rm -f /tmp/testfile
ls -l process_resources.log

nano analyze_logs.sh
chmod +x analyze_logs.sh
./analyze_logs.sh

# ------------------------------------------------------------
# Task 4.2 - System Performance Baseline
# ------------------------------------------------------------

nano system_baseline.sh
chmod +x system_baseline.sh
./system_baseline.sh
ls -l system_baseline_20260225.txt

# ------------------------------------------------------------
# Troubleshooting Commands Used
# ------------------------------------------------------------

sync
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

kill -TERM $PID
sleep 5
kill -INT $PID
sleep 5
kill -KILL $PID

ps aux | grep -E '\[.*\]'
iostat 1 5

cat /proc/meminfo | head -15
pmap -x $PID | head -15
