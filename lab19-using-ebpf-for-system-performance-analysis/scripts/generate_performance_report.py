#!/usr/bin/env python3
import os
import sys
import json
import statistics
from datetime import datetime
from collections import defaultdict
import re

class PerformanceReportGenerator:
    def __init__(self, data_directory):
        self.data_dir = data_directory
        self.report = {
            "timestamp": datetime.now().isoformat(),
            "data_directory": os.path.abspath(data_directory),
            "system_calls": {},
            "dns_performance": {},
            "file_operations": {},
            "process_activity": {},
            "performance_issues": [],
            "recommendations": []
        }

    def analyze_syscount_data(self, filename):
        if not os.path.exists(filename):
            return

        with open(filename, "r") as f:
            lines = f.readlines()

        # syscount -P outputs: COMM SYSCALL COUNT
        syscalls = defaultdict(int)

        for line in lines:
            line = line.strip()
            if not line or line.startswith("COMM") or line.startswith("SYSCALL") or "Tracing" in line:
                continue
            parts = line.split()
            # COMM SYSCALL COUNT
            if len(parts) >= 3:
                try:
                    syscall = parts[1]
                    count = int(parts[2])
                    syscalls[syscall] += count
                except ValueError:
                    continue
            elif len(parts) >= 2:
                try:
                    syscall = parts[0]
                    count = int(parts[1])
                    syscalls[syscall] += count
                except ValueError:
                    continue

        total = sum(syscalls.values())
        top = dict(sorted(syscalls.items(), key=lambda x: x[1], reverse=True)[:10])

        self.report["system_calls"] = {
            "total_calls": total,
            "unique_syscalls": len(syscalls),
            "top_syscalls": top
        }

        io_syscalls = {"read","write","open","openat","close","stat","newfstatat","unlink","fstat"}
        io_calls = sum(ct for sc, ct in syscalls.items() if sc in io_syscalls)

        if io_calls > 10000:
            self.report["performance_issues"].append({
                "type": "high_io",
                "description": f"High I/O syscall activity: {io_calls} calls (read/write/open/close/stat/unlink)",
                "severity": "medium"
            })

        if syscalls.get("futex", 0) > 5000:
            self.report["performance_issues"].append({
                "type": "high_futex",
                "description": f"High futex activity detected: {syscalls.get('futex')} (possible lock contention)",
                "severity": "medium"
            })

    def analyze_dns_latency_data(self, filename):
        if not os.path.exists(filename):
            return

        latencies = []
        hosts = defaultdict(list)

        with open(filename, "r") as f:
            for line in f:
                # TIME PID COMM HOST LAT(ms)
                m = re.search(r'(\d+:\d+:\d+)\s+(\d+)\s+(\S+)\s+([^\s]+)\s+([\d.]+)', line)
                if m:
                    host = m.group(4)
                    latency = float(m.group(5))
                    latencies.append(latency)
                    hosts[host].append(latency)

        if not latencies:
            return

        self.report["dns_performance"] = {
            "total_queries": len(latencies),
            "average_latency_ms": statistics.mean(latencies),
            "median_latency_ms": statistics.median(latencies),
            "max_latency_ms": max(latencies),
            "min_latency_ms": min(latencies),
            "slow_queries_gt_100ms": len([x for x in latencies if x > 100]),
            "very_slow_gt_500ms": len([x for x in latencies if x > 500]),
            "hosts_queried": len(hosts),
            "top_slowest_hosts_avg_ms": dict(
                sorted(
                    ((h, statistics.mean(v)) for h, v in hosts.items()),
                    key=lambda x: x[1],
                    reverse=True
                )[:10]
            )
        }

        if self.report["dns_performance"]["slow_queries_gt_100ms"] > 0:
            sev = "medium"
            if self.report["dns_performance"]["slow_queries_gt_100ms"] >= 10:
                sev = "high"
            self.report["performance_issues"].append({
                "type": "slow_dns",
                "description": f"{self.report['dns_performance']['slow_queries_gt_100ms']} DNS lookups >100ms",
                "severity": sev
            })

        if self.report["dns_performance"]["very_slow_gt_500ms"] > 0:
            self.report["performance_issues"].append({
                "type": "very_slow_dns",
                "description": f"{self.report['dns_performance']['very_slow_gt_500ms']} DNS lookups >500ms",
                "severity": "high"
            })

    def analyze_file_operations(self, filename):
        if not os.path.exists(filename):
            return
        with open(filename, "r") as f:
            lines = [ln.strip() for ln in f if ln.strip()]

        samples = lines[:20]
        self.report["file_operations"] = {
            "total_lines": len(lines),
            "sample": samples
        }

        if len(lines) > 500:
            self.report["performance_issues"].append({
                "type": "high_file_open_activity",
                "description": f"High file open activity observed in opensnoop output ({len(lines)} lines).",
                "severity": "low"
            })

    def analyze_process_activity(self, filename):
        if not os.path.exists(filename):
            return
        with open(filename, "r") as f:
            lines = [ln.strip() for ln in f if ln.strip()]

        self.report["process_activity"] = {
            "total_lines": len(lines),
            "sample": lines[:20]
        }

    def generate_recommendations(self):
        recs = []

        syscalls = self.report.get("system_calls", {})
        dns = self.report.get("dns_performance", {})
        issues = self.report.get("performance_issues", [])

        if syscalls.get("total_calls", 0) > 50000:
            recs.append({
                "category": "system_calls",
                "recommendation": "Reduce syscall frequency (batch I/O, caching, avoid excessive file open/close in loops).",
                "priority": "medium"
            })

        if any(i["type"] == "high_io" for i in issues):
            recs.append({
                "category": "io",
                "recommendation": "Investigate heavy I/O patterns: check file access loops, enable caching, consider async I/O where appropriate.",
                "priority": "medium"
            })

        if dns:
            if dns.get("average_latency_ms", 0) > 50:
                recs.append({
                    "category": "dns",
                    "recommendation": "DNS latency high: verify resolver config, check network path, consider local caching resolver (systemd-resolved/unbound).",
                    "priority": "high"
                })
            elif dns.get("slow_queries_gt_100ms", 0) > 0:
                recs.append({
                    "category": "dns",
                    "recommendation": "Some DNS queries slow: check intermittent network issues and try alternate DNS servers or caching.",
                    "priority": "medium"
                })

        if any(i["type"] == "high_futex" for i in issues):
            recs.append({
                "category": "locking",
                "recommendation": "High futex counts may indicate lock contention—profile application threads and reduce shared locks.",
                "priority": "medium"
            })

        if not recs:
            recs.append({
                "category": "general",
                "recommendation": "No major issues detected. Continue periodic monitoring and baseline comparisons.",
                "priority": "low"
            })

        self.report["recommendations"] = recs

    def write_outputs(self, out_prefix="performance_report"):
        json_path = os.path.join(self.data_dir, f"{out_prefix}.json")
        txt_path = os.path.join(self.data_dir, f"{out_prefix}.txt")

        with open(json_path, "w") as f:
            json.dump(self.report, f, indent=2)

        with open(txt_path, "w") as f:
            f.write("=== eBPF Performance Report ===\n")
            f.write(f"Generated: {self.report['timestamp']}\n")
            f.write(f"Data Dir: {self.report['data_directory']}\n\n")

            f.write("== System Calls ==\n")
            sc = self.report.get("system_calls", {})
            f.write(f"Total calls: {sc.get('total_calls', 0)}\n")
            f.write(f"Unique syscalls: {sc.get('unique_syscalls', 0)}\n")
            f.write("Top syscalls:\n")
            for k, v in sc.get("top_syscalls", {}).items():
                f.write(f"  {k:<15} {v}\n")

            f.write("\n== DNS Performance ==\n")
            dns = self.report.get("dns_performance", {})
            if dns:
                f.write(f"Total queries: {dns.get('total_queries')}\n")
                f.write(f"Avg latency: {dns.get('average_latency_ms'):.2f} ms\n")
                f.write(f"Max latency: {dns.get('max_latency_ms'):.2f} ms\n")
                f.write(f"Slow >100ms: {dns.get('slow_queries_gt_100ms')}\n")
            else:
                f.write("No DNS data found.\n")

            f.write("\n== Detected Issues ==\n")
            if self.report["performance_issues"]:
                for i in self.report["performance_issues"]:
                    f.write(f"- [{i['severity']}] {i['type']}: {i['description']}\n")
            else:
                f.write("No issues detected.\n")

            f.write("\n== Recommendations ==\n")
            for r in self.report["recommendations"]:
                f.write(f"- ({r['priority']}) {r['category']}: {r['recommendation']}\n")

        return json_path, txt_path

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 generate_performance_report.py <monitoring_data_directory>")
        sys.exit(1)

    data_dir = sys.argv[1]
    gen = PerformanceReportGenerator(data_dir)

    gen.analyze_syscount_data(os.path.join(data_dir, "syscount_detailed.txt"))
    gen.analyze_dns_latency_data(os.path.join(data_dir, "dns_latency.txt"))
    gen.analyze_file_operations(os.path.join(data_dir, "file_opens.txt"))
    gen.analyze_process_activity(os.path.join(data_dir, "process_execs.txt"))
    gen.generate_recommendations()

    jp, tp = gen.write_outputs()
    print(f"Report written: {jp}")
    print(f"Summary written: {tp}")

if __name__ == "__main__":
    main()
