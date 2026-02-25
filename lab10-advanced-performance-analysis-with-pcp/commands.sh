#!/bin/bash
# Lab 10 - Advanced Performance Analysis with PCP (Performance Co-Pilot)
# Commands Executed During Lab (sequential, no explanations)

# --- On pcp-monitor (monitoring server) ---
hostname
whoami

sudo yum update -y

sudo yum install -y pcp pcp-gui pcp-system-tools
sudo yum install -y pcp-pmda-* pcp-export-* pcp-import-*

sudo systemctl start pmcd
sudo systemctl enable pmcd
sudo systemctl start pmlogger
sudo systemctl enable pmlogger
sudo systemctl status pmcd pmlogger

# --- Install PCP on target-1 ---
ssh root@target-1
sudo yum install -y pcp pcp-system-tools
sudo systemctl start pmcd
sudo systemctl enable pmcd
sudo systemctl start pmlogger
sudo systemctl enable pmlogger
exit

# --- Install PCP on target-2 ---
ssh root@target-2
sudo yum install -y pcp pcp-system-tools
sudo systemctl start pmcd pmlogger
sudo systemctl enable pmcd pmlogger
exit

# --- PMDA inspection / verification on pcp-monitor ---
ls /var/lib/pcp/pmdas/ | head -20
pminfo -f pmcd.agent | head -25

cd /var/lib/pcp/pmdas/
cd linux
sudo ./Install
cd ../proc
sudo ./Install
cd ../disk
sudo ./Install
cd ../network
sudo ./Install
cd ../memory
sudo ./Install
cd ..

pminfo -f pmcd.agent.status | head -15
pminfo kernel.all.load
pmval -s 5 kernel.all.load

# --- pmcd config checks ---
sudo nano /etc/pcp/pmcd/pmcd.conf
grep -E "^(linux|pmcd|proc)\s" /etc/pcp/pmcd/pmcd.conf | head

echo "allow 192.168.1.0/24 : all;" | sudo tee -a /etc/pcp/pmcd/pmcd.options
echo "allow localhost : all;" | sudo tee -a /etc/pcp/pmcd/pmcd.options
sudo systemctl restart pmcd

# --- Remote connectivity tests ---
pminfo -h target-1 kernel.all.load
pminfo -h target-2 kernel.all.load
pminfo -h 192.168.1.101 kernel.all.load
pminfo -h 192.168.1.102 kernel.all.load

# --- Real-time monitoring ---
pmval -s 10 -t 2 kernel.all.cpu.user

pmval -h target-1 -s 10 -t 2 kernel.all.cpu.user &
pmval -h target-2 -s 10 -t 2 kernel.all.cpu.user &
wait

nano multi_system_monitor.sh
chmod +x multi_system_monitor.sh
./multi_system_monitor.sh

pmstat -t 2 -s 10

nano pmstat_all.sh
chmod +x pmstat_all.sh
./pmstat_all.sh

# --- Historical logging: pmlogger control updates ---
sudo nano /etc/pcp/pmlogger/control
echo "target-1 n PCP_LOG_DIR/target-1 -r -T24h10m -c config.default" | sudo tee -a /etc/pcp/pmlogger/control
echo "target-2 n PCP_LOG_DIR/target-2 -r -T24h10m -c config.default" | sudo tee -a /etc/pcp/pmlogger/control
sudo systemctl restart pmlogger

# --- Generate load ---
nano generate_load.sh
chmod +x generate_load.sh
sudo yum install -y stress-ng || sudo apt install -y stress-ng
./generate_load.sh

# --- Archive analysis ---
ls -la /var/log/pcp/pmlogger/ | head

pmval -a /var/log/pcp/pmlogger/localhost/$(date +%Y%m%d) -s 20 kernel.all.load

pmdumptext -a /var/log/pcp/pmlogger/localhost/$(date +%Y%m%d) -t 60 \
 kernel.all.cpu.user kernel.all.cpu.sys mem.util.used disk.all.total | head -25

# --- pmie setup ---
sudo nano /etc/pcp/pmie/config.local
nano /tmp/pmie_rules
sudo cp /tmp/pmie_rules /etc/pcp/pmie/config.local

sudo systemctl start pmie
sudo systemctl enable pmie

sudo pmie -v /etc/pcp/pmie/config.local &
./generate_load.sh
sudo tail -n 10 /var/log/pcp/pmie/localhost/pmie.log

# --- pmchart check + config ---
which pmchart
mkdir -p ~/.pcp/pmchart
nano ~/.pcp/pmchart/system_overview

# --- Reporting scripts ---
nano performance_dashboard.sh
chmod +x performance_dashboard.sh
./performance_dashboard.sh
ls -la /tmp/pcp_reports | head

nano trend_analysis.sh
chmod +x trend_analysis.sh
./trend_analysis.sh

nano comparative_analysis.sh
chmod +x comparative_analysis.sh
./comparative_analysis.sh

nano comprehensive_report.sh
chmod +x comprehensive_report.sh
./comprehensive_report.sh
ls -la /tmp/pcp_comprehensive_report_20260225_105624.html

# --- Automated monitoring + cron ---
nano automated_monitoring.sh
chmod +x automated_monitoring.sh
sudo cp automated_monitoring.sh /usr/local/bin/automated_monitoring.sh

echo "*/5 * * * * root /usr/local/bin/automated_monitoring.sh" | sudo tee -a /etc/crontab

sudo /usr/local/bin/automated_monitoring.sh
sudo tail -n 10 /var/log/pcp_monitoring.log

# --- Troubleshooting helpers used ---
sudo dnf install -y net-tools
sudo ss -tlnp | grep :44321
