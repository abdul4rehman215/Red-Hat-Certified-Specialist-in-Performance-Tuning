#!/bin/bash
show_help() {
 echo "Priority Manager Script"
 echo "Usage: $0 [option] [pid] [nice_value]"
 echo ""
 echo "Options:"
 echo " list - List all processes with priorities"
 echo " renice - Change process priority"
 echo " monitor - Monitor priority changes"
 echo ""
 echo "Examples:"
 echo " $0 list"
 echo " $0 renice 1234 10"
 echo " $0 monitor"
}
list_priorities() {
 echo "Current Process Priorities:"
 echo "PID PPID NI COMMAND"
 echo "=========================="
 ps -eo pid,ppid,ni,comm --sort=-ni | head -20
}
renice_process() {
 local pid=$1
 local nice_value=$2

 if [ -z "$pid" ] || [ -z "$nice_value" ]; then
 echo "Error: PID and nice value required"
 return 1
 fi

 echo "Changing priority of PID $pid to nice value $nice_value"

 if [ "$nice_value" -lt 0 ]; then
 sudo renice "$nice_value" "$pid"
 else
 renice "$nice_value" "$pid"
 fi

 echo "New priority:"
 ps -eo pid,ppid,ni,comm | grep "^[[:space:]]*$pid"
}
monitor_priorities() {
 echo "Monitoring process priorities (Press Ctrl+C to stop)..."
 while true; do
 clear
 echo "Process Priority Monitor - $(date)"
 echo "=================================="
 ps -eo pid,ppid,ni,%cpu,%mem,comm --sort=-%cpu | head -15
 sleep 2
 done
}
case $1 in
 list) list_priorities ;;
 renice) renice_process $2 $3 ;;
 monitor) monitor_priorities ;;
 *) show_help ;;
esac
