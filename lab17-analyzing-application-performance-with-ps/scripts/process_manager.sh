#!/bin/bash

show_help() {
 echo "Process Manager - Advanced ps-based process analysis tool"
 echo
 echo "Usage: $0 [OPTION]"
 echo
 echo "Options:"
 echo " -t, --top Show top resource consumers"
 echo " -u, --user USER Show processes for specific user"
 echo " -s, --search TERM Search for processes containing TERM"
 echo " -k, --kill PID Safely terminate process"
 echo " -m, --monitor Continuous monitoring mode"
 echo " -r, --report Generate detailed system report"
 echo " -h, --help Show this help message"
}

show_top() {
 echo "=== TOP RESOURCE CONSUMERS ==="
 echo
 echo "Top 10 CPU consumers:"
 ps aux --sort=-%cpu | head -11 | awk 'NR==1 {print $0} NR>1 {printf "%-8s %6s %5.1f%% %5.1f%% %s\n", $1, $2, $3, $4, $11}'
 echo
 echo "Top 10 Memory consumers:"
 ps aux --sort=-%mem | head -11 | awk 'NR==1 {print $0} NR>1 {printf "%-8s %6s %5.1f%% %5.1f%% %s\n", $1, $2, $3, $4, $11}'
}

show_user_processes() {
 local user=$1
 echo "=== PROCESSES FOR USER: $user ==="
 ps -u "$user" -o pid,pcpu,pmem,time,cmd --sort=-%cpu
}

search_processes() {
 local term=$1
 echo "=== PROCESSES MATCHING: $term ==="
 ps aux | grep -i "$term" | grep -v grep
}

monitor_mode() {
 echo "=== CONTINUOUS MONITORING MODE ==="
 echo "Press Ctrl+C to exit"
 while true; do
  clear
  echo "System Process Monitor - $(date)"
  echo "========================================"
  ps aux --sort=-%cpu | head -15
  echo
  echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
  sleep 3
 done
}

generate_report() {
 local report_file="process_report_$(date +%Y%m%d_%H%M%S).txt"
 echo "Generating detailed report: $report_file"

 {
  echo "=== SYSTEM PROCESS ANALYSIS REPORT ==="
  echo "Generated: $(date)"
  echo "Hostname: $(hostname)"
  echo "Uptime: $(uptime)"
  echo

  echo "=== SYSTEM SUMMARY ==="
  echo "Total processes: $(ps aux | wc -l)"
  echo "Running processes: $(ps aux | awk '$8=="'"R"'" {count++} END {print count+0}')"
  echo "Sleeping processes: $(ps aux | awk '$8~/^S/ {count++} END {print count+0}')"
  echo "Zombie processes: $(ps aux | awk '$8=="'"Z"'" {count++} END {print count+0}')"
  echo

  show_top
  echo

  echo "=== PROCESS TREE ==="
  ps auxf

 } > "$report_file"

 echo "Report saved to: $report_file"
}

case "$1" in
 -t|--top)
  show_top
  ;;
 -u|--user)
  if [ -z "$2" ]; then
   echo "Error: Please specify a username"
   exit 1
  fi
  show_user_processes "$2"
  ;;
 -s|--search)
  if [ -z "$2" ]; then
   echo "Error: Please specify a search term"
   exit 1
  fi
  search_processes "$2"
  ;;
 -k|--kill)
  if [ -z "$2" ]; then
   echo "Error: Please specify a PID"
   exit 1
  fi
  ./safe_terminate.sh "$2"
  ;;
 -m|--monitor)
  monitor_mode
  ;;
 -r|--report)
  generate_report
  ;;
 -h|--help)
  show_help
  ;;
 *)
  echo "Error: Unknown option '$1'"
  show_help
  exit 1
  ;;
esac
