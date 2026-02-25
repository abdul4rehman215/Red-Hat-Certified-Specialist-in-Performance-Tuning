#!/usr/bin/env python3
import time
import os
import sys
import re
from collections import defaultdict, deque

class PerformanceAnalyzer:
    def __init__(self, syscount_file, dns_file):
        self.syscount_file = syscount_file
        self.dns_file = dns_file
        self.syscall_counts = defaultdict(int)
        self.dns_latencies = deque(maxlen=200)
        self.last_syscount_size = 0
        self.last_dns_size = 0

    def _read_new(self, path, last_size):
        if not os.path.exists(path):
            return [], last_size
        size = os.path.getsize(path)
        if size < last_size:
            last_size = 0
        with open(path, "r") as f:
            f.seek(last_size)
            data = f.read()
        return data.splitlines(), size

    def ingest_syscount(self):
        lines, self.last_syscount_size = self._read_new(self.syscount_file, self.last_syscount_size)
        for line in lines:
            line = line.strip()
            if not line or line.startswith("COMM") or line.startswith("SYSCALL") or "Tracing" in line:
                continue
            parts = line.split()
            if len(parts) >= 3:
                # COMM SYSCALL COUNT
                try:
                    syscall = parts[1]
                    count = int(parts[2])
                    self.syscall_counts[syscall] += count
                except ValueError:
                    pass
            elif len(parts) >= 2:
                try:
                    syscall = parts[0]
                    count = int(parts[1])
                    self.syscall_counts[syscall] += count
                except ValueError:
                    pass

    def ingest_dns(self):
        lines, self.last_dns_size = self._read_new(self.dns_file, self.last_dns_size)
        for line in lines:
            m = re.search(r'(\d+:\d+:\d+)\s+(\d+)\s+(\S+)\s+([^\s]+)\s+([\d.]+)', line)
            if m:
                lat = float(m.group(5))
                self.dns_latencies.append(lat)

    def print_analysis(self):
        print("\n" + "=" * 60)
        print(f"Performance Analysis - {time.strftime('%H:%M:%S')}")
        print("=" * 60)

        if self.syscall_counts:
            print("\nTop System Calls (accumulated):")
            for sc, ct in sorted(self.syscall_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
                print(f" {sc:<15}: {ct:>8}")

            io_calls = sum(ct for sc, ct in self.syscall_counts.items()
                           if sc in ["read","write","open","openat","close","stat","newfstatat","unlink"])
            if io_calls > 5000:
                print(f"\nALERT: High I/O syscall volume detected: {io_calls}")

        if self.dns_latencies:
            avg = sum(self.dns_latencies) / len(self.dns_latencies)
            mx = max(self.dns_latencies)
            slow = sum(1 for x in self.dns_latencies if x > 100)
            print("\nDNS Performance (recent):")
            print(f" Samples: {len(self.dns_latencies)}")
            print(f" Avg latency: {avg:.2f} ms")
            print(f" Max latency: {mx:.2f} ms")
            if slow:
                print(f" ALERT: {slow} lookups > 100ms")

        print("-" * 60)

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 realtime_analyzer.py <syscount_file> <dns_file>")
        sys.exit(1)

    analyzer = PerformanceAnalyzer(sys.argv[1], sys.argv[2])
    print("Starting real-time performance analysis (file-based)...")
    print("Press Ctrl+C to stop\n")

    try:
        while True:
            analyzer.ingest_syscount()
            analyzer.ingest_dns()
            analyzer.print_analysis()
            time.sleep(10)
    except KeyboardInterrupt:
        print("\nShutting down analyzer...")

if __name__ == "__main__":
    main()
