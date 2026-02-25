#!/bin/bash
echo "Starting comprehensive eBPF monitoring..."
echo "Monitoring duration: 60 seconds"

DIR="ebpf_monitoring_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$DIR"
cd "$DIR" || exit 1

echo "Starting syscount monitoring..."
sudo /usr/share/bcc/tools/syscount.py -P -d 60 > syscount_detailed.txt &
SYSCOUNT_PID=$!

echo "Starting DNS latency monitoring..."
sudo /usr/share/bcc/tools/gethostlatency.py -t > dns_latency.txt &
GETHOSTLATENCY_PID=$!

if [ -f /usr/share/bcc/tools/opensnoop.py ]; then
 echo "Starting file open monitoring..."
 sudo /usr/share/bcc/tools/opensnoop.py -d 60 > file_opens.txt &
 OPENSNOOP_PID=$!
fi

if [ -f /usr/share/bcc/tools/execsnoop.py ]; then
 echo "Starting process execution monitoring..."
 sudo /usr/share/bcc/tools/execsnoop.py -t > process_execs.txt &
 EXECSNOOP_PID=$!
fi

echo "Generating test workload..."
sleep 5

for i in {1..50}; do
 dd if=/dev/zero of=test_file_$i bs=1M count=1 2>/dev/null
 sync
done

ping -c 10 8.8.8.8 > /dev/null 2>&1 &
ping -c 10 1.1.1.1 > /dev/null 2>&1 &

for domain in google.com github.com stackoverflow.com redhat.com; do
 nslookup $domain > /dev/null 2>&1
 host $domain > /dev/null 2>&1
done

ps aux > /dev/null
find /usr -name "*.conf" -type f 2>/dev/null | head -100 > /dev/null

echo "Waiting for monitoring to complete..."
wait $SYSCOUNT_PID
wait $GETHOSTLATENCY_PID

if [ -n "$OPENSNOOP_PID" ]; then sudo kill $OPENSNOOP_PID 2>/dev/null; fi
if [ -n "$EXECSNOOP_PID" ]; then sudo kill $EXECSNOOP_PID 2>/dev/null; fi

rm -f test_file_*
echo "Monitoring completed. Results saved in $(pwd)"
ls -la
