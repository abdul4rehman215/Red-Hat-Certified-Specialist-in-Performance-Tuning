#!/bin/bash
# Lab 18 - SystemTap for Kernel Performance Analysis
# Commands Executed During Lab (sequential, no explanations)

# ------------------------------------------------------------
# Task 1.1 - Verify SystemTap Installation
# ------------------------------------------------------------

rpm -qa | grep systemtap
stap --version

ls /usr/lib/debug/lib/modules/$(uname -r)/
sudo stap -e 'probe begin { println("SystemTap is working!"); exit() }'

# ------------------------------------------------------------
# Task 1.2 - Install Additional Components (if needed)
# ------------------------------------------------------------

sudo dnf install -y systemtap systemtap-runtime
sudo dnf install -y kernel-debuginfo kernel-debuginfo-common-$(uname -m)
sudo dnf install -y kernel-devel gcc

# ------------------------------------------------------------
# Task 1.3 - Test Basic SystemTap Functionality
# ------------------------------------------------------------

nano hello_systemtap.stp
chmod +x hello_systemtap.stp
ls -l hello_systemtap.stp
sudo stap hello_systemtap.stp

# ------------------------------------------------------------
# Task 2.1 - Create Basic I/O Monitoring Script
# ------------------------------------------------------------

nano io_monitor.stp
chmod +x io_monitor.stp
ls -l io_monitor.stp

# ------------------------------------------------------------
# Task 2.2 - Create Advanced I/O Latency Tracking Script
# ------------------------------------------------------------

nano io_latency.stp
chmod +x io_latency.stp
ls -l io_latency.stp

# ------------------------------------------------------------
# Task 2.3 - Test I/O Monitoring Scripts
# ------------------------------------------------------------

sudo stap io_monitor.stp

dd if=/dev/zero of=/tmp/testfile bs=1M count=100
cp /tmp/testfile /tmp/testfile_copy
find /usr -name "*.conf" -type f | head -20 | xargs cat > /tmp/config_dump
rm /tmp/testfile /tmp/testfile_copy /tmp/config_dump

sudo stap io_latency.stp

# ------------------------------------------------------------
# Task 3.1 - Create Comprehensive System Call Tracer
# ------------------------------------------------------------

nano syscall_tracer.stp
chmod +x syscall_tracer.stp
ls -l syscall_tracer.stp

# ------------------------------------------------------------
# Task 3.2 - Create Process-Specific System Call Monitor
# ------------------------------------------------------------

nano process_monitor.stp
chmod +x process_monitor.stp
ls -l process_monitor.stp

# ------------------------------------------------------------
# Task 3.3 - Test System Call Monitoring
# ------------------------------------------------------------

sudo stap syscall_tracer.stp

ls -la /etc/
find /var/log -name "*.log" | head -10
ps aux | grep systemd
netstat -tuln
df -h

sudo stap process_monitor.stp
sudo systemctl status sshd
curl -I http://localhost

# ------------------------------------------------------------
# Task 4.1 - Create I/O Bottleneck Detection Script
# ------------------------------------------------------------

nano io_bottleneck_detector.stp
chmod +x io_bottleneck_detector.stp

# ------------------------------------------------------------
# Task 4.2 - Create Memory and CPU Performance Monitor
# ------------------------------------------------------------

nano performance_monitor.stp
chmod +x performance_monitor.stp

# ------------------------------------------------------------
# Task 4.3 - Create I/O Bottleneck Simulation and Analysis
# ------------------------------------------------------------

nano generate_io_load.sh
chmod +x generate_io_load.sh

sudo stap io_bottleneck_detector.stp &
STAP_PID=$!
echo "SystemTap detector running with PID: $STAP_PID"
sleep 5
./generate_io_load.sh
sleep 30
sudo kill $STAP_PID

sudo stap performance_monitor.stp &
PERF_PID=$!
echo "Performance monitor running with PID: $PERF_PID"

(
 yes > /dev/null &
 CPU_PID=$!

 python3 -c "
import time
data = []
for i in range(1000):
 data.append('x' * 1024 * 1024) # 1MB chunks
 time.sleep(0.01)
" &
 MEM_PID=$!

 ./generate_io_load.sh &
 IO_PID=$!

 sleep 60

 kill $CPU_PID $MEM_PID $IO_PID 2>/dev/null
) &
wait

sudo kill $PERF_PID

# ------------------------------------------------------------
# Task 5.1 - Create Custom Kernel Event Tracer
# ------------------------------------------------------------

nano kernel_event_tracer.stp
chmod +x kernel_event_tracer.stp
sudo stap kernel_event_tracer.stp

# ------------------------------------------------------------
# Task 5.2 - Real-time Performance Dashboard
# ------------------------------------------------------------

nano realtime_dashboard.stp
chmod +x realtime_dashboard.stp
ls -l realtime_dashboard.stp

sudo stap realtime_dashboard.stp -o /tmp/dashboard.log &
DASH_PID=$!
echo "Dashboard running as PID: $DASH_PID"
ls -l /tmp/dashboard.log

tail -f /tmp/dashboard.log

dd if=/dev/zero of=/tmp/dash_test bs=1M count=30 2>/dev/null
rm -f /tmp/dash_test

sudo kill $DASH_PID
tail -n 3 /tmp/dashboard.log
