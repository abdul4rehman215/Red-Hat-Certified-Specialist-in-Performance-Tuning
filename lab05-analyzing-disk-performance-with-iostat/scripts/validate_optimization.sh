#!/bin/bash
# Performance Optimization Validation Script
VALIDATION_DIR="validation_$(date +%Y%m%d_%H%M%S)"
mkdir -p $VALIDATION_DIR
echo "Performance Optimization Validation"
echo "==================================="
echo "Results will be saved in: $VALIDATION_DIR"
# Record current configuration
echo "Recording current configuration..."
./check_schedulers.sh > $VALIDATION_DIR/current_schedulers.txt
# Run performance test
echo "Running post-optimization performance test..."
iostat -x 1 60 > $VALIDATION_DIR/optimized_performance.log &
IOSTAT_PID=$!
# Generate test load
./io_workload_generator.sh mixed > $VALIDATION_DIR/test_workload.log 2>&1
# Stop iostat
kill $IOSTAT_PID 2>/dev/null
# Generate validation report
echo "Generating validation report..."
cat > $VALIDATION_DIR/validation_report.txt << 'VALIDATION_EOF'
PERFORMANCE OPTIMIZATION VALIDATION REPORT
==========================================
Test Date: $(date)
Test Duration: 60 seconds
Workload: Mixed read/write operations
OPTIMIZATION RESULTS:
--------------------
Current Scheduler Configuration:
$(cat current_schedulers.txt)
Performance Metrics Summary:
- Average Utilization: $(awk '/^[a-z]/ {sum+=$NF; count++} END {if(count>0) printf "%.2f%%", sum/count}' optimized_performance.log)
- Average Await Time: $(awk '/^[a-z]/ {sum+=$(NF-1); count++} END {if(count>0) printf "%.2fms", sum/count}' optimized_performance.log)
- Average Queue Size: $(awk '/^[a-z]/ {sum+=$(NF-2); count++} END {if(count>0) printf "%.2f", sum/count}' optimized_performance.log)
RECOMMENDATIONS:
---------------
1. Compare these results with your baseline measurements
2. Monitor performance over time to ensure stability
3. Consider application-specific tuning if needed
4. Document changes for future reference
FILES INCLUDED:
--------------
- current_schedulers.txt: Active scheduler configuration
- optimized_performance.log: Detailed iostat output
- test_workload.log: Workload generation log
- validation_report.txt: This summary report
VALIDATION_EOF
# Process the template
cd $VALIDATION_DIR
eval "echo \"$(cat validation_report.txt)\"" > validation_report_final.txt
mv validation_report_final.txt validation_report.txt
cd ..
echo ""
echo "Validation completed!"
echo "Report location: $VALIDATION_DIR/validation_report.txt"
echo ""
echo "Validation Summary:"
echo "=================="
cat $VALIDATION_DIR/validation_report.txt
