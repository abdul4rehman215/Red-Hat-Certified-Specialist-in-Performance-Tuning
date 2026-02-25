#!/bin/bash
echo "Creating comprehensive system stress scenario..."

# Start combined stressors (CPU + memory + I/O)
# Note: Uses stress-ng (installed earlier). Safe time-bounded defaults.
stress-ng --cpu 0 --timeout 300s --metrics-brief >/dev/null 2>&1 &
CPU_PID=$!

stress-ng --vm 1 --vm-bytes 1G --timeout 300s --metrics-brief >/dev/null 2>&1 &
MEM_PID=$!

stress-ng --hdd 1 --hdd-bytes 2G --timeout 300s --metrics-brief >/dev/null 2>&1 &
IO_PID=$!

echo "Stress test PIDs:"
echo "CPU: $CPU_PID"
echo "Memory: $MEM_PID"
echo "I/O: $IO_PID"
echo "Monitor system performance in gnome-system-monitor for 5 minutes"
echo "Press Ctrl+C to stop all stress tests early"

# Keep script alive while stressors run (can be interrupted)
wait
