#!/bin/bash
LOG_FILE="memory_usage_log.txt"
echo "Timestamp,Total_MB,Used_MB,Free_MB,Available_MB,Cached_MB,Swap_Used_MB" > $LOG_FILE

for i in {1..60}; do
 TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

 # free -m output: Mem: total used free shared buff/cache available
 MEM_TOTAL=$(free -m | awk 'NR==2{print $2}')
 MEM_USED=$(free -m | awk 'NR==2{print $3}')
 MEM_FREE=$(free -m | awk 'NR==2{print $4}')
 MEM_AVAIL=$(free -m | awk 'NR==2{print $7}')
 MEM_CACHED=$(free -m | awk 'NR==2{print $6}')
 SWAP_USED=$(free -m | awk 'NR==3{print $3}')

 echo "$TIMESTAMP,$MEM_TOTAL,$MEM_USED,$MEM_FREE,$MEM_AVAIL,$MEM_CACHED,$SWAP_USED" >> $LOG_FILE
 sleep 5
done

echo "Memory monitoring completed. Check $LOG_FILE for results."
