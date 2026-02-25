#!/bin/bash
echo "=== Network Performance Test ==="
echo "Testing network throughput and latency..."
# Test local network performance
echo "Local network interface statistics:"
ip -s link show eth0
# Test TCP performance (requires iperf3 server on another machine or localhost)
echo "Starting iperf3 server in background..."
iperf3 -s -D
sleep 2
echo "Testing TCP throughput:"
iperf3 -c localhost -t 10 -P 4
# Kill background iperf3 server
pkill iperf3
echo "Network test completed."
