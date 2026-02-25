#!/bin/bash
# Lab 08 - Real-time Performance Monitoring with gnome-system-monitor
# Commands Executed During Lab (sequential, no explanations)

sudo apt update && sudo apt upgrade -y
sudo apt install gnome-system-monitor htop stress-ng -y

which gnome-system-monitor
gnome-system-monitor --version

gnome-system-monitor &

sudo apt install -y xvfb
xvfb-run -a gnome-system-monitor &

ps aux --sort=-%cpu | head -10

top -bn1 | head -8

nano cpu_monitor.sh
chmod +x cpu_monitor.sh
./cpu_monitor.sh
head -6 cpu_usage_log.txt

stress-ng --cpu 0 --timeout 120s --metrics-brief
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -10

stress-ng --cpu 2 --timeout 60s
stress-ng --cpu 1 --cpu-load 75 --timeout 60s

nano cpu_analysis.sh
chmod +x cpu_analysis.sh
./cpu_analysis.sh

nano memory_monitor.sh
chmod +x memory_monitor.sh
./memory_monitor.sh
head -6 memory_usage_log.txt

stress-ng --vm 1 --vm-bytes 1G --timeout 120s --metrics-brief
stress-ng --vm 4 --vm-bytes 256M --timeout 60s
stress-ng --vm 1 --vm-bytes 2G --timeout 60s --vm-keep

nano memory_leak_sim.py
chmod +x memory_leak_sim.py

python3 memory_leak_sim.py &
LEAK_PID=$!
echo "Memory leak simulation PID: $LEAK_PID"
echo "Monitor this PID in gnome-system-monitor Processes tab"
ps -p $LEAK_PID -o pid,%cpu,%mem,rss,cmd
kill $LEAK_PID

nano process_tree_demo.sh
chmod +x process_tree_demo.sh
./process_tree_demo.sh &
pstree -p 3522 | head -20

sudo apt install -y bc

nano cpu_intensive.sh
nano memory_intensive.sh
nano io_intensive.sh
chmod +x cpu_intensive.sh memory_intensive.sh io_intensive.sh

./cpu_intensive.sh &
CPU_PID=$!
./memory_intensive.sh &
MEM_PID=$!
./io_intensive.sh &
IO_PID=$!

echo "Process PIDs:"
echo "CPU-intensive: $CPU_PID"
echo "Memory-intensive: $MEM_PID"
echo "I/O-intensive: $IO_PID"

ps -p $CPU_PID,$MEM_PID,$IO_PID -o pid,%cpu,%mem,rss,stat,cmd

renice +10 -p $CPU_PID

kill -TERM $CPU_PID
kill -KILL $MEM_PID
kill $IO_PID

nano process_manager.sh
chmod +x process_manager.sh
./process_manager.sh 2526

nano system_stress.sh
chmod +x system_stress.sh
./system_stress.sh
top -bn1 | head -6
pkill -f "stress-ng"

nano performance_checklist.txt

sudo apt install -y net-tools

nano performance_report.sh
chmod +x performance_report.sh
./performance_report.sh

nano system_optimizer.sh
chmod +x system_optimizer.sh
sudo ./system_optimizer.sh

nano performance_dashboard.sh
chmod +x performance_dashboard.sh
timeout 6s ./performance_dashboard.sh

nano advanced_monitor.sh
chmod +x advanced_monitor.sh
./advanced_monitor.sh
ls -la monitoring_logs | head

nano trend_analyzer.sh
chmod +x trend_analyzer.sh
./trend_analyzer.sh
cat monitoring_logs/trend_summary.txt
