#!/bin/bash
echo "Network Parameter Monitoring"
echo "============================"
echo "Timestamp: $(date)"
echo
echo "=== IP FORWARDING ==="
echo "IPv4 Forward: $(sysctl -n net.ipv4.ip_forward)"
echo "IPv6 Forward: $(sysctl -n net.ipv6.conf.all.forwarding)"
echo
echo "=== TCP PARAMETERS ==="
echo "TCP Window Scaling: $(sysctl -n net.ipv4.tcp_window_scaling)"
echo "TCP Timestamps: $(sysctl -n net.ipv4.tcp_timestamps)"
echo "TCP SACK: $(sysctl -n net.ipv4.tcp_sack)"
echo "TCP Keepalive Time: $(sysctl -n net.ipv4.tcp_keepalive_time)"
echo "TCP Keepalive Probes: $(sysctl -n net.ipv4.tcp_keepalive_probes)"
echo "TCP Keepalive Interval: $(sysctl -n net.ipv4.tcp_keepalive_intvl)"
echo
echo "=== BUFFER SIZES ==="
echo "TCP Read Buffer Max: $(sysctl -n net.ipv4.tcp_rmem)"
echo "TCP Write Buffer Max: $(sysctl -n net.ipv4.tcp_wmem)"
echo "UDP Read Buffer: $(sysctl -n net.core.rmem_default)"
echo "UDP Write Buffer: $(sysctl -n net.core.wmem_default)"
echo
echo "=== CONNECTION LIMITS ==="
echo "Max Connections: $(sysctl -n net.core.somaxconn)"
echo "SYN Backlog: $(sysctl -n net.ipv4.tcp_max_syn_backlog)"
