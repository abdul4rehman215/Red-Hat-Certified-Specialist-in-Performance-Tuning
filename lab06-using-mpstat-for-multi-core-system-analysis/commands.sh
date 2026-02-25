#!/bin/bash
# Lab 06 - Using mpstat for Multi-Core System Analysis
# Commands Executed During Lab (sequential, no explanations)

lscpu
cat /proc/cpuinfo | grep -E "(processor|model name|cpu cores|siblings)"
nproc
uptime

sudo apt update
sudo apt install -y sysstat
mpstat -V

sudo systemctl enable sysstat
sudo systemctl start sysstat
sudo systemctl status sysstat
cat /etc/default/sysstat

mpstat -P ALL
mpstat -P ALL 2 5
mpstat -P 0 2 5
mpstat -P ALL 1 3 | head -20

nano baseline_cpu.sh
chmod +x baseline_cpu.sh
./baseline_cpu.sh

sudo apt install -y stress
stress --cpu $(nproc) --timeout 60s &
mpstat -P ALL 2 30

nano cpu_analysis.sh
chmod +x cpu_analysis.sh
./cpu_analysis.sh 60 2

nano detect_bottlenecks.sh
chmod +x detect_bottlenecks.sh
./detect_bottlenecks.sh

nano cpu_affinity_test.sh
chmod +x cpu_affinity_test.sh
./cpu_affinity_test.sh

nano optimize_processes.sh
chmod +x optimize_processes.sh
./optimize_processes.sh

nano cpu_dashboard.sh
chmod +x cpu_dashboard.sh
echo "Dashboard created. Run './cpu_dashboard.sh' for real-time monitoring."

nano historical_analysis.sh
chmod +x historical_analysis.sh
./historical_analysis.sh

sudo apt install -y bc
nano generate_report.sh
chmod +x generate_report.sh
./generate_report.sh

nano setup_monitoring.sh
chmod +x setup_monitoring.sh
./setup_monitoring.sh
