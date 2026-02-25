#!/bin/bash
# Lab 19 - Using eBPF for System Performance Analysis
# Commands Executed During Lab (sequential, no explanations)

# ------------------------------------------------------------
# Task 1.1 - Verify System Compatibility
# ------------------------------------------------------------

uname -r
ls /sys/kernel/debug/tracing/ | head -15
mount | grep bpf

# ------------------------------------------------------------
# Task 1.2 - Install eBPF Tools
# ------------------------------------------------------------

sudo dnf install -y epel-release
sudo dnf install -y bcc-tools kernel-devel-$(uname -r)
sudo dnf install -y python3-bcc

# ------------------------------------------------------------
# Task 1.3 - Verify Installation
# ------------------------------------------------------------

which syscount.py
ls /usr/share/bcc/tools/ | head -20
sudo ls /sys/kernel/debug/tracing/events/ | head -10

# ------------------------------------------------------------
# Task 1.4 - Enable Debug Filesystem
# ------------------------------------------------------------

sudo mount -t debugfs debugfs /sys/kernel/debug
mount | grep debugfs
sudo ls -la /sys/kernel/debug/tracing/ | head -12

# ------------------------------------------------------------
# Task 2.1 - Basic System Call Monitoring (syscount)
# ------------------------------------------------------------

sudo /usr/share/bcc/tools/syscount.py -d 10

sleep 20 &
TARGET_PID=$!
echo "Using PID: $TARGET_PID"
sudo /usr/share/bcc/tools/syscount.py -p $TARGET_PID -d 5

# ------------------------------------------------------------
# Task 2.2 - Create Test Workload
# ------------------------------------------------------------

nano test_workload.sh
chmod +x test_workload.sh
ls -l test_workload.sh

# ------------------------------------------------------------
# Task 2.3 - Monitor System Calls During Workload
# ------------------------------------------------------------

sudo /usr/share/bcc/tools/syscount.py -d 30 > syscount_output.txt &
sleep 2
./test_workload.sh
wait
cat syscount_output.txt

# ------------------------------------------------------------
# Task 2.4 - Advanced syscount Usage
# ------------------------------------------------------------

sudo /usr/share/bcc/tools/syscount.py -P -d 15 | head -25
sudo /usr/share/bcc/tools/syscount.py -e open,close,read,write -d 10
sudo /usr/share/bcc/tools/syscount.py -i 2 -d 10

# ------------------------------------------------------------
# Task 2.5 - Analyze syscount Output
# ------------------------------------------------------------

nano analyze_syscalls.py
chmod +x analyze_syscalls.py
python3 analyze_syscalls.py syscount_output.txt

# ------------------------------------------------------------
# Task 3.1 - Understanding gethostlatency
# ------------------------------------------------------------

ls /usr/share/bcc/tools/gethostlatency.py
sudo /usr/share/bcc/tools/gethostlatency.py --help | head -20

# ------------------------------------------------------------
# Task 3.2 - Basic DNS Latency Monitoring
# ------------------------------------------------------------

sudo /usr/share/bcc/tools/gethostlatency.py

# ------------------------------------------------------------
# Task 3.3 - Generate DNS Resolution Activity
# ------------------------------------------------------------

which nslookup || sudo dnf install -y bind-utils

nano dns_test.sh
chmod +x dns_test.sh
./dns_test.sh

# ------------------------------------------------------------
# Task 3.4 - Advanced gethostlatency Usage
# ------------------------------------------------------------

sudo /usr/share/bcc/tools/gethostlatency.py -p $(pgrep -n bash) -t

sudo /usr/share/bcc/tools/gethostlatency.py -t > dns_latency.log &
./dns_test.sh
sleep 5
sudo pkill -f gethostlatency.py
head -15 dns_latency.log

# ------------------------------------------------------------
# Task 3.5 - Create DNS Latency Analysis Tool
# ------------------------------------------------------------

nano analyze_dns_latency.py
chmod +x analyze_dns_latency.py
python3 analyze_dns_latency.py dns_latency.log

# ------------------------------------------------------------
# Task 4.1 - Comprehensive System Monitoring
# ------------------------------------------------------------

nano comprehensive_monitor.sh
chmod +x comprehensive_monitor.sh
./comprehensive_monitor.sh

# ------------------------------------------------------------
# Task 4.2 - Performance Issue Simulation
# ------------------------------------------------------------

nano simulate_issues.sh
chmod +x simulate_issues.sh
./simulate_issues.sh

# ------------------------------------------------------------
# Task 4.3 - Real-time Performance Analysis Tool
# ------------------------------------------------------------

nano realtime_analyzer.py
chmod +x realtime_analyzer.py
echo "Real-time analyzer created. In production, this would connect to live eBPF tools."
python3 realtime_analyzer.py ebpf_monitoring_20260225_184950/syscount_detailed.txt ebpf_monitoring_20260225_184950/dns_latency.txt

# ------------------------------------------------------------
# Task 4.4 - Performance Report Generation
# ------------------------------------------------------------

nano generate_performance_report.py
chmod +x generate_performance_report.py
python3 generate_performance_report.py ebpf_monitoring_20260225_184950
tail -n 25 ebpf_monitoring_20260225_184950/performance_report.txt
