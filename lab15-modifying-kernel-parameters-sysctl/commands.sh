#!/bin/bash
# Lab 15 - Modifying Kernel Parameters with sysctl
# Commands Executed During Lab (sequential, no explanations)

# ----------------------------------------
# Task 1: Understanding and Exploring sysctl
# ----------------------------------------

mkdir -p ~/lab15 && cd ~/lab15
sudo sysctl -a | head -20
sudo sysctl -a | wc -l
sysctl --help

sudo sysctl -a | grep vm
sudo sysctl -a | grep net

sudo sysctl vm.swappiness
sudo sysctl net.ipv4.ip_forward
sudo sysctl kernel.hostname

nano ~/explore_sysctl.sh
chmod +x ~/explore_sysctl.sh
./explore_sysctl.sh

# ----------------------------------------
# Task 2: Modifying Virtual Memory Parameters
# ----------------------------------------

free -h
cat /proc/meminfo | grep -E "(MemTotal|MemFree|SwapTotal|SwapFree)"

echo "Current VM Parameters:"
sysctl vm.swappiness
sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio
sysctl vm.vfs_cache_pressure
sysctl vm.overcommit_memory

current_swappiness=$(sysctl -n vm.swappiness)
echo "Current swappiness: $current_swappiness"

nano ~/monitor_memory.sh
chmod +x ~/monitor_memory.sh
./monitor_memory.sh

sudo sysctl vm.swappiness=10
echo "New swappiness: $(sysctl -n vm.swappiness)"

echo "Current Dirty Memory Parameters:"
sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio
sysctl vm.dirty_expire_centisecs
sysctl vm.dirty_writeback_centisecs

sudo sysctl vm.dirty_ratio=15
sudo sysctl vm.dirty_background_ratio=5
sudo sysctl vm.dirty_expire_centisecs=3000
sudo sysctl vm.dirty_writeback_centisecs=500

echo "Updated Dirty Memory Parameters:"
sysctl vm.dirty_ratio
sysctl vm.dirty_background_ratio
sysctl vm.dirty_expire_centisecs
sysctl vm.dirty_writeback_centisecs

echo "Current VFS cache pressure: $(sysctl -n vm.vfs_cache_pressure)"

nano ~/monitor_cache.sh
chmod +x ~/monitor_cache.sh
./monitor_cache.sh

sudo sysctl vm.vfs_cache_pressure=50
echo "New VFS cache pressure: $(sysctl -n vm.vfs_cache_pressure)"

# ----------------------------------------
# Task 3: Configuring Network Parameters
# ----------------------------------------

nano ~/monitor_network.sh
chmod +x ~/monitor_network.sh
./monitor_network.sh

sudo sysctl net.ipv4.tcp_window_scaling=1
sudo sysctl net.ipv4.tcp_timestamps=1
sudo sysctl net.ipv4.tcp_sack=1
sudo sysctl net.ipv4.tcp_keepalive_time=600
sudo sysctl net.ipv4.tcp_keepalive_probes=3
sudo sysctl net.ipv4.tcp_keepalive_intvl=60

echo "Available congestion control algorithms:"
sysctl net.ipv4.tcp_available_congestion_control

if sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr; then
  sudo sysctl net.ipv4.tcp_congestion_control=bbr
  echo "BBR congestion control enabled"
else
  sudo sysctl net.ipv4.tcp_congestion_control=cubic
  echo "CUBIC congestion control enabled"
fi

echo "Current Buffer Sizes:"
sysctl net.core.rmem_default
sysctl net.core.rmem_max
sysctl net.core.wmem_default
sysctl net.core.wmem_max

sudo sysctl net.core.rmem_default=262144
sudo sysctl net.core.rmem_max=16777216
sudo sysctl net.core.wmem_default=262144
sudo sysctl net.core.wmem_max=16777216
sudo sysctl net.ipv4.tcp_rmem="4096 65536 16777216"
sudo sysctl net.ipv4.tcp_wmem="4096 65536 16777216"

