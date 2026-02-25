#!/bin/bash
echo "=== Comprehensive System Optimization ==="

cat > /etc/sysctl.d/99-performance-tuning.conf << 'SYSCTL_EOF'
# Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
# Memory optimizations
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.swappiness = 10
# File system optimizations
fs.file-max = 2097152
SYSCTL_EOF

sysctl -p /etc/sysctl.d/99-performance-tuning.conf

echo "Optimizing systemd configuration..."
mkdir -p /etc/systemd/system.conf.d
cat > /etc/systemd/system.conf.d/performance.conf << 'SYSTEMD_EOF'
[Manager]
DefaultTimeoutStopSec=30s
DefaultTimeoutStartSec=30s
SYSTEMD_EOF

echo "Updating system limits..."
cat >> /etc/security/limits.conf << 'LIMITS_EOF'
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
LIMITS_EOF

echo "System-wide optimization completed."
echo "Note: Some changes require a system reboot to take effect."
