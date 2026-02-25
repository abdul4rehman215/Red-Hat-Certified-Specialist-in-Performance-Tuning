#!/bin/bash
if [ $# -eq 0 ]; then
 echo "Usage: $0 <PID>"
 exit 1
fi
PID=$1
echo "Tracking process $PID..."
echo "Time,CPU%,MEM%,VSZ,RSS"
for i in {1..10}; do
 if ps -p $PID > /dev/null 2>&1; then
 ps -p $PID -o pcpu,pmem,vsz,rss --no-headers | \
 awk -v time="$(date +%H:%M:%S)" '{printf "%s,%.1f,%.1f,%d,%d\n", time, $1, $2, $3, $4}'
 else
 echo "Process $PID no longer exists"
 break
 fi
 sleep 5
done
