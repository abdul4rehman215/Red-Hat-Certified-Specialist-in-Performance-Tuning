#!/bin/bash
REPORT_FILE="cpu_performance_report_$(date +%Y%m%d_%H%M%S).txt"
echo "=== Generating CPU Performance Report ==="
echo "Report will be saved as: $REPORT_FILE"

{
 echo "=========================================="
 echo " CPU PERFORMANCE ANALYSIS REPORT"
 echo "=========================================="
 echo "Generated: $(date)"
 echo "System: $(hostname)"
 echo "Analyst: $(whoami)"
 echo ""

 echo "=== SYSTEM CONFIGURATION ==="
 echo "CPU Architecture:"
 lscpu | grep -E "(Architecture|Model name|CPU\(s\)|Thread|Core|Socket|Cache)"
 echo ""

 echo "Memory Information:"
 free -h
 echo ""

 echo "=== CURRENT PERFORMANCE METRICS ==="
 echo "System Load:"
 uptime
 echo ""

 echo "CPU Utilization (10-second average):"
 mpstat -P ALL 1 10 | grep "Average"
 echo ""

 echo "=== PERFORMANCE TEST RESULTS ==="
 echo "Running CPU stress test for analysis..."

 # Run stress test and capture results
 mpstat -P ALL 2 20 > temp_stress_results.log &
 MPSTAT_PID=$!

 stress --cpu $(nproc) --timeout 15s >/dev/null 2>&1 &
 STRESS_PID=$!

 wait $STRESS_PID
 wait $MPSTAT_PID

 echo "Stress Test Results:"
 grep "Average" temp_stress_results.log
 echo ""

 echo "=== ANALYSIS AND RECOMMENDATIONS ==="

 # Analyze results and provide recommendations
 MAX_UTIL=$(grep "Average" temp_stress_results.log | awk '$3 ~ /^[0-9]+$/ {total=$4+$6; if(total>max) max=total} END {print max}')
 MIN_UTIL=$(grep "Average" temp_stress_results.log | awk '$3 ~ /^[0-9]+$/ {total=$4+$6; if(NR==1 || total<min) min=total} END {print min}')

 echo "Performance Analysis:"
 echo "- Maximum CPU utilization during test: ${MAX_UTIL}%"
 echo "- Minimum CPU utilization during test: ${MIN_UTIL}%"

 if (( $(echo "$MAX_UTIL > 90" | bc -l) )); then
  echo "- Status: HIGH CPU utilization detected"
  echo "- Recommendation: Monitor for sustained high usage"
 elif (( $(echo "$MAX_UTIL < 50" | bc -l) )); then
  echo "- Status: LOW CPU utilization"
  echo "- Recommendation: System has available CPU capacity"
 else
  echo "- Status: MODERATE CPU utilization"
  echo "- Recommendation: Normal operating range"
 fi

 echo ""
 echo "Load Balancing Analysis:"
 CORE_COUNT=$(grep "Average" temp_stress_results.log | awk '$3 ~ /^[0-9]+$/' | wc -l)
 echo "- Number of CPU cores analyzed: $CORE_COUNT"

 # Check for load imbalance
 grep "Average" temp_stress_results.log | awk '
 $3 ~ /^[0-9]+$/ {
  total = $4 + $6
  sum += total
  count++
  util[count] = total
 }
 END {
  avg = sum / count
  variance = 0
  for (i = 1; i <= count; i++) {
   variance += (util[i] - avg) ^ 2
  }
  variance = variance / count
  stddev = sqrt(variance)

  printf "- Average utilization across cores: %.1f%%\n", avg
  printf "- Standard deviation: %.1f%%\n", stddev

  if (stddev > 15) {
   print "- Load Balance: POOR - Significant variation between cores"
   print "- Recommendation: Consider CPU affinity optimization"
  } else if (stddev > 5) {
   print "- Load Balance: MODERATE - Some variation between cores"
   print "- Recommendation: Monitor load distribution"
  } else {
   print "- Load Balance: GOOD - Even distribution across cores"
   print "- Recommendation: Current load balancing is effective"
  }
 }'

 echo ""
 echo "=== MONITORING RECOMMENDATIONS ==="
 echo "1. Regular Monitoring:"
 echo " - Use 'mpstat -P ALL 5' for real-time monitoring"
 echo " - Set up automated alerts for >80% sustained CPU usage"
 echo ""
 echo "2. Performance Optimization:"
 echo " - Consider process CPU affinity for critical applications"
 echo " - Monitor I/O wait times if >20% consistently"
 echo " - Review process scheduling priorities"
 echo ""
 echo "3. Capacity Planning:"
 echo " - Current peak utilization: ${MAX_UTIL}%"
 echo " - Recommended threshold for scaling: 70%"
 echo " - Consider additional cores if consistently above threshold"
 echo ""

 echo "=== APPENDIX: COMMAND REFERENCE ==="
 echo "Useful mpstat commands:"
 echo "- mpstat -P ALL # Show all CPU statistics"
 echo "- mpstat -P ALL 5 # Monitor every 5 seconds"
 echo "- mpstat -P 0,1 2 10 # Monitor CPUs 0,1 for 20 seconds"
 echo "- mpstat -I SUM # Show interrupt statistics"
 echo ""

 echo "Report generation completed: $(date)"

 # Cleanup temporary files
 rm -f temp_stress_results.log

} > "$REPORT_FILE"

echo "Report generated successfully: $REPORT_FILE"
echo ""
echo "Report summary:"
head -30 "$REPORT_FILE"
echo "..."
echo "(Full report saved to $REPORT_FILE)"
