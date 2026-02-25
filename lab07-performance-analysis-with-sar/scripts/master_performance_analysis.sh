#!/bin/bash
# Master Performance Analysis Script

# Configuration
DATA_FILE="/var/log/sysstat/sa$(date +%d)"
REPORT_DIR="/tmp/performance_reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MASTER_REPORT="${REPORT_DIR}/master_performance_report_${TIMESTAMP}.html"

# Create report directory
mkdir -p $REPORT_DIR

# HTML Report Generation
cat > $MASTER_REPORT << 'EOF'
<!DOCTYPE html>
<html>
<head>
 <title>System Performance Analysis Report</title>
 <style>
 body { font-family: Arial, sans-serif; margin: 20px; }
 .header { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }
 .section { margin: 20px 0; border: 1px solid #ddd; padding: 15px; border-radius: 5px; }
 .metric { background-color: #f9f9f9; padding: 5px; margin: 5px 0; }
 .warning { color: #ff6600; font-weight: bold; }
 .critical { color: #ff0000; font-weight: bold; }
 .good { color: #00aa00; font-weight: bold; }
 pre { background-color: #f5f5f5; padding: 10px; overflow-x: auto; }
 table { border-collapse: collapse; width: 100%; }
 th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
 th { background-color: #f2f2f2; }
 </style>
</head>
<body>
EOF

# Add header information
cat >> $MASTER_REPORT << EOF
<div class="header">
 <h1>System Performance Analysis Report</h1>
 <p><strong>Generated:</strong> $(date)</p>
 <p><strong>Hostname:</strong> $(hostname)</p>
 <p><strong>Kernel:</strong> $(uname -r)</p>
 <p><strong>Uptime:</strong> $(uptime)</p>
</div>
EOF

# Function to add section to HTML report
add_section() {
 local title="$1"
 local content="$2"

 cat >> $MASTER_REPORT << EOF
<div class="section">
 <h2>$title</h2>
 <pre>$content</pre>
</div>
EOF
}

# System Overview
SYSTEM_INFO=$(cat << 'SYSINFO'
CPU Information:
$(lscpu | grep -E "(Model name|CPU\(s\)|Thread|Core)")
Memory Information:
$(free -h)
Disk Information:
$(df -h | grep -v tmpfs)
Network Interfaces:
$(ip addr show | grep -E "(inet |link/)")
SYSINFO
)
add_section "System Overview" "$SYSTEM_INFO"

# CPU Analysis
CPU_ANALYSIS=$(sar -u -f $DATA_FILE | awk '
BEGIN {
 print "CPU Performance Summary"
 print "======================"
 samples=0; total_user=0; total_system=0; total_idle=0; total_iowait=0;
 max_util=0; min_util=100;
}
$3 != "%user" && NF > 6 {
 samples++;
 user=$3; system=$5; idle=$8; iowait=$6;
 utilization = 100 - idle;
 total_user += user;
 total_system += system;
 total_idle += idle;
 total_iowait += iowait;
 if(utilization > max_util) max_util = utilization;
 if(utilization < min_util) min_util = utilization;
 if(utilization > 80) high_util_count++;
 if(iowait > 10) high_iowait_count++;
}
END {
 if(samples > 0) {
 avg_user = total_user/samples;
 avg_system = total_system/samples;
 avg_idle = total_idle/samples;
 avg_iowait = total_iowait/samples;
 avg_util = 100 - avg_idle;

 print "Average CPU Utilization: " avg_util "%";
 print "Peak CPU Utilization: " max_util "%";
 print "Minimum CPU Utilization: " min_util "%";
 print "Average User CPU: " avg_user "%";
 print "Average System CPU: " avg_system "%";
 print "Average I/O Wait: " avg_iowait "%";
 print "High Utilization Periods (>80%): " (high_util_count ? high_util_count : 0);
 print "High I/O Wait Periods (>10%): " (high_iowait_count ? high_iowait_count : 0);

 if(avg_util < 50) print "Status: CPU utilization is GOOD";
 else if(avg_util < 80) print "Status: CPU utilization is MODERATE";
 else print "Status: CPU utilization is HIGH - Investigation needed";
 }
}')
add_section "CPU Performance Analysis" "$CPU_ANALYSIS"

# Memory Analysis
MEMORY_ANALYSIS=$(sar -r -f $DATA_FILE | awk '
BEGIN {
 print "Memory Performance Summary"
 print "========================="
 samples=0; total_used=0; total_free=0; max_used=0;
}
$6 != "%memused" && NF > 6 {
 samples++;
 used_pct=$6;
 free_kb=$3;
 total_used += used_pct;
 total_free += free_kb;
 if(used_pct > max_used) max_used = used_pct;
 if(used_pct > 90) critical_count++;
 if(used_pct > 80) warning_count++;
}
END {
 if(samples > 0) {
 avg_used = total_used/samples;
 avg_free = total_free/samples;

 print "Average Memory Usage: " avg_used "%";
 print "Peak Memory Usage: " max_used "%";
 print "Average Free Memory: " avg_free " KB";
 print "Critical Usage Periods (>90%): " (critical_count ? critical_count : 0);
 print "Warning Usage Periods (>80%): " (warning_count ? warning_count : 0);

 if(avg_used < 70) print "Status: Memory usage is GOOD";
 else if(avg_used < 85) print "Status: Memory usage is MODERATE";
 else print "Status: Memory usage is HIGH - Investigation needed";
 }
}')
add_section "Memory Performance Analysis" "$MEMORY_ANALYSIS"

# Disk Analysis
DISK_ANALYSIS=$(sar -d -f $DATA_FILE | awk '
BEGIN {
 print "Disk Performance Summary"
 print "======================="
 samples=0; total_tps=0; total_util=0; max_util=0;
}
$4 != "tps" && NF > 9 {
 samples++;
 tps=$4; util=$NF;
 total_tps += tps;
 total_util += util;
 if(util > max_util) max_util = util;
 if(util > 80) high_util_count++;
 if(tps > 100) high_tps_count++;
}
END {
 if(samples > 0) {
 avg_tps = total_tps/samples;
 avg_util = total_util/samples;

 print "Average TPS: " avg_tps;
 print "Average Disk Utilization: " avg_util "%";
 print "Peak Disk Utilization: " max_util "%";
 print "High Utilization Periods (>80%): " (high_util_count ? high_util_count : 0);
 print "High TPS Periods (>100): " (high_tps_count ? high_tps_count : 0);

 if(avg_util < 50) print "Status: Disk performance is GOOD";
 else if(avg_util < 80) print "Status: Disk performance is MODERATE";
 else print "Status: Disk performance is HIGH - Investigation needed";
 }
}')
add_section "Disk Performance Analysis" "$DISK_ANALYSIS"

# Performance Recommendations
RECOMMENDATIONS=$(cat << 'RECOMMENDATIONS'
Performance Optimization Recommendations:
1. CPU Optimization:
 - Monitor processes with high CPU usage using 'top' or 'htop'
 - Consider CPU affinity for critical processes
 - Evaluate if additional CPU cores are needed
2. Memory Optimization:
 - Review memory-intensive applications
 - Consider increasing swap space if memory usage is consistently high
 - Monitor for memory leaks in applications
3. Disk I/O Optimization:
 - Consider faster storage solutions (SSD) for high I/O workloads
 - Implement proper file system tuning
 - Monitor disk queue lengths and response times
4. General Recommendations:
 - Set up automated monitoring and alerting
 - Establish performance baselines
 - Regular performance reviews and capacity planning
RECOMMENDATIONS
)
add_section "Performance Recommendations" "$RECOMMENDATIONS"

# Close HTML
cat >> $MASTER_REPORT << 'EOF'
</body>
</html>
EOF

echo "Master performance report generated: $MASTER_REPORT"

# Also create a text version
TEXT_REPORT="${REPORT_DIR}/master_performance_report_${TIMESTAMP}.txt"
lynx -dump $MASTER_REPORT > $TEXT_REPORT 2>/dev/null || \
w3m -dump $MASTER_REPORT > $TEXT_REPORT 2>/dev/null || \
echo "Text version could not be generated. Install lynx or w3m for text output." > $TEXT_REPORT

echo "Text report generated: $TEXT_REPORT"
echo "Reports saved in: $REPORT_DIR"
ls -la $REPORT_DIR/