echo "Updated Buffer Sizes:"
sysctl net.core.rmem_default
sysctl net.core.rmem_max
sysctl net.core.wmem_default
sysctl net.core.wmem_max

sudo sysctl net.core.somaxconn=65535
sudo sysctl net.ipv4.tcp_max_syn_backlog=8192
sudo sysctl net.ipv4.tcp_syncookies=1
sudo sysctl net.ipv4.tcp_syn_retries=3
sudo sysctl net.ipv4.tcp_synack_retries=3
sudo sysctl net.ipv4.tcp_tw_reuse=1
sudo sysctl net.ipv4.tcp_fin_timeout=30

echo "Connection parameters updated:"
sysctl net.core.somaxconn
sysctl net.ipv4.tcp_max_syn_backlog
sysctl net.ipv4.tcp_syncookies

# ----------------------------------------
# Task 4: Monitoring System Performance Impact
# ----------------------------------------

nano ~/performance_monitor.sh
chmod +x ~/performance_monitor.sh

echo "Taking baseline measurements..."
./performance_monitor.sh

command -v stress-ng >/dev/null 2>&1 || echo "stress-ng not found"
sudo dnf install stress-ng -y

nano ~/load_test.sh
chmod +x ~/load_test.sh

echo "Running performance test with modified parameters..."
./load_test.sh
./performance_monitor.sh

nano ~/compare_performance.sh
chmod +x ~/compare_performance.sh
./compare_performance.sh

# ----------------------------------------
# Task 5: Making Persistent Changes
# ----------------------------------------

ls -la /etc/sysctl.conf
cat /etc/sysctl.conf

ls -la /etc/sysctl.d/

sudo tee /etc/sysctl.d/99-performance-tuning.conf << 'EOF'
# Performance Tuning Configuration
# Created for Lab 15: Modifying Kernel Parameters with sysctl
# Virtual Memory Optimizations
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.dirty_expire_centisecs = 3000
vm.dirty_writeback_centisecs = 500
vm.vfs_cache_pressure = 50
# Network Performance Optimizations
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 60
# Buffer Size Optimizations
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
# Connection Handling Optimizations
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
EOF

echo "Persistent configuration created in /etc/sysctl.d/99-performance-tuning.conf"

sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
sudo sysctl --system

nano ~/validate_config.sh
chmod +x ~/validate_config.sh
./validate_config.sh

nano ~/backup_sysctl.sh
chmod +x ~/backup_sysctl.sh
nano ~/restore_sysctl.sh
chmod +x ~/restore_sysctl.sh

./backup_sysctl.sh
./restore_sysctl.sh

# ----------------------------------------
# Task 6: Advanced Kernel Parameter Tuning
# ----------------------------------------

sudo tee /etc/sysctl.d/98-security-tuning.conf << 'EOF'
# Security Tuning Configuration
# Enable Address Space Layout Randomization (ASLR)
kernel.randomize_va_space = 2
# Disable IP forwarding (unless needed for routing)
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
# Enable SYN flood protection
net.ipv4.tcp_syncookies = 1
# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
# Enable reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
# Disable ping responses (optional)
# net.ipv4.icmp_echo_ignore_all = 1
# Log suspicious packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
EOF

sudo sysctl -p /etc/sysctl.d/98-security-tuning.conf

sudo tee /etc/sysctl.d/97-filesystem-tuning.conf << 'EOF'
# File System Tuning Configuration
# Increase file handle limits
fs.file-max = 2097152
# Optimize inode and dentry cache
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 256
# AIO optimization
fs.aio-max-nr = 1048576
EOF

sudo sysctl -p /etc/sysctl.d/97-filesystem-tuning.conf

echo "Current file system parameters:"
sysctl fs.file-max
sysctl fs.inotify.max_user_watches
sysctl fs.aio-max-nr

nano ~/sysctl_profiles.sh
chmod +x ~/sysctl_profiles.sh
./sysctl_profiles.sh list
./sysctl_profiles.sh webserver

sysctl vm.swappiness net.core.somaxconn net.ipv4.tcp_fin_timeout fs.file-max
