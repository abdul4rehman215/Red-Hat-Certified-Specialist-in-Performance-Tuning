#!/bin/bash
# Lab 13 - System Diagnostics with sosreport
# Commands Executed During Lab (sequential, no explanations)

# ----------------------------------------
# Task 1.1: Verify sosreport installation
# ----------------------------------------

which sosreport
sosreport --version
sudo dnf install sos -y

# ----------------------------------------
# Task 1.2: Explore sosreport help + plugins
# ----------------------------------------

sosreport --help
sosreport --list-plugins
sosreport --describe networking
sosreport --describe kernel
sosreport --describe performance

# ----------------------------------------
# Task 1.3: Run basic sosreport collection
# ----------------------------------------

sudo mkdir -p /var/tmp/sosreports
cd /var/tmp/sosreports
sudo sosreport --batch --tmp-dir=/var/tmp/sosreports

# ----------------------------------------
# Task 1.4: Run targeted sosreport collections
# ----------------------------------------

sudo sosreport --batch --only-plugins=networking,network,firewalld,iptables --tmp-dir=/var/tmp/sosreports
sudo sosreport --batch --only-plugins=performance,kernel,memory,processor,block --tmp-dir=/var/tmp/sosreports
sudo sosreport --batch --only-plugins=block,filesys,lvm2,md,multipath --tmp-dir=/var/tmp/sosreports

# ----------------------------------------
# Task 1.5: Extract and examine report structure
# ----------------------------------------

ls -la /var/tmp/sosreports/
LATEST_REPORT=$(ls -t /var/tmp/sosreports/sosreport-*.tar.xz | head -1)
echo "Extracting: $LATEST_REPORT"
cd /var/tmp/sosreports
tar -xf $LATEST_REPORT
EXTRACTED_DIR=$(basename $LATEST_REPORT .tar.xz)
cd $EXTRACTED_DIR
tree -L 2 . || find . -maxdepth 2 -type d

# ----------------------------------------
# Task 2.1: System overview analysis (inside extracted report)
# ----------------------------------------

cd /var/tmp/sosreports/sosreport-*
echo "=== HOSTNAME INFORMATION ==="
cat hostname
echo -e "\n=== SYSTEM UPTIME ==="
cat uptime
echo -e "\n=== SYSTEM DATE ==="
cat date
echo -e "\n=== OS RELEASE INFORMATION ==="
cat etc/os-release
echo -e "\n=== KERNEL VERSION ==="
cat uname
echo -e "\n=== SYSTEM LOAD AVERAGE ==="
cat proc/loadavg

# ----------------------------------------
# Task 2.2: Hardware and performance analysis
# ----------------------------------------

echo "=== CPU INFORMATION ==="
cat proc/cpuinfo | grep -E "(processor|model name|cpu MHz|cache size)" | head -20
echo -e "\n=== CPU UTILIZATION ==="
if [ -f sar_files/sar* ]; then
  echo "SAR data available for detailed CPU analysis"
  ls sar_files/
fi

echo -e "\n=== MEMORY INFORMATION ==="
cat proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree)"
echo -e "\n=== MEMORY USAGE ANALYSIS ==="
if [ -f free ]; then
  cat free
fi
echo -e "\n=== CHECKING FOR MEMORY PRESSURE ==="
if [ -f proc/pressure/memory ]; then
  cat proc/pressure/memory
fi

# ----------------------------------------
# Task 2.3: Storage and filesystem analysis
# ----------------------------------------

echo "=== DISK USAGE INFORMATION ==="
cat df
echo -e "\n=== FILESYSTEM MOUNT INFORMATION ==="
cat proc/mounts | grep -v tmpfs | head -10
echo -e "\n=== BLOCK DEVICE INFORMATION ==="
if [ -f lsblk ]; then
  cat lsblk
fi

echo -e "\n=== I/O STATISTICS ==="
if [ -f proc/diskstats ]; then
  echo "Disk statistics available:"
  head -10 proc/diskstats
fi

echo -e "\n=== CHECKING FILESYSTEM ERRORS ==="
grep -i "error\|fail\|corrupt" var/log/messages* 2>/dev/null | head -5 || echo "No obvious filesystem errors found"

# ----------------------------------------
# Task 2.4: Network configuration analysis
# ----------------------------------------

echo "=== NETWORK INTERFACE INFORMATION ==="
if [ -f ip_addr ]; then
  cat ip_addr
fi
echo -e "\n=== NETWORK ROUTING INFORMATION ==="
if [ -f ip_route ]; then
  cat ip_route
fi
echo -e "\n=== NETWORK STATISTICS ==="
if [ -f proc/net/dev ]; then
  cat proc/net/dev
fi

echo -e "\n=== DNS CONFIGURATION ==="
if [ -f etc/resolv.conf ]; then
  cat etc/resolv.conf
fi

echo -e "\n=== NETWORK SERVICE STATUS ==="
grep -i "network\|dhcp" systemctl_list-units 2>/dev/null | head -5 || echo "Network service information not available in this format"

# ----------------------------------------
# Task 2.5: Service and process analysis
# ----------------------------------------

