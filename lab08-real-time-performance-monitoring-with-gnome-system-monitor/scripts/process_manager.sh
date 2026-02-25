#!/bin/bash
show_process_info() {
 local pid=$1
 echo "=== Process Information for PID $pid ==="
 if ps -p $pid > /dev/null 2>&1; then
  ps -p $pid -o pid,ppid,user,%cpu,%mem,vsz,rss,tty,stat,lstart,time,command
  echo ""
  echo "Memory details:"
  cat /proc/$pid/status | grep -E "VmSize|VmRSS|VmData|VmStk"
  echo ""
  echo "Open files:"
  lsof -p $pid 2>/dev/null | wc -l
  echo ""
 else
  echo "Process $pid not found or terminated"
 fi
}

# Usage example
if [ $# -eq 1 ]; then
 show_process_info $1
else
 echo "Usage: $0 <PID>"
 echo "Example: $0 1234"
fi
