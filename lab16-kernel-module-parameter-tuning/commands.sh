#!/bin/bash
# Lab 16 - Kernel Module Parameter Tuning
# Commands Executed During Lab (sequential, no explanations)

# ------------------------------------------------------------
# Task 1.1 - Examine Current Network Parameters
# ------------------------------------------------------------

sysctl -a | grep net | head -20
sysctl net.core.rmem_max net.core.wmem_max net.core.netdev_max_backlog

lsmod | grep -E "(e1000|igb|ixgbe|virtio_net)"
modinfo virtio_net

sudo yum install -y iperf3 netperf
cat /proc/net/dev
ip -s link show > /tmp/network_baseline.txt
ls -l /tmp/network_baseline.txt

# ------------------------------------------------------------
# Task 1.2 - Modify Network Buffer Parameters
# ------------------------------------------------------------

sysctl -a | grep net > /tmp/network_sysctl_backup.txt
wc -l /tmp/network_sysctl_backup.txt

sudo sysctl -w net.core.rmem_default=262144
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_default=262144
sudo sysctl -w net.core.wmem_max=16777216
sudo sysctl -w net.ipv4.tcp_window_scaling=1
sudo sysctl -w net.core.netdev_max_backlog=5000

cat /proc/sys/net/ipv4/tcp_available_congestion_control
sudo sysctl -w net.ipv4.tcp_congestion_control=bbr

# ------------------------------------------------------------
# Task 1.3 - Adjust Network Interface Parameters
# ------------------------------------------------------------

ip link show
ethtool -i eth0

ethtool -g eth0
sudo ethtool -G eth0 rx 4096 tx 4096

sudo ethtool -K eth0 tso on
sudo ethtool -K eth0 gro on
echo 2 | sudo tee /sys/class/net/eth0/queues/rx-0/rps_cpus

# ------------------------------------------------------------
# Task 2.1 - Examine Current Storage Parameters
# ------------------------------------------------------------

for dev in /sys/block/*/queue/scheduler; do
  echo "Device: $dev"
  cat "$dev"
  echo "---"
done

cat /sys/block/sda/queue/read_ahead_kb
cat /sys/block/sda/queue/nr_requests

lsmod | grep -E "(scsi|ata|nvme|virtio_blk)"
modinfo virtio_blk
modinfo scsi_mod

sudo yum install -y fio hdparm
iostat -x 1 3
cat /proc/diskstats > /tmp/storage_baseline.txt
ls -l /tmp/storage_baseline.txt

# ------------------------------------------------------------
# Task 2.2 - Optimize I/O Scheduler Parameters
# ------------------------------------------------------------

cat /sys/block/sda/queue/scheduler
echo deadline | sudo tee /sys/block/sda/queue/scheduler
echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler

echo 512 | sudo tee /sys/block/sda/queue/read_ahead_kb
echo 128 | sudo tee /sys/block/sda/queue/nr_requests
echo 50 | sudo tee /sys/block/sda/queue/iosched/read_expire
echo 250 | sudo tee /sys/block/sda/queue/iosched/write_expire

# ------------------------------------------------------------
# Task 2.3 - Modify Virtual Memory Parameters
# ------------------------------------------------------------

sudo sysctl -w vm.dirty_ratio=10
sudo sysctl -w vm.dirty_background_ratio=5
sudo sysctl -w vm.dirty_expire_centisecs=1500
sudo sysctl -w vm.dirty_writeback_centisecs=500

sudo sysctl -w vm.swappiness=10
sudo sysctl -w vm.vfs_cache_pressure=50

# ------------------------------------------------------------
# Task 3.1 - Network Performance Testing
# ------------------------------------------------------------

nano /tmp/network_test.sh
chmod +x /tmp/network_test.sh
ls -l /tmp/network_test.sh

/tmp/network_test.sh
watch -n 1 'cat /proc/net/dev | grep eth0'

top -p $(pgrep -d',' ksoftirqd)
ss -m | head -20
watch -n 1 'cat /proc/interrupts | grep eth0'

# ------------------------------------------------------------
# Task 3.2 - Storage Performance Testing
# ------------------------------------------------------------

nano /tmp/storage_test.sh
chmod +x /tmp/storage_test.sh
ls -l /tmp/storage_test.sh

/tmp/storage_test.sh
iostat -x 1 5

vmstat 1 10
sudo iotop -a -o
ps aux | grep -E "\[.*\]" | grep -E "(kworker|ksoftirqd|migration)" | head -15

# ------------------------------------------------------------
# Task 3.3 - System-Wide Performance Analysis
# ------------------------------------------------------------

nano /tmp/system_monitor.sh
chmod +x /tmp/system_monitor.sh

/tmp/system_monitor.sh > /tmp/performance_analysis.txt
cat /tmp/performance_analysis.txt

nano /tmp/compare_performance.sh
chmod +x /tmp/compare_performance.sh
/tmp/compare_performance.sh

# ------------------------------------------------------------
# Task 4.1 - Make Changes Persistent
# ------------------------------------------------------------

sudo nano /etc/sysctl.d/99-performance-tuning.conf
sudo ls -l /etc/sysctl.d/99-performance-tuning.conf

sudo nano /etc/systemd/system/storage-tuning.service
sudo systemctl daemon-reload
sudo systemctl enable storage-tuning.service

sudo nano /usr/local/bin/network-tuning.sh
sudo chmod +x /usr/local/bin/network-tuning.sh
sudo ls -l /usr/local/bin/network-tuning.sh

sudo nano /etc/systemd/system/network-tuning.service
sudo systemctl daemon-reload
sudo systemctl enable network-tuning.service

# ------------------------------------------------------------
# Task 4.2 - Validate Persistent Configuration
# ------------------------------------------------------------

sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf

sudo systemctl start storage-tuning.service
sudo systemctl start network-tuning.service

echo "=== Verifying sysctl parameters ==="
sysctl net.core.rmem_max net.core.wmem_max vm.dirty_ratio vm.swappiness

echo "=== Verifying storage settings ==="
cat /sys/block/sda/queue/scheduler
cat /sys/block/sda/queue/read_ahead_kb

echo "=== Verifying network settings ==="
ethtool -g eth0 2>/dev/null || echo "ethtool not available or interface not found"

nano /tmp/validate_tuning.sh
chmod +x /tmp/validate_tuning.sh
/tmp/validate_tuning.sh

# ------------------------------------------------------------
# Troubleshooting Commands Used
# ------------------------------------------------------------

lsmod | grep tcp_bbr
sudo modprobe tcp_bbr
echo 'tcp_bbr' | sudo tee -a /etc/modules-load.d/bbr.conf

which ethtool || sudo yum install -y ethtool
ip link show

cat /sys/block/sda/queue/scheduler
ls /sys/block/nvme*/queue/scheduler

sudo -i
ls -la /sys/block/sda/queue/
exit
