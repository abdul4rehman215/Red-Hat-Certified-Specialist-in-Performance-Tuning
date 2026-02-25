# 🧪 Lab 19: Using eBPF for System Performance Analysis

> **Track:** Red Hat Certified Specialist in Performance Tuning (Exam Labs)  
> **Environment:** CentOS Stream 9 (Cloud Lab)  
> **Shell:** `-bash-4.2$`  
> **User:** `centos` (sudo available)

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand core eBPF concepts and why eBPF is low-overhead for kernel observability
- Validate system readiness for eBPF (kernel version, debugfs/tracing, bpffs)
- Install/verify BCC tools (`syscount`, `gethostlatency`, etc.)
- Use `syscount.py` to trace and analyze syscalls (system-wide, per-PID, per-process name, and interval mode)
- Use `gethostlatency.py` to measure DNS resolution latency and capture results with timestamps
- Generate realistic workloads (file I/O + process activity + DNS lookups) and observe syscall patterns
- Build small automation tooling to analyze syscall and DNS outputs and generate a performance report
- Apply eBPF outputs to identify bottlenecks (I/O-heavy syscall profiles, slow DNS, high file-open/exec activity)

---

## ✅ Prerequisites

- Linux administration fundamentals
- CLI comfort + basic shell scripting
- Understanding of syscalls, kernel basics, and process behavior
- DNS fundamentals + basic network troubleshooting
- Performance monitoring concepts (bottlenecks, latency, baselines)

---

## ☁️ Lab Environment

| Component | Details |
|---|---|
| OS | CentOS Stream 9 |
| Kernel | `5.14.0-4xx.el9.x86_64` |
| eBPF filesystem | `bpffs` mounted at `/sys/fs/bpf` |
| debugfs | mounted at `/sys/kernel/debug` |
| Tools used | BCC tools (`syscount.py`, `gethostlatency.py`, optional `opensnoop.py`, `execsnoop.py`), `nslookup`, `host`, `dig`, standard GNU tools |
| Workloads used | file create/read/delete loop, `ping`, `ps`, `/proc` listing, DNS lookup loops |

---

## 🗂️ Repository Structure

```text
lab19-using-ebpf-for-system-performance-analysis/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── test_workload.sh
    ├── analyze_syscalls.py
    ├── dns_test.sh
    ├── analyze_dns_latency.py
    ├── comprehensive_monitor.sh
    ├── simulate_issues.sh
    ├── realtime_analyzer.py
    └── generate_performance_report.py
````

> **Note:** This lab also generates output artifacts (captured during execution), such as:

* `syscount_output.txt`
* `dns_latency.log`
* `ebpf_monitoring_YYYYMMDD_HHMMSS/` (monitoring bundle directory)

These are recorded in `output.txt` and can optionally be committed under a `artifacts/` folder, but in this repo layout we keep them referenced in logs to keep the structure clean.

---

## 🧩 Lab Tasks Overview (No commands here — commands are in `commands.sh`)

### ✅ Task 1: Set Up eBPF Tools & Environment

* Confirmed kernel version is eBPF-ready.
* Verified tracing filesystem exists and bpffs is mounted.
* Ensured BCC tools and Python bindings are installed.
* Ensured debugfs is mounted and tracing events are accessible.

### ✅ Task 2: Use `syscount` to Trace System Calls

* Captured baseline syscall activity for a fixed duration.
* Traced syscalls for a specific PID (`sleep` target).
* Built a test workload to generate file/process/network activity.
* Captured syscall patterns during workload into a file for analysis.
* Explored advanced syscount modes:

  * by process name (`-P`)
  * filtering specific syscalls (`-e`)
  * interval snapshots (`-i`)
* Built a Python parser to summarize syscall output and derive “performance insight” (I/O-heavy profile).

### ✅ Task 3: Measure DNS Latency with `gethostlatency`

* Verified tool availability and reviewed help.
* Ran real-time DNS tracing and generated DNS activity via `nslookup/host/dig`.
* Captured timestamped output to a log file.
* Built a Python analyzer to compute stats, distribution buckets, slowest hosts, and warnings.

### ✅ Task 4: Analyze Performance Issues with eBPF

* Built an automation script to run multiple BCC tools together:

  * `syscount` + `gethostlatency` + optional `opensnoop/execsnoop`
* Generated controlled workload while monitoring.
* Simulated typical “issue patterns”:

  * excessive file I/O churn
  * failed DNS lookups
  * rapid process creation
  * syscall-heavy `/proc` reads
* Built a real-time file-based analyzer (works on produced logs).
* Completed a report generator producing:

  * `performance_report.json`
  * `performance_report.txt`
  * with detected issues + recommendations (based on recorded data)

---

## ✅ Verification Summary

This lab verifies eBPF tracing by demonstrating:

* Kernel + bpffs + debugfs readiness
* BCC tools accessible (`syscount.py`, `gethostlatency.py`)
* Syscall counts shift noticeably during workload (I/O-heavy signatures)
* DNS latency can be measured and summarized with timestamps
* Multi-tool monitoring can capture correlated signals (syscalls + DNS + file opens + execs)
* Automated analysis produces structured findings and actionable recommendations

---

## 📌 Result

✅ I used BCC-based eBPF tools to trace syscall behavior and DNS latency in real time, generated controlled workloads to surface patterns, and built analysis + reporting scripts to turn raw eBPF output into performance insights and recommendations.

---

## 💡 Why This Matters

eBPF provides **low-overhead kernel visibility** that is extremely practical for production troubleshooting, especially when:

* services feel slow but CPU usage looks “normal”
* I/O-related syscall volume spikes response times
* DNS intermittently delays service discovery
* you need evidence-based analysis without invasive instrumentation

---

## 🌍 Real-World Applications

* Detecting file-churn causing high `openat/close/read/write/unlink`
* Identifying DNS latency spikes affecting API calls or microservice dependencies
* Validating whether “slow” is compute vs I/O vs network-related
* Building lightweight monitoring bundles for incident response
* Supporting performance baselines and regression comparisons

---

## 🧾 Conclusion

In this lab, I successfully:

* Verified system readiness for eBPF
* Used `syscount` to observe syscall patterns (baseline + workload + advanced modes)
* Used `gethostlatency` to measure DNS lookup latency and log results
* Automated multi-tool monitoring and created analysis scripts + reporting outputs
* Produced a structured performance report with detected issues and recommendations

✅ **Lab 19 completed successfully — eBPF tools used for syscall + DNS performance analysis with automation and reporting.**
