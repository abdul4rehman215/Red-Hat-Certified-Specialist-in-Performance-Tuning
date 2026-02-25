#!/bin/bash
# Lab 07 - Performance Analysis with sar
# Commands Executed During Lab (sequential, no explanations)

rpm -qa | grep sysstat

sudo apt update
sudo apt install -y sysstat
sar -V
ls -la /usr/bin/sa*

sudo systemctl enable sysstat
sudo systemctl start sysstat
sudo systemctl status sysstat

sudo cat /etc/cron.d/sysstat
sudo nano /etc/cron.d/sysstat
sudo cat /etc/cron.d/sysstat

ls -la /var/log/sa/
ls -la /var/log/sysstat/
ls -la /var/log/sa/sa$(date +%d)
ls -la /var/log/sysstat/sa$(date +%d)

sudo /usr/lib64/sa/sa1 1 1
sudo /usr/lib/sysstat/sa1 1 1
sar -u 1 1

sudo nano /usr/local/bin/enhanced_sar_collection.sh
sudo chmod +x /usr/local/bin/enhanced_sar_collection.sh
sudo /usr/local/bin/enhanced_sar_collection.sh

nano cpu_stress_test.sh
chmod +x cpu_stress_test.sh
./cpu_stress_test.sh &

sar -u 5 20
sar -P ALL 5 10
sar -u 2 300 > cpu_performance_$(date +%Y%m%d_%H%M).log &

sar -u -f /var/log/sa/sa$(date +%d)
sar -u -f /var/log/sysstat/sa$(date +%d)
sar -u -s $(date -d '2 hours ago' +%H:%M:%S) -f /var/log/sa/sa$(date +%d)
sar -u -s $(date -d '2 hours ago' +%H:%M:%S) -f /var/log/sysstat/sa$(date +%d)
sar -u -f /var/log/sa/sa$(date +%d) | tail -20
sar -u -f /var/log/sysstat/sa$(date +%d) | tail -20

nano analyze_cpu_performance.sh
chmod +x analyze_cpu_performance.sh
./analyze_cpu_performance.sh

nano memory_stress_test.sh
chmod +x memory_stress_test.sh
./memory_stress_test.sh &

sar -r 5 20
sar -S 5 10
sar -B 5 15
sar -r 2 600 > memory_performance_$(date +%Y%m%d_%H%M).log &

nano analyze_memory_performance.sh
chmod +x analyze_memory_performance.sh
./analyze_memory_performance.sh

nano disk_stress_test.sh
chmod +x disk_stress_test.sh
./disk_stress_test.sh &

sar -d 5 20
sar -d -p 5 15
sar -b 5 10
sar -d 2 600 > disk_performance_$(date +%Y%m%d_%H%M).log &

nano analyze_disk_performance.sh
chmod +x analyze_disk_performance.sh
./analyze_disk_performance.sh

nano master_performance_analysis.sh

sudo apt install -y lynx
chmod +x master_performance_analysis.sh
./master_performance_analysis.sh

sudo cat /etc/cron.d/sar-automation

nano setup_sar_automation.sh
chmod +x setup_sar_automation.sh
./setup_sar_automation.sh

sudo cat /etc/cron.d/sar-automation
