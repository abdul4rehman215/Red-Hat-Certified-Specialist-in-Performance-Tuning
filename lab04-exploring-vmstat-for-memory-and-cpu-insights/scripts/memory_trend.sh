#!/bin/bash
echo "=== Memory Trend Analysis ==="
echo "Timestamp,Free_MB,Used_MB,Buff_MB,Cache_MB,Swap_Used_MB" > memory_trend.csv
for i in {1..20}; do
 TIMESTAMP=$(date '+%H:%M:%S')
 MEMORY_DATA=$(free -m | awk 'NR==2{printf "%d,%d,%d", $4,$3,$6} NR==3{printf ",%d", $3}')
 CACHE_DATA=$(free -m | awk 'NR==2{printf ",%d", $7}')
 echo "$TIMESTAMP,$MEMORY_DATA$CACHE_DATA" >> memory_trend.csv
 sleep 3
done
echo "Memory trend data saved to memory_trend.csv"
cat memory_trend.csv
