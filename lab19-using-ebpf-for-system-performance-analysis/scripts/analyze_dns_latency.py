#!/usr/bin/env python3
import sys
import re
from collections import defaultdict
import statistics

def parse_gethostlatency_output(filename):
    print("=== DNS Latency Analysis ===")

    latencies = []
    host_latencies = defaultdict(list)
    pid_latencies = defaultdict(list)

    with open(filename, 'r') as f:
        for line in f:
            # Example:
            # 18:41:10 4821 nslookup google.com 8.41
            match = re.search(r'(\d+:\d+:\d+)\s+(\d+)\s+(\S+)\s+([^\s]+)\s+([\d.]+)', line)
            if match:
                time_str, pid, comm, host, latency = match.groups()
                latency_ms = float(latency)
                latencies.append(latency_ms)
                host_latencies[host].append(latency_ms)
                pid_latencies[f"{pid}({comm})"].append(latency_ms)

    if not latencies:
        print("No DNS latency data found in the file.")
        return

    print(f"Total DNS resolutions: {len(latencies)}")
    print(f"Average latency: {statistics.mean(latencies):.2f} ms")
    print(f"Median latency: {statistics.median(latencies):.2f} ms")
    print(f"Min latency: {min(latencies):.2f} ms")
    print(f"Max latency: {max(latencies):.2f} ms")
    if len(latencies) > 1:
        print(f"Standard deviation: {statistics.stdev(latencies):.2f} ms")

    print("\n=== Latency Distribution ===")
    ranges = [(0, 10), (10, 50), (50, 100), (100, 500), (500, float('inf'))]
    labels = ["0-10ms", "10-50ms", "50-100ms", "100-500ms", ">500ms"]
    for (mn, mx), label in zip(ranges, labels):
        count = sum(1 for lat in latencies if mn <= lat < mx)
        pct = (count / len(latencies)) * 100
        print(f"{label:<10}: {count:>3} ({pct:>5.1f}%)")

    print("\n=== Slowest Hosts (Average Latency) ===")
    host_avg = [(h, statistics.mean(v)) for h, v in host_latencies.items()]
    host_avg.sort(key=lambda x: x[1], reverse=True)
    for host, avg in host_avg[:10]:
        print(f"{host:<25}: {avg:>6.2f} ms (n={len(host_latencies[host])})")

    print("\n=== Process DNS Activity ===")
    pid_avg = [(p, statistics.mean(v)) for p, v in pid_latencies.items()]
    pid_avg.sort(key=lambda x: len(pid_latencies[x[0]]), reverse=True)
    for pid_comm, avg in pid_avg[:5]:
        print(f"{pid_comm:<20}: {len(pid_latencies[pid_comm]):>3} lookups, avg {avg:>6.2f} ms")

    print("\n=== Performance Warnings ===")
    slow = [lat for lat in latencies if lat > 100]
    very_slow = [lat for lat in latencies if lat > 500]
    if slow:
        print(f" {len(slow)} DNS resolutions took >100ms")
        print(f" Slowest resolution: {max(slow):.2f} ms")
    if very_slow:
        print(f" {len(very_slow)} DNS resolutions took >500ms")
    if not slow:
        print(" All DNS resolutions completed in reasonable time")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 analyze_dns_latency.py <gethostlatency_output_file>")
        sys.exit(1)
    parse_gethostlatency_output(sys.argv[1])
