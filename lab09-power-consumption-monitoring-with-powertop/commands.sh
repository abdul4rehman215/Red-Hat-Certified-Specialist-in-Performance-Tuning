#!/bin/bash
# Lab 09 - Power Consumption Monitoring with powertop
# Commands Executed During Lab (sequential, no explanations)

sudo dnf update -y

sudo dnf install -y powertop kernel-tools

powertop --version

cat /sys/class/power_supply/BAT*/status 2>/dev/null || echo "AC Power detected"

sudo modprobe msr

ls /sys/class/power_supply/
cat /sys/class/power_supply/ACAD/online

sudo powertop --calibrate

sudo powertop
echo "Exited powertop interactive mode (q)."

sudo powertop

sudo powertop --html=power_report.html --time=60
sudo powertop --csv=power_data.csv --time=30
ls -la power_report.html power_data.csv

nano analyze_power.sh
chmod +x analyze_power.sh
./analyze_power.sh

sudo powertop --auto-tune

nano power_optimize.sh
chmod +x power_optimize.sh
sudo ./power_optimize.sh

sudo nano /etc/systemd/system/power-optimize.service
sudo cp power_optimize.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/power-optimize.sh

sudo systemctl daemon-reload
sudo systemctl enable power-optimize.service
sudo systemctl start power-optimize.service
sudo systemctl status power-optimize.service

nano cpu_power_mgmt.sh
chmod +x cpu_power_mgmt.sh
sudo ./cpu_power_mgmt.sh

nano power_dashboard.sh
chmod +x power_dashboard.sh
timeout 6s ./power_dashboard.sh

nano power_benchmark.sh
chmod +x power_benchmark.sh
./power_benchmark.sh
ls -la /tmp/power_benchmark | head

nano generate_power_report.sh
chmod +x generate_power_report.sh
./generate_power_report.sh

sudo dnf install -y tlp tlp-rdw

sudo systemctl enable tlp.service
sudo systemctl start tlp.service

sudo nano /etc/tlp.conf
sudo tlp start
sudo tlp-stat -s

nano power_profiles.sh
chmod +x power_profiles.sh
sudo cp power_profiles.sh /usr/local/bin/

echo "Testing power profiles..."
sudo /usr/local/bin/power_profiles.sh list
sudo /usr/local/bin/power_profiles.sh balanced

nano auto_power_mgmt.sh
chmod +x auto_power_mgmt.sh
sudo cp auto_power_mgmt.sh /usr/local/bin/

sudo nano /etc/systemd/system/auto-power-mgmt.service

sudo systemctl daemon-reload
sudo systemctl enable auto-power-mgmt.service
sudo systemctl start auto-power-mgmt.service
sudo systemctl status auto-power-mgmt.service | head -20
