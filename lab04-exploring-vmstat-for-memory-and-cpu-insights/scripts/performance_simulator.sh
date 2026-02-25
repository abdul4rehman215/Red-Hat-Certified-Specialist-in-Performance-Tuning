#!/bin/bash
simulate_memory_leak() {
 echo "Simulating memory leak..."
 # Gradually consume memory
 for i in {1..50}; do
 dd if=/dev/zero of=/tmp/leak_$i bs=10M count=1 2>/dev/null &
 sleep 2
 done
}
simulate_cpu_spike() {
 echo "Simulating CPU spike..."
 # Create CPU-intensive processes
 for i in {1..4}; do
 (while true; do echo "scale=1000; 4*a(1)" | bc -l >/dev/null 2>&1; done) &
 done
 sleep 30
 killall bc 2>/dev/null
}
simulate_io_bottleneck() {
 echo "Simulating I/O bottleneck..."
 # Create multiple I/O intensive processes
 for i in {1..8}; do
 (
 while [ $SECONDS -lt 45 ]; do
 dd if=/dev/zero of=/tmp/iobottleneck_$i bs=5M count=20 2>/dev/null
 dd if=/tmp/iobottleneck_$i of=/dev/null bs=5M 2>/dev/null
 done
 rm -f /tmp/iobottleneck_$i
 ) &
 done
 wait
}
cleanup() {
 echo "Cleaning up..."
 killall dd bc 2>/dev/null
 rm -f /tmp/leak_* /tmp/iobottleneck_*
}
trap cleanup EXIT
echo "Performance Issue Simulator"
echo "1. Memory leak simulation"
echo "2. CPU spike simulation"
echo "3. I/O bottleneck simulation"
echo "4. All simulations"
read -p "Choose simulation (1-4): " choice
case $choice in
 1) simulate_memory_leak ;;
 2) simulate_cpu_spike ;;
 3) simulate_io_bottleneck ;;
 4)
 simulate_memory_leak &
 sleep 10
 simulate_cpu_spike &
 sleep 10
 simulate_io_bottleneck &
 wait
 ;;
 *) echo "Invalid choice" ;;
esac
