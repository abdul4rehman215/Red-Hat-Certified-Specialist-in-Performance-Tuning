#!/bin/bash
# Performance trend analysis script
LOG_DIR="monitoring_logs"

analyze_cpu_trends() {
 echo "=== CPU TREND ANALYSIS ==="

 local cpu_log=$(ls $LOG_DIR/cpu_*.log 2>/dev/null | head -1)
 if [ -f "$cpu_log" ]; then
  echo "Analyzing CPU data from: $cpu_log"

  local avg_cpu=$(awk -F',' 'NR>1{sum+=$2; count++} END{if(count>0) printf "%.2f", sum/count; else print "0"}' "$cpu_log")
  local max_cpu=$(awk -F',' 'NR>1{if($2>max) max=$2} END{print (max?max:0)}' "$cpu_log")
  local min_cpu=$(awk -F',' 'NR>1{if(NR==2 || $2<min) min=$2} END{print (min?min:0)}' "$cpu_log")

  echo "Average CPU Usage: $avg_cpu%"
  echo "Maximum CPU Usage: $max_cpu%"
  echo "Minimum CPU Usage: $min_cpu%"

  # Identify high CPU periods
  local high_count=$(awk -F',' 'NR>1{if($2>80) c++} END{print (c?c:0)}' "$cpu_log")
  echo ""
  echo "High CPU events (>80%): $high_count"
 else
  echo "No CPU log found in $LOG_DIR"
 fi
 echo ""
}

analyze_memory_trends() {
 echo "=== MEMORY TREND ANALYSIS ==="

 local mem_log=$(ls $LOG_DIR/memory_*.log 2>/dev/null | head -1)
 if [ -f "$mem_log" ]; then
  echo "Analyzing Memory data from: $mem_log"

  # memory log columns: Timestamp,Total_MB,Used_MB,Free_MB,Usage_Percent
  local avg_mem=$(awk -F',' 'NR>1{sum+=$5; count++} END{if(count>0) printf "%.2f", sum/count; else print "0"}' "$mem_log")
  local max_mem=$(awk -F',' 'NR>1{if($5>max) max=$5} END{print (max?max:0)}' "$mem_log")
  local min_mem=$(awk -F',' 'NR>1{if(NR==2 || $5<min) min=$5} END{print (min?min:0)}' "$mem_log")

  echo "Average Memory Usage: $avg_mem%"
  echo "Maximum Memory Usage: $max_mem%"
  echo "Minimum Memory Usage: $min_mem%"

  local high_count=$(awk -F',' 'NR>1{if($5>85) c++} END{print (c?c:0)}' "$mem_log")
  echo ""
  echo "High Memory events (>85%): $high_count"
 else
  echo "No Memory log found in $LOG_DIR"
 fi
 echo ""
}

analyze_alerts() {
 echo "=== ALERT LOG SUMMARY ==="
 local alert_log=$(ls $LOG_DIR/alerts_*.log 2>/dev/null | head -1)
 if [ -f "$alert_log" ]; then
  echo "Alerts file: $alert_log"
  echo "Total alerts: $(wc -l < "$alert_log")"
 else
  echo "No alerts log found (or no alerts triggered)."
 fi
 echo ""
}

write_summary() {
 local outfile="$LOG_DIR/trend_summary.txt"
 local cpu_log=$(ls $LOG_DIR/cpu_*.log 2>/dev/null | head -1)
 local mem_log=$(ls $LOG_DIR/memory_*.log 2>/dev/null | head -1)
 local alert_log=$(ls $LOG_DIR/alerts_*.log 2>/dev/null | head -1)

 local avg_cpu="N/A" max_cpu="N/A" min_cpu="N/A" high_cpu="N/A"
 local avg_mem="N/A" max_mem="N/A" min_mem="N/A" high_mem="N/A"
 local total_alerts="0"

 if [ -f "$cpu_log" ]; then
  avg_cpu=$(awk -F',' 'NR>1{sum+=$2; count++} END{if(count>0) printf "%.2f", sum/count; else print "0"}' "$cpu_log")
  max_cpu=$(awk -F',' 'NR>1{if($2>max) max=$2} END{print (max?max:0)}' "$cpu_log")
  min_cpu=$(awk -F',' 'NR>1{if(NR==2 || $2<min) min=$2} END{print (min?min:0)}' "$cpu_log")
  high_cpu=$(awk -F',' 'NR>1{if($2>80) c++} END{print (c?c:0)}' "$cpu_log")
 fi

 if [ -f "$mem_log" ]; then
  avg_mem=$(awk -F',' 'NR>1{sum+=$5; count++} END{if(count>0) printf "%.2f", sum/count; else print "0"}' "$mem_log")
  max_mem=$(awk -F',' 'NR>1{if($5>max) max=$5} END{print (max?max:0)}' "$mem_log")
  min_mem=$(awk -F',' 'NR>1{if(NR==2 || $5<min) min=$5} END{print (min?min:0)}' "$mem_log")
  high_mem=$(awk -F',' 'NR>1{if($5>85) c++} END{print (c?c:0)}' "$mem_log")
 fi

 if [ -f "$alert_log" ]; then
  total_alerts=$(wc -l < "$alert_log")
 fi

 {
  echo "SYSTEM TREND SUMMARY"
  echo "Generated: $(date)"
  echo ""
  echo "CPU:"
  echo "- Avg: ${avg_cpu}%"
  echo "- Max: ${max_cpu}%"
  echo "- Min: ${min_cpu}%"
  echo "- High CPU events (>80%): ${high_cpu}"
  echo ""
  echo "Memory:"
  echo "- Avg: ${avg_mem}%"
  echo "- Max: ${max_mem}%"
  echo "- Min: ${min_mem}%"
  echo "- High Memory events (>85%): ${high_mem}"
  echo ""
  echo "Alerts:"
  echo "- Total alerts: ${total_alerts}"
 } > "$outfile"

 echo "Trend summary saved to: $outfile"
}

analyze_cpu_trends
analyze_memory_trends
analyze_alerts
write_summary
