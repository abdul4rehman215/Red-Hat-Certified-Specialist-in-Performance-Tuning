# 🧪 Lab 02: Installing Performance Monitoring Tools

> **Environment:** RHEL 9.3 (Cloud Lab Environment)  
> **User:** `root`  
> **Focus:** Install + enable monitoring utilities → run core commands → automate monitoring + baselines

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Install and configure essential performance monitoring tools on Red Hat Enterprise Linux (RHEL)
- Understand the purpose and functionality of key monitoring utilities including `top`, `vmstat`, `iostat`, `mpstat`, and `sar`
- Execute basic monitoring tasks to analyze system performance metrics
- Interpret outputs from monitoring tools to identify system bottlenecks
- Configure monitoring tools for continuous system observation
- Apply performance monitoring best practices in enterprise environments

---

## 🧰 Prerequisites

Before starting this lab, the following knowledge was required:

- Basic Linux command line interface usage
- Familiarity with RHEL system administration concepts
- Understanding of processes and resource management
- CPU, memory, disk, and network fundamentals
- Root or sudo access
- Basic text editor skills (vi/vim or nano)

---

## 🖥️ Lab Environment

This lab was performed on a **cloud-hosted RHEL VM (guided sandbox environment)** with:

- **OS:** Red Hat Enterprise Linux 9.3 (Plow)
- **Kernel:** `5.14.0-362.24.2.el9_3.x86_64`
- **Virtualization:** KVM
- **Access:** root + sudo
- **Internet:** enabled for package installation

> Note: The original lab text mentions the provider name; this repo documents work completed on a **cloud lab environment (sandbox VM)**.

---

## 🗂️ Repository Structure

```text
lab02-installing-performance-monitoring-tools/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── vmstat_monitor.sh
    ├── system_monitor.sh
    ├── create_baseline.sh
    └── performance_analysis.sh
````

---

## ✅ Task Overview (What I Did)

### ✅ Task 1: Verify system information and current tool availability

* Confirmed RHEL version and kernel details using:

  * `/etc/redhat-release`, `uname -a`, `hostnamectl`
* Verified which monitoring tools were present (`top`, `vmstat`) and which were missing (`iostat`, `mpstat`, `sar`)
* Captured baseline resource state using:

  * `free -h`, `df -h`, `lscpu`

### ✅ Task 1.2: Install monitoring tool packages

* Updated repositories (`dnf update`)
* Installed **sysstat** to provide:

  * `iostat`, `mpstat`, `sar` (and others)
* Installed additional utilities:

  * `htop`, `iotop`
* Attempted to install `nethogs` and resolved dependency source issue:

  * Enabled `epel-release`, then installed `nethogs`
* Verified installation using:

  * `rpm -qa`, `which iostat/mpstat/sar`

### ✅ Task 1.3: Enable and configure sysstat for continuous collection

* Enabled + started the sysstat service
* Edited `/etc/sysconfig/sysstat` to set retention/compression:

  * `HISTORY=7`
  * `COMPRESSAFTER=10`
* Restarted sysstat to ensure config applied
* Verified sysstat scheduled collection via:

  * `/etc/cron.d/sysstat`

### ✅ Task 2: Run basic monitoring tasks and interpret outputs

* Used `top` in interactive mode and batch mode
* Saved `top` output to a file for documentation
* Used `sar` to capture:

  * CPU (`sar -u`)
  * Memory (`sar -r`)
  * Disk I/O (`sar -d`)
  * Network (`sar -n DEV`)
  * Load average (`sar -q`)
* Queried historical SAR data from `/var/log/sa/`
* Generated a comprehensive SAR report via `sar -A`

### ✅ Task 2.3: Use vmstat for memory + CPU + disk views

* Ran `vmstat` in single snapshot and interval mode
* Used:

  * `vmstat -S M` for MB formatting
  * `vmstat -d` for disk activity
  * `vmstat -a` for active/inactive memory visibility
* Built a small script to standardize `vmstat` collection

### ✅ Task 2.4: Use iostat for disk and CPU I/O interpretation

* Verified baseline I/O stats (`iostat`)
* Used interval reporting (`iostat 2 5`)
* Used extended disk metrics (`iostat -x`)
* Fixed a common “device name mismatch” issue:

  * VM uses `nvme0n1`, not `sda`
* Exported an I/O report to `/tmp/iostat_report.txt`

### ✅ Task 3: Advanced monitoring configuration (automation + operations readiness)

* Created a **system monitoring script** that:

  * captures CPU (`sar`), memory (`free`), disk (`iostat`), top processes (`ps`), load (`uptime`)
  * writes a timestamped report to `/tmp/system_monitor_<timestamp>.log`
* Configured a **cron job** to run monitoring every 15 minutes
* Implemented **log rotation** for generated monitoring logs using logrotate
* Built a **baseline collection script** that stores CPU/memory/disk/network baselines under `/tmp/performance_baseline`

### ✅ Task 4: Interpret monitoring output and generate recommendations

* Re-checked `top`, `vmstat`, `iostat` outputs and noted key columns for bottleneck detection
* Installed `bc` (already present) for numeric comparisons in analysis scripting
* Created a performance analysis script that outputs:

  * system info + uptime + load
  * CPU summary, memory %, disk usage, and top processes
  * simple actionable recommendations for follow-up investigation

---

## 📌 Key Tools and What They’re Used For

* **top** → real-time process + CPU/memory load view
* **vmstat** → memory, swap, I/O, and CPU scheduling indicators
* **iostat** → disk I/O utilization, latency (`await`), throughput, and device load
* **mpstat** → CPU usage per core (from sysstat)
* **sar** → time-series performance data (CPU/mem/disk/net/load), including historical analysis

---

## ✅ Result

* Successfully installed and enabled core performance tooling on RHEL 9:

  * `sysstat` (sar/iostat/mpstat), `htop`, `iotop`, `nethogs`
* Enabled continuous SAR collection and confirmed scheduled collection configuration
* Created reusable scripts for:

  * monitoring snapshots
  * automated periodic reporting
  * baseline creation
  * quick performance analysis with recommendations
* Produced report artifacts stored under `/tmp/` for validation and documentation

---

## 🧠 What I Learned

* Monitoring tools are most effective when:

  * enabled for **continuous collection**
  * paired with **automation (scripts + cron)**
  * protected with **log rotation** to prevent disk bloat
* Device naming matters in cloud VMs (NVMe vs SATA):

  * always validate disk devices (`lsblk`, `iostat` device list)
* `sar` becomes far more valuable once sysstat collection is running consistently because it enables:

  * trend analysis
  * historical comparisons
  * “what changed?” investigations during incidents

---

## 🌍 Why This Matters

Performance monitoring is the foundation of:

* proactive capacity planning
* incident response and RCA
* stability for production services
* reliable observability pipelines (logging/metrics)
* evidence-based tuning decisions

---

## 🏁 Conclusion

This lab established a complete performance monitoring setup on RHEL:

✅ Installed tools → ✅ enabled sysstat data collection → ✅ validated monitoring commands → ✅ automated reporting & baselines → ✅ documented outputs and reports

All artifacts are stored in separate GitHub-ready files:

* `commands.sh` → commands executed
* `output.txt` → full outputs captured
* `scripts/` → reusable monitoring + analysis scripts
* `interview_qna.md` → interview prep questions
* `troubleshooting.md` → common issues + fixes
