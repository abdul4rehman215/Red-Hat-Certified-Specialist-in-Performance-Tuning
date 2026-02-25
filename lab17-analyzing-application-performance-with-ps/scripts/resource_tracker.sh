#!/bin/bash
LOGFILE="process_resources.log"
INTERVAL=10 # seconds
echo "Starting resource tracking (logging to $LOGFILE)"
echo "Press Ctrl+C to stop"
# Initialize log file
echo "Timestamp,PID,User,CPU%,MEM%,VSZ,RSS,Command" > "$LOGFILE"
trap 'echo "Stopping resource tracker..."; exit 0' INT
while true; do
 TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

 # Log top 5 CPU consumers
 ps aux --sort=-%cpu | head -6 | tail -5 | while read line; do
  echo "$TIMESTAMP,$line" | awk '{
   gsub(/ +/, ",", $0)
   print $1","$3","$2","$4","$5","$6","$7","$12
  }' >> "$LOGFILE"
 done

 sleep $INTERVAL
done
