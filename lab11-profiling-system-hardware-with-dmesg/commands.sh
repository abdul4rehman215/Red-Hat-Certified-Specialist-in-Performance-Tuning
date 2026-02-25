#!/bin/bash
# Lab 11 - Profiling System Hardware with dmesg
# Commands Executed During Lab (sequential, no explanations)

# ----------------------------------------
# Task 1: Understanding dmesg and Kernel Ring Buffer
# ----------------------------------------

dmesg
dmesg -T
dmesg --color=always

dmesg | head -10
dmesg -x | head -12
dmesg -l err,warn | tail -20

# ----------------------------------------
# Task 2: Hardware Detection Messages
# CPU Analysis
# ----------------------------------------

dmesg | grep -i cpu | head -20
dmesg | grep -i "cpu.*feature" | head -10
dmesg | grep -i "cpufreq\|scaling" | head -10

nano cpu_analysis.sh
chmod +x cpu_analysis.sh
./cpu_analysis.sh

# ----------------------------------------
# Task 2: Memory Detection Analysis
# ----------------------------------------

dmesg | grep -i memory | head -20
dmesg | grep -i "memory.*map\|e820" | head -12
dmesg | grep -i "memory.*error\|memory.*fail"

nano memory_analysis.sh
chmod +x memory_analysis.sh
./memory_analysis.sh

# ----------------------------------------
# Task 2: Storage Device Analysis
# ----------------------------------------

dmesg | grep -i "sd[a-z]\|nvme\|ata" | head -25
dmesg | grep -i "error\|fail" | grep -i "disk\|ata\|scsi"
dmesg | grep -i "ext4\|xfs\|filesystem" | head -15

nano storage_analysis.sh
chmod +x storage_analysis.sh
./storage_analysis.sh

# ----------------------------------------
# Task 3: Network Hardware Analysis
# ----------------------------------------

dmesg | grep -i "eth\|network\|link" | head -25
dmesg | grep -i "driver.*network\|net.*driver" | head -20
dmesg | grep -i "network.*error\|link.*down\|network.*fail"

nano network_analysis.sh
chmod +x network_analysis.sh
./network_analysis.sh

# ----------------------------------------
# Task 4: Advanced dmesg Filtering and Analysis
# Time-Based Filtering
# ----------------------------------------

dmesg --since="$(date -d 'today 00:00' '+%Y-%m-%d %H:%M:%S')" | head -25
dmesg --since="1 hour ago" | tail -20
dmesg --since="2 hours ago" --until="1 hour ago" | tail -20

# Facility and Level Filtering
dmesg -f kern | head -20
dmesg -l err | tail -20
dmesg -l crit,alert | tail -20

nano dmesg_filter.sh
chmod +x dmesg_filter.sh
./dmesg_filter.sh

# ----------------------------------------
# Task 5: Identifying Hardware Issues
# ----------------------------------------

dmesg | grep -i "i/o error\|input/output error"
dmesg | grep -i "timeout\|timed out" | head -20
dmesg | grep -i "hardware error\|hardware failure"
dmesg | grep -i "thermal\|temperature\|overheat" | head -20

nano hardware_health_check.sh
chmod +x hardware_health_check.sh
./hardware_health_check.sh

# Real-time monitoring
dmesg -w
dmesg -w -l err,crit,alert

nano realtime_monitor.sh
chmod +x realtime_monitor.sh

# ----------------------------------------
# Task 6: Performance Analysis Using dmesg
# ----------------------------------------

dmesg | grep -i "boot\|init" | head -20
dmesg | grep -i "slow\|delay\|wait"

nano boot_performance.sh
chmod +x boot_performance.sh
./boot_performance.sh

dmesg | grep -i "out of memory\|oom\|memory pressure"
dmesg | grep -i "cpu.*stall\|cpu.*hang\|cpu.*lock"
dmesg | grep -i "i/o.*slow\|disk.*slow\|high load"

# ----------------------------------------
# Task 7: Custom Monitoring Solutions
# ----------------------------------------

nano hardware_monitor.sh
chmod +x hardware_monitor.sh
./hardware_monitor.sh

cat /var/log/hardware_monitor.log

nano hardware_profile.sh
chmod +x hardware_profile.sh
./hardware_profile.sh

# ----------------------------------------
# Task 8: Troubleshooting Scripts
# ----------------------------------------

nano diagnose_storage.sh
chmod +x diagnose_storage.sh
./diagnose_storage.sh

nano diagnose_network.sh
chmod +x diagnose_network.sh
./diagnose_network.sh

nano diagnose_memory.sh
chmod +x diagnose_memory.sh
./diagnose_memory.sh
