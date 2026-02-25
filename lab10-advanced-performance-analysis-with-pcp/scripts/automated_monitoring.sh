#!/bin/bash
# Automated monitoring cycle: checks key metrics on multiple hosts and logs results

LOG_FILE="/var/log/pcp_monitoring.log"
HOSTS=("localhost" "target-1" "target-2")

log() {
 echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE" >/dev/null
 echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting automated monitoring"

for host in "${HOSTS[@]}"; do
 log "Checking system: $host"

 # Load
 load=$(pmval -h "$host" -s 1 -t 1 kernel.all.load 2>/dev/null | tail -1 | awk '{print $NF}')
 # CPU user
 cpu=$(pmval -h "$host" -s 1 -t 1 kernel.all.cpu.user 2>/dev/null | tail -1 | awk '{print $NF}')
 # Memory used
 mem=$(pmval -h "$host" -s 1 -t 1 mem.util.used 2>/dev/null | tail -1 | awk '{print $NF}')

 log "$host metrics -> load:$load cpu_user:$cpu mem_used:$mem"
done

log "Monitoring cycle complete"
