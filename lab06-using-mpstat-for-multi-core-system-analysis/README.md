# 🧪 Lab 06: Using `mpstat` for Multi-Core System Analysis

**Category:** Red Hat Certified Specialist in Performance Tuning (Exam Labs)  
**Environment:** Ubuntu 24.04.1 LTS (Cloud Lab Environment)  
**User:** `toor`  
**Host:** `ip-172-31-10-187`  
**Date:** 2026-02-25  

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand the fundamentals of multi-core CPU architecture and performance monitoring
- Install and configure the `sysstat` package containing the `mpstat` utility
- Execute `mpstat` commands to monitor CPU usage across multiple cores
- Interpret `mpstat` output to identify performance bottlenecks and utilization patterns
- Analyze CPU load distribution across individual cores and logical processors
- Generate CPU stress scenarios to observe real-time performance metrics
- Optimize resource allocation using CPU affinity and process distribution techniques
- Create automated monitoring scripts for continuous CPU performance tracking
- Apply performance tuning techniques for multi-core systems

---

## ✅ Prerequisites

Before starting this lab, I had:

- Basic understanding of Linux CLI
- Familiarity with system administration concepts
- Knowledge of CPU architecture fundamentals (cores, threads, hyperthreading)
- Understanding of performance metrics (user/system/idle/iowait/steal)
- Basic bash scripting knowledge
- Familiarity with process monitoring tools (`ps`, `uptime`, scheduling basics)

---

## 🧰 Lab Environment

This lab was performed in a cloud-based Linux environment:

| Component | Details |
|----------|---------|
| OS | Ubuntu 24.04.1 LTS |
| Kernel | Linux 6.8.0-xx-generic |
| CPU | Intel(R) Xeon(R) Platinum 8259CL CPU @ 2.50GHz |
| Logical CPUs | 4 |
| Cores per Socket | 2 |
| Threads per Core | 2 |
| Hypervisor | KVM |
| Tools Installed | sysstat (`mpstat`), stress, bc |

---

## 📁 Repository Structure

```text
lab06-using-mpstat-for-multi-core-system-analysis/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── baseline_cpu.sh
    ├── cpu_analysis.sh
    ├── detect_bottlenecks.sh
    ├── cpu_affinity_test.sh
    ├── optimize_processes.sh
    ├── cpu_dashboard.sh
    ├── historical_analysis.sh
    ├── generate_report.sh
    └── setup_monitoring.sh
````

---

## 🧩 Lab Tasks Overview

### ✅ Task 1: Environment Preparation and `mpstat` Installation

* Verified CPU architecture and logical processor layout using:

  * `lscpu`, `/proc/cpuinfo`, `nproc`, and `uptime`
* Installed required monitoring tools:

  * Installed `sysstat` (contains `mpstat`)
  * Enabled and started `sysstat` service for SAR data collection
  * Verified `/etc/default/sysstat` is enabled for historical logging

---

### ✅ Task 2: Basic `mpstat` Usage and CPU Monitoring

* Captured CPU statistics across all cores:

  * `mpstat -P ALL`
* Sampled CPU performance across time windows:

  * `mpstat -P ALL 2 5`
* Focused on a single core for targeted observation:

  * `mpstat -P 0 2 5`
* Confirmed timestamp-based monitoring output:

  * `mpstat -P ALL 1 3 | head -20`

---

### ✅ Task 3: Advanced CPU Load Distribution Analysis

* Installed stress tool and generated load conditions:

  * Full multi-core CPU load: `stress --cpu $(nproc)`
* Observed real-time utilization changes using `mpstat`
* Built automation scripts to:

  * Generate controlled single-core vs multi-core vs I/O load
  * Log output to `cpu_stats.log`
  * Identify peak utilization periods

---

### ✅ Task 4: Resource Allocation Optimization

* Performed CPU affinity tests using `taskset`:

  * Verified how pinning workloads to specific CPUs affects per-core utilization
* Demonstrated load balancing:

  * Scenario 1: processes pinned to CPU0 (poor distribution)
  * Scenario 2: processes distributed across all CPUs (good distribution)
* Verified improvements via `mpstat -P ALL` averages and per-core totals

---

### ✅ Task 5: Advanced Analysis and Reporting

* Performed historical analysis using `sar`:

  * Detected sysstat log file (e.g., `/var/log/sysstat/sa25`)
  * Generated CPU summary + per-core reports
* Created a performance report generator:

  * Captures system configuration, memory info, CPU averages, stress test results
  * Adds recommendations based on utilization and load balance (stddev)
* Built automated continuous monitoring setup:

  * Creates `/home/toor/cpu_monitoring/`
  * Logs CPU stats every 5 minutes
  * Alerts when CPU utilization crosses threshold
  * Rotates/compresses old logs
  * Includes optional `systemd` service file

---

## ✅ Result

By completing this lab, I successfully:

* Installed and validated `mpstat` and sysstat services
* Established baseline CPU metrics
* Measured CPU utilization across multi-core CPUs
* Generated stress workloads to observe real-time utilization spikes
* Identified load imbalance and possible bottlenecks
* Verified CPU pinning and distribution techniques using `taskset`
* Built scripts for analysis, reporting, and long-term monitoring automation

---

## 📌 What I Learned

* The difference between **physical cores** vs **logical CPUs (threads)**
* How to interpret key `mpstat` fields like:

  * `%usr`, `%sys`, `%iowait`, `%steal`, `%idle`
* How virtualization can introduce measurable `%steal` time
* How to validate whether workloads are evenly distributed across cores
* Why pinning workloads (`taskset`) can help critical services
* How to automate CPU monitoring and build repeatable performance reports

---

## 🌍 Why This Matters

Modern systems rely heavily on multi-core performance. Knowing how to:

* detect CPU bottlenecks,
* verify load distribution,
* tune CPU affinity,
* monitor long-term trends,

…is essential for performance engineering in production environments.

---

## 🧠 Real-World Applications

This lab maps directly to:

* Performance troubleshooting in Linux servers
* Capacity planning (scaling CPU cores when needed)
* Diagnosing uneven load in containerized workloads
* Identifying CPU starvation or VM steal-time issues
* Optimizing scheduling and CPU affinity for critical workloads
* Building monitoring automation that can run continuously

---

## ✅ Conclusion

This lab built strong hands-on skills for multi-core CPU performance analysis using `mpstat`.

I successfully:

* Verified CPU architecture and logical processor layout
* Installed and enabled sysstat for real-time + historical monitoring
* Used `mpstat` for per-core utilization analysis
* Generated controlled stress tests for CPU load simulation
* Detected load imbalance and bottlenecks using scripts
* Tested CPU affinity and process distribution strategies
* Built automation for dashboards, reports, and continuous monitoring

✅ Lab completed successfully on a cloud lab environment.

