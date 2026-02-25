#!/bin/bash
echo "=== SYSTEM INFORMATION ==="
echo "Hostname: $(sysctl -n kernel.hostname)"
echo "Kernel Version: $(sysctl -n kernel.version)"
echo "OS Type: $(sysctl -n kernel.ostype)"
echo

echo "=== MEMORY PARAMETERS ==="
echo "Swappiness: $(sysctl -n vm.swappiness)"
echo "Dirty Ratio: $(sysctl -n vm.dirty_ratio)"
echo "VFS Cache Pressure: $(sysctl -n vm.vfs_cache_pressure)"
echo

echo "=== NETWORK PARAMETERS ==="
echo "IP Forward: $(sysctl -n net.ipv4.ip_forward)"
echo "TCP Keepalive Time: $(sysctl -n net.ipv4.tcp_keepalive_time)"
echo "TCP Window Scaling: $(sysctl -n net.ipv4.tcp_window_scaling)"
echo

echo "=== SECURITY PARAMETERS ==="
echo "ASLR: $(sysctl -n kernel.randomize_va_space)"
echo "Core Pattern: $(sysctl -n kernel.core_pattern)"
