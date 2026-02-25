#!/bin/bash
# Lab 02 - Installing Performance Monitoring Tools
# Commands Executed During Lab (sequential, clean, ready to paste)

# ------------------------------
# Task 1.1: Verify System Information
# ------------------------------

cat /etc/redhat-release
uname -a
hostnamectl

which top
which vmstat
which iostat
which mpstat
which sar

free -h
df -h
lscpu

# ------------------------------
# Task 1.2: Install Required Packages
# ------------------------------

sudo dnf update -y

# Install sysstat (iostat, mpstat, sar)
sudo dnf install -y sysstat

# Install additional tools (first attempt includes nethogs)
sudo dnf install -y htop iotop nethogs

# Fix: enable EPEL for nethogs
sudo dnf install -y epel-release

# Retry install
sudo dnf install -y htop iotop nethogs

# Verify installation
rpm -qa | grep sysstat
which iostat
which mpstat
which sar

# ------------------------------
# Task 1.3: Enable and Configure SAR/sysstat
# ------------------------------

sudo systemctl enable sysstat
sudo systemctl start sysstat
sudo systemctl status sysstat --no-pager -l

# Configure retention/compression
sudo vi /etc/sysconfig/sysstat
sudo grep -E "HISTORY=|COMPRESSAFTER=" /etc/sysconfig/sysstat

sudo systemctl restart sysstat

# Verify scheduled data collection configuration
cat /etc/cron.d/sysstat

# ------------------------------
# Task 2.1: Basic top Monitoring
# ------------------------------

# Interactive top (observed then quit with q)
top

# Batch mode output
top -n 1 -b | head -20

# Filter by user (interactive)
top -u root

# Refresh interval (interactive)
top -d 2

# Save top output to a file
top -n 1 -b > /tmp/top_output.txt
cat /tmp/top_output.txt | head -25

# ------------------------------
# Task 2.2: Using sar (CPU/memory/disk/net/load + historical)
# ------------------------------

sar -u 1 5
sar -r 1 5
sar -d 1 5
sar -n DEV 1 5
sar -q 1 5

# Today's historical data
sar -u

# Yesterday's data file
sar -u -f /var/log/sa/sa$(date -d yesterday +%d)

# Specific time range
sar -u -s 10:00:00 -e 12:00:00

# Generate full system report
sar -A > /tmp/system_report.txt
ls -lh /tmp/system_report.txt
head -20 /tmp/system_report.txt

# ------------------------------
# Task 2.3: Using vmstat
# ------------------------------

vmstat
vmstat 2 10
vmstat -S M 2 5
vmstat -d
vmstat -a 2 5

# Create a vmstat monitor script
nano /tmp/vmstat_monitor.sh
chmod +x /tmp/vmstat_monitor.sh
/tmp/vmstat_monitor.sh

# ------------------------------
# Task 2.4: Using iostat
# ------------------------------

iostat
iostat 2 5
iostat -x 2 5

# Incorrect device example (VM uses NVMe)
iostat -x sda 2 5

# Correct device
iostat -x nvme0n1 2 5

# CPU and disk together
iostat -c -d 2 5

# Export report
iostat -x -t 1 10 > /tmp/iostat_report.txt
ls -lh /tmp/iostat_report.txt

# MB view
iostat -x -m 2 5

# ------------------------------
# Task 3.1: Custom Monitoring Scripts
# ------------------------------

nano /tmp/system_monitor.sh
chmod +x /tmp/system_monitor.sh
/tmp/system_monitor.sh

ls -lh /tmp/system_monitor_*.log | tail -1

# ------------------------------
# Task 3.2: Automated Monitoring (cron + logrotate)
# ------------------------------

crontab -e
crontab -l

sudo nano /etc/logrotate.d/system-monitor
sudo cat /etc/logrotate.d/system-monitor

# ------------------------------
# Task 3.3: Baseline Creation Script
# ------------------------------

nano /tmp/create_baseline.sh
chmod +x /tmp/create_baseline.sh
/tmp/create_baseline.sh

# ------------------------------
# Task 4.1: Interpret Outputs
# ------------------------------

top -n 1 -b | head -20
vmstat 1 5
iostat -x 1 3

# ------------------------------
# Task 4.2: Performance Analysis Report Script
# ------------------------------

sudo dnf install -y bc

nano /tmp/performance_analysis.sh
chmod +x /tmp/performance_analysis.sh
/tmp/performance_analysis.sh

# Troubleshooting verification commands (as executed)
sudo systemctl status sysstat --no-pager -l
sudo journalctl -u sysstat --no-pager | tail -15
sudo systemctl restart sysstat
sudo cat /etc/sysconfig/sysstat

sudo /usr/libexec/sysstat/sa1
ls -la /var/log/sa/

sudo sar -u
sudo iostat -x

ls -la /proc/ | head -15
ls -la /var/log/sa/
