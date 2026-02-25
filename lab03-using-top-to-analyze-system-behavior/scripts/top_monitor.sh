#!/bin/bash
# Custom top monitoring with specific focus areas
echo "Starting comprehensive system monitoring..."
# Function to capture top output
capture_top() {
 local duration=$1
 local output_file=$2

 echo "Capturing top output for $duration seconds..."
 timeout $duration top -b -n $((duration/2)) > $output_file
 echo "Output saved to $output_file"
}
# Function to analyze top output
analyze_top() {
 local input_file=$1

 echo "Analysis of $input_file:"
 echo "========================"

 # Extract load averages
 echo "Load Average Trends:"
 grep "load average" $input_file | awk '{print $12, $13, $14}'
 echo ""

 # Extract top CPU consumers
 echo "Top CPU Consumers:"
 grep -A 20 "PID USER" $input_file | grep -v "PID USER" | head -10
 echo ""

 # Extract memory usage
 echo "Memory Usage Patterns:"
 grep "MiB Mem" $input_file
 echo ""
}
# Capture system performance
capture_top 60 "system_performance.log"
# Analyze the captured data
analyze_top "system_performance.log"
echo "Monitoring complete. Check system_performance.log for detailed data."