echo "=== TOP PROCESSES BY CPU/MEMORY ==="
if [ -f ps ]; then
  echo "Process information available:"
  head -20 ps
fi

echo -e "\n=== FAILED SERVICES ==="
grep -i "failed\|error" systemctl_list-units 2>/dev/null | head -10 || echo "No failed services found in current format"

echo -e "\n=== SYSTEM LOAD ANALYSIS ==="
if [ -f proc/loadavg ]; then
  LOAD=$(cat proc/loadavg | awk '{print $1}')
  CPU_COUNT=$(grep -c processor proc/cpuinfo)
  echo "Current load: $LOAD"
  echo "CPU count: $CPU_COUNT"
  echo "Load per CPU: $(echo "scale=2; $LOAD / $CPU_COUNT" | bc 2>/dev/null || echo "calculation unavailable")"
fi

# ----------------------------------------
# Task 2.6: Log analysis for system issues
# ----------------------------------------

echo "=== RECENT SYSTEM ERRORS ==="
if [ -d var/log ]; then
  echo "Checking for critical errors in system logs:"
  grep -i "error\|critical\|fail" var/log/messages* 2>/dev/null | tail -10 || echo "No recent critical errors found"
fi

echo -e "\n=== KERNEL MESSAGES ==="
if [ -f var/log/dmesg ]; then
  echo "Recent kernel messages:"
  tail -20 var/log/dmesg
fi

echo -e "\n=== AUTHENTICATION FAILURES ==="
if [ -f var/log/secure ]; then
  echo "Recent authentication issues:"
  grep -i "failed\|invalid" var/log/secure 2>/dev/null | tail -5 || echo "No recent authentication failures"
fi

# ----------------------------------------
# Task 2.7: Create and run performance analysis script
# ----------------------------------------

nano /tmp/analyze_performance.sh
chmod +x /tmp/analyze_performance.sh
/tmp/analyze_performance.sh

# ----------------------------------------
# Task 2.8: Generate system health report artifact
# ----------------------------------------

nano /tmp/system_health_report.txt
echo "Analyzing system for critical issues..." >> /tmp/system_health_report.txt

if [ -f proc/loadavg ]; then
  LOAD=$(awk '{print $1}' proc/loadavg)
  CPU_COUNT=$(grep -c processor proc/cpuinfo 2>/dev/null || echo 1)
  if (( $(echo "$LOAD > $CPU_COUNT * 2" | bc -l 2>/dev/null || echo 0) )); then
    echo "- HIGH CPU LOAD: Load average ($LOAD) exceeds CPU capacity" >> /tmp/system_health_report.txt
  fi
fi

if [ -f proc/meminfo ]; then
  AVAILABLE=$(grep MemAvailable proc/meminfo | awk '{print $2}')
  TOTAL=$(grep MemTotal proc/meminfo | awk '{print $2}')
  if [ "$AVAILABLE" -lt "$((TOTAL/10))" ] 2>/dev/null; then
    echo "- LOW MEMORY: Available memory is less than 10% of total" >> /tmp/system_health_report.txt
  fi
fi

if [ -f df ]; then
  while read line; do
    if echo "$line" | grep -q "%"; then
      USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
      FILESYSTEM=$(echo "$line" | awk '{print $6}')
      if [ "$USAGE" -gt 95 ] 2>/dev/null; then
        echo "- DISK FULL: $FILESYSTEM is ${USAGE}% full" >> /tmp/system_health_report.txt
      fi
    fi
  done < df
fi

echo "" >> /tmp/system_health_report.txt
echo "=== RECOMMENDATIONS ===" >> /tmp/system_health_report.txt
echo "1. Review detailed analysis above for specific issues" >> /tmp/system_health_report.txt
echo "2. Monitor resource usage trends over time" >> /tmp/system_health_report.txt
echo "3. Implement proactive monitoring for identified bottlenecks" >> /tmp/system_health_report.txt
echo "4. Consider hardware upgrades for consistently high resource usage" >> /tmp/system_health_report.txt
cat /tmp/system_health_report.txt

# ----------------------------------------
# Advanced analysis: reusable analyzer script
# ----------------------------------------

sudo nano /usr/local/bin/sosreport-analyzer
sudo chmod +x /usr/local/bin/sosreport-analyzer
/usr/local/bin/sosreport-analyzer $(pwd)

# ----------------------------------------
# Troubleshooting: command not found / perms / size / script errors
# ----------------------------------------

sudo dnf install sos
which sosreport
sosreport --version

sudo sosreport --batch
df -h /tmp
ls -ld /tmp

sudo sosreport --batch --only-plugins=kernel,memory,networking
sudo sosreport --batch --skip-plugins=logs,rpm

sudo dnf install bc -y
find . -name "*.txt" -o -name "proc" -o -name "etc" | head -10

# ----------------------------------------
# Best practices: example automation scripts created
# ----------------------------------------

sudo nano /usr/local/bin/monthly-sosreport
sudo chmod +x /usr/local/bin/monthly-sosreport

sudo nano /usr/local/bin/sosreport-workflow
sudo chmod +x /usr/local/bin/sosreport-workflow
