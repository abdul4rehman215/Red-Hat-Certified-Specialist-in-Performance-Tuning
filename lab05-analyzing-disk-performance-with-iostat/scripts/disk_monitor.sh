#!/bin/bash
# Disk Performance Monitoring Script
echo "Starting disk performance monitoring..."
echo "Timestamp: $(date)"
echo "=================================="
# Monitor for 60 seconds with 5-second intervals
iostat -x 5 12 > disk_performance_$(date +%Y%m%d_%H%M%S).log &
echo "Monitoring started. Check disk_performance_*.log for results."
echo "Press Ctrl+C to stop monitoring early."
# Wait for monitoring to complete
wait
echo "Monitoring completed."
