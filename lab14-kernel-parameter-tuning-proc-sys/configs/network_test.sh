#!/bin/bash
echo "=== Network Performance Test ==="
echo "Testing with current TCP buffer settings:"
echo "TCP rmem: $(cat /proc/sys/net/ipv4/tcp_rmem)"
echo "TCP wmem: $(cat /proc/sys/net/ipv4/tcp_wmem)"
echo ""

# Test network throughput using iperf3 (if available) or nc
if command -v iperf3 &> /dev/null; then
  echo "Starting iperf3 server in background..."
  iperf3 -s -p 5001 &
  SERVER_PID=$!
  sleep 2

  echo "Running iperf3 client test..."
  iperf3 -c localhost -p 5001 -t 10

  kill $SERVER_PID
else
  echo "iperf3 not available, using basic network test"
  # Simple network test using netcat
  echo "Testing basic network connectivity..."
  nc -l 8080 &
  NC_PID=$!
  sleep 1
  echo "Network test data" | nc localhost 8080
  kill $NC_PID 2>/dev/null
fi
