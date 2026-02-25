#!/bin/bash
if [ $# -eq 0 ]; then
 echo "Usage: $0 <PID> [signal]"
 echo "Common signals: TERM (15), KILL (9), HUP (1), USR1 (10)"
 exit 1
fi
PID=$1
SIGNAL=${2:-TERM}
# Check if process exists
if ! ps -p $PID > /dev/null 2>&1; then
 echo "Process $PID does not exist"
 exit 1
fi
# Get process information
PROCESS_INFO=$(ps -p $PID -o pid,user,cmd --no-headers)
echo "Process to terminate: $PROCESS_INFO"
# Send signal
echo "Sending $SIGNAL signal to process $PID..."
kill -$SIGNAL $PID
# Wait and check if process terminated
sleep 2
if ps -p $PID > /dev/null 2>&1; then
 echo "Process $PID is still running"
 if [ "$SIGNAL" != "KILL" ]; then
  echo "You may need to use KILL signal: $0 $PID KILL"
 fi
else
 echo "Process $PID terminated successfully"
fi
