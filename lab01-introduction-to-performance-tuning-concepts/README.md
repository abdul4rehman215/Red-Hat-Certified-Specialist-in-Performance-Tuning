# 🧪 Lab 01: Introduction to Performance Tuning Concepts

> **Environment:** CentOS/RHEL 9 (Cloud Lab Environment)  
> **User:** `root`  
> **Focus:** Baseline → Detect bottlenecks → Apply safe tuning → Validate with metrics

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand the primary goals and principles of performance tuning in Linux systems
- Identify and analyze common resource bottlenecks (CPU, memory, disk, and network)
- Implement basic tuning strategies for CPU optimization
- Apply memory management techniques to improve system performance
- Configure disk I/O optimization settings
- Use open-source monitoring tools to assess system performance
- Interpret performance metrics and make data-driven tuning decisions

---

## 🧰 Prerequisites

Before starting this lab, the following knowledge was required:

- Basic Linux command-line knowledge
- Understanding of Linux file system structure
- Familiarity with text editors (vi/vim or nano)
- Basic knowledge of system processes and services
- Understanding of Linux user permissions and sudo access

---

## 🖥️ Lab Environment

This lab was performed on a **cloud-hosted Linux practice VM** with:

- **OS:** CentOS Stream / RHEL 9 family
- **Shell:** bash
- **Access:** root + sudo available
- **Network:** enabled for package installation
- **Tools installed during the lab:** `htop`, `iotop`, `sysstat (sar/iostat)`, `perf`, `stress-ng`, `bc`, `lsof`

> Note: The original lab environment text mentions the provider name; this repo documents work done in a **guided cloud lab environment** (sandbox VM).

---

## 🗂️ Repository Structure

```text
lab01-introduction-to-performance-tuning-concepts/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── performance_baseline.sh
    ├── detect_cpu_bottleneck.sh
    ├── detect_memory_bottleneck.sh
    ├── detect_disk_bottleneck.sh
    ├── set_cpu_governor.sh
    ├── optimize_cpu.sh
    ├── monitor_cpu_performance.sh
    ├── analyze_memory.sh
    ├── cleanup_memory.sh
    ├── optimize_disk.sh
    ├── monitor_disk_io.sh
    ├── analyze_disk_io.sh
    ├── tune_filesystem.sh
    └── performance_test_suite.sh
````

---

## ✅ Task Overview (What I Did)

### ✅ Task 1: Understand performance tuning goals + establish a baseline

* Reviewed tuning objectives: throughput, response time, utilization, scalability, UX, and cost
* Updated the system and installed monitoring tools
* Enabled **sysstat** for ongoing metric collection
* Created a baseline snapshot script to capture CPU, memory, disk, load average, and top processes

### ✅ Task 2: Identify resource bottlenecks (CPU, memory, disk)

* Simulated CPU load using `stress-ng` and monitored with:

  * `htop` (interactive)
  * `sar -u` (per-second CPU utilization)
* Checked memory health using:

  * `free -h`, `swapon --show`, `sar -r`
  * Verified no OOM-killer events in `dmesg`
* Checked disk I/O behavior using:

  * `iotop` (interactive)
  * `iostat -x` (extended disk metrics)
  * `df -h` (space utilization)
* Built detection scripts to standardize the checks for repeatability

### ✅ Task 3: Apply CPU tuning strategies

* Validated that CPU frequency scaling files were not available (common on cloud VMs)
* Installed `kernel-tools` and used `cpupower` to view and set governors
* Set the governor to `performance`
* Practiced process tuning:

  * `renice` to adjust scheduling priority
  * `taskset` to verify CPU affinity behavior
* Created scripts to automate CPU governor setup + optimization workflows
* Built a CPU monitoring script that logs metrics to `/var/log/cpu_performance.log`

### ✅ Task 4: Apply memory tuning strategies

* Collected baseline `sysctl` values for memory behavior:

  * swappiness, dirty ratios, cache pressure
* Created `/etc/sysctl.d/99-memory-tuning.conf` and applied it
* Built analysis + cleanup scripts:

  * memory inspection + fragmentation visibility
  * safe cache drop method using `tee` (fixes common sudo-redirection mistake)

### ✅ Task 5: Apply disk I/O tuning strategies

* Verified filesystem type and mount options
* Inspected available I/O schedulers and applied a safer scheduler for NVMe (`none`)
* Adjusted read-ahead values
* Built scripts for:

  * disk monitoring + analysis
  * filesystem tuning checks (XFS note: already optimized in many cases)

### ✅ Comprehensive performance test suite (end-to-end validation)

* Built a test suite to run CPU, memory, and disk tests and generate a combined report
* Stored outputs in `~/performance_results/` and created a summary report file
* Confirmed results through a report preview using `sed`

---

## 📌 Key Metrics Observed

### CPU

* Load average vs CPU cores
* `%user`, `%system`, `%idle` (via `sar -u`)
* top CPU consumers via `ps aux --sort=-%cpu`

### Memory

* `MemAvailable` + swap usage (`free -h`, `sar -r`, `swapon --show`)
* OOM checks (`dmesg | grep -i killed process`)
* process memory ranking via `ps aux --sort=-%mem`

### Disk

* `%util`, `await`, `rkB/s`, `wkB/s` via `iostat -x`
* I/O heavy tasks via `iotop`
* filesystem space and inode usage via `df -h` / `df -i`

---

## ✅ Result

* Installed and enabled a full baseline monitoring toolkit
* Captured baseline performance snapshots for CPU/memory/disk
* Simulated load safely using `stress-ng` and validated metrics with `sar/iostat`
* Applied realistic tuning methods for cloud VMs:

  * `cpupower` governor tuning instead of missing `cpufreq` sysfs paths
  * safe memory cache cleanup using `tee` for privileged writes
  * NVMe scheduler + read-ahead tuning
* Generated a combined **performance summary report** under `~/performance_results/`

---

## 🧠 What I Learned

* Why **baseline metrics** must be captured before changing anything
* How to interpret:

  * CPU load average vs core count
  * `%iowait` vs real disk bottlenecks
  * memory “free vs available” and swap usage indicators
* Why cloud VMs often behave differently (CPU frequency scaling exposure varies)
* How to make tuning steps repeatable using scripts and logs

---

## 🌍 Why This Matters

Performance tuning is not guesswork — it’s **measurement-driven**.
For production systems and security operations, stable performance directly affects:

* monitoring reliability (SOC visibility)
* incident response speed
* log ingestion capacity (SIEM)
* system stability under load
* cost efficiency in cloud environments

---

## 🧩 Real-World Applications

* Baseline creation for system hardening and compliance
* Diagnosing “slow server” incidents
* Tuning for logging-heavy systems (SIEM agents, audit pipelines)
* Reducing noisy bottlenecks before scaling infrastructure
* Performance validation after patching or configuration changes

---

## 🏁 Conclusion

This lab established a complete beginner-to-practical performance tuning workflow:

✅ **Measure first (baseline)** → ✅ **Detect bottlenecks** → ✅ **Apply safe tuning** → ✅ **Validate with metrics**

All artifacts are stored as separate files for GitHub traceability:

* commands executed (`commands.sh`)
* full outputs (`output.txt`)
* reusable scripts (`scripts/`)
* interview prep (`interview_qna.md`)
* troubleshooting reference (`troubleshooting.md`)
