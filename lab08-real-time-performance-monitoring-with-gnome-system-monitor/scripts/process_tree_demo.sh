#!/bin/bash
echo "Creating process tree demonstration..."
echo "Parent PID: $$"

# Function to create child processes
create_children() {
 local parent_name=$1
 local depth=$2

 if [ $depth -gt 0 ]; then
  echo "[$parent_name] Creating child process at depth $depth"
  (
   echo "Child process PID: $$ (Parent: $PPID)"
   sleep 300 & # Background sleep process
   create_children "Child-$depth" $((depth-1))
   wait
  ) &
 fi
}

# Create a 3-level process tree
create_children "Root" 3
echo "Process tree created. Check gnome-system-monitor for the hierarchy."
echo "Processes will run for 5 minutes. Press Ctrl+C to stop early."

# Wait for all background processes
wait
