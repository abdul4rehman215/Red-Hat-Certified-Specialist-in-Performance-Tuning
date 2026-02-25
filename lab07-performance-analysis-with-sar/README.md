# 🧪 Lab 07: Performance Analysis with `sar` (System Activity Reporter)

**Category:** Red Hat Certified Specialist in Performance Tuning (Exam Labs)  
**Environment:** Ubuntu 24.04.1 LTS (Cloud Lab Environment)  
**User:** `toor`  
**Host:** `ip-172-31-10-203`  
**Date:** 2026-02-25  

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Install and configure `sar` (System Activity Reporter) for continuous performance monitoring
- Set up automated data collection for historical performance analysis (cron-based collection)
- Analyze CPU utilization patterns and identify performance bottlenecks
- Examine memory usage trends and detect memory-related issues
- Monitor disk I/O performance and storage subsystem behavior
- Generate comprehensive performance reports from historical data
- Interpret `sar` output to make informed system optimization decisions
- Create custom monitoring scripts for specific performance scenarios
- Produce a combined “master report” (HTML + text) and automate snapshot/report generation

---

## ✅ Prerequisites

Before starting this lab, I had:

- Basic Linux CLI skills
- Familiarity with system administration concepts
- Knowledge of CPU, memory, and disk fundamentals
- Understanding of performance monitoring principles
- Experience with text editors like `nano`
- Basic bash scripting knowledge

---

## 🧰 Lab Environment

This lab was performed in a cloud-based Linux environment:

| Component | Details |
|----------|---------|
| OS | Ubuntu 24.04.1 LTS |
| Kernel | Linux 6.8.0-xx-generic |
| Tooling | `sysstat` (`sar`, `sadc`, `sa1`, `sa2`) |
| Access | sudo/root access available |
| Notes | Ubuntu uses `/var/log/sysstat/` for SAR logs (not `/var/log/sa/`) |

---

## 📁 Repository Structure

```text
lab07-performance-analysis-with-sar/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── enhanced_sar_collection.sh
    ├── cpu_stress_test.sh
    ├── analyze_cpu_performance.sh
    ├── memory_stress_test.sh
    ├── analyze_memory_performance.sh
    ├── disk_stress_test.sh
    ├── analyze_disk_performance.sh
    ├── master_performance_analysis.sh
    └── setup_sar_automation.sh
````

---

## 🧩 Lab Tasks Overview

### ✅ Task 1: Set Up `sar` to Collect System Activity Data Over Time

#### Subtask 1.1: Verify and Install `sysstat`

* Confirmed RPM tools are not present on Ubuntu (`rpm: command not found`)
* Updated repositories with `apt update`
* Ensured `sysstat` is installed (already newest version)
* Verified `sar` version and validated sysstat utilities:

  * `sar -V`
  * `ls -la /usr/bin/sa*`

#### Subtask 1.2: Configure Data Collection Service

* Enabled and started `sysstat` service
* Verified `sysstat` status with systemd
* Reviewed existing cron-based collection in `/etc/cron.d/sysstat`:

  * Default activity collection every **10 minutes**
* Modified cron schedule to collect every **2 minutes**
* **Important Ubuntu fix applied:** retained schedule/intent but used correct Ubuntu tooling:

  * `debian-sa1` and `debian-sa2`
  * path: `/usr/lib/sysstat/`
    (instead of `/usr/lib64/sa/`)

#### Subtask 1.3: Verify Data Collection Setup

* Verified that `/var/log/sa` does not exist on this system
* Confirmed SAR logs stored in:

  * `/var/log/sysstat/saDD`
  * `/var/log/sysstat/sarDD`
* Forced immediate data collection:

  * Ubuntu fix used: `sudo /usr/lib/sysstat/sa1 1 1`
* Verified collection by running:

  * `sar -u 1 1`

#### Subtask 1.4: Custom Enhanced Data Collection Script

* Created `/usr/local/bin/enhanced_sar_collection.sh`
* Script runs targeted 10-minute collection with 30-second intervals:

  * CPU: `sar -u 30 20`
  * Memory: `sar -r 30 20`
  * Disk: `sar -d 30 20`
  * Network: `sar -n DEV 30 20`
* **Ubuntu fix applied:** logs stored in `/var/log/sysstat` (not `/var/log/sa`)
* Ran script once to validate it starts cleanly

---

### ✅ Task 2: Analyze CPU Performance Metrics from Historical Data

#### Subtask 2.1: Generate CPU Load for Testing

* Created and launched `cpu_stress_test.sh` in background
* Workload phases:

  * Light load (2 cores)
  * Heavy load (4 cores)
  * Variable pattern (1→5 cores sequentially)

#### Subtask 2.2: Collect Real-time CPU Data

* Captured real-time CPU averages:

  * `sar -u 5 20`
* Captured per-core CPU breakdown:

  * `sar -P ALL 5 10`
* Logged longer sample to file for later review:

  * `sar -u 2 300 > cpu_performance_<timestamp>.log &`

#### Subtask 2.3: Analyze Historical CPU Data

* Attempted `/var/log/sa/saDD` (failed—expected on some distros)
* **Ubuntu fix applied:** analyzed from:

  * `/var/log/sysstat/sa$(date +%d)`
* Generated:

  * full-day summary
  * last 2 hours time-range analysis
  * tail summaries
* Built `analyze_cpu_performance.sh`:

  * **Ubuntu column fix applied:** totals computed using `%user + %system`
  * I/O wait uses correct Ubuntu `%iowait` column
  * Output saved as `cpu_analysis_report_YYYYMMDD.txt`

---

### ✅ Task 3: Analyze Memory Performance Metrics

#### Subtask 3.1: Generate Memory Load

* Created and launched `memory_stress_test.sh` in background
* Workload patterns:

  * gradual memory increase (100→800 MB)
  * multiple temporary allocations in `/tmp`
  * cleanup performed after testing

#### Subtask 3.2: Collect Memory Performance Data

* Real-time memory sampling:

  * `sar -r 5 20`
* Swap usage visibility:

  * `sar -S 5 10` (swap remained 0 in this environment)
* Paging activity:

  * `sar -B 5 15`
* Stored longer memory samples:

  * `sar -r 2 600 > memory_performance_<timestamp>.log &`

#### Subtask 3.3: Historical Memory Analysis Script

* Created `analyze_memory_performance.sh`
* **Ubuntu column fix applied:** `%memused` referenced correctly (Ubuntu `sar -r`)
* Output saved as: `memory_analysis_report_YYYYMMDD.txt`

---

### ✅ Task 4: Analyze Disk Performance Metrics

#### Subtask 4.1: Generate Disk I/O Load

* Created and launched `disk_stress_test.sh` in background
* Workloads performed:

  * sequential writes (multiple block sizes)
  * random I/O patterns (timed)
  * mixed workload (reads + writes)
  * cleanup of `/tmp/disk_test`

#### Subtask 4.2: Collect Disk Performance Data

* Device I/O statistics:

  * `sar -d 5 20`
* Device-named output:

  * `sar -d -p 5 15`
* Block device stats:

  * `sar -b 5 10`
* Stored longer disk samples:

  * `sar -d 2 600 > disk_performance_<timestamp>.log &`

#### Subtask 4.3: Historical Disk Analysis Script

* Created `analyze_disk_performance.sh`
* **Ubuntu field fix applied:** used `rkB/s` and `wkB/s` fields (Ubuntu `sar -d`)
* Output saved as: `disk_analysis_report_YYYYMMDD.txt`

---

### ✅ Task 5: Generate Comprehensive Performance Reports

#### Subtask 5.1: Master Performance Analysis Script

* Created `master_performance_analysis.sh`
* **Fixes applied:**

  * Data file path uses Ubuntu SAR logs: `/var/log/sysstat/saDD`
  * Installed `lynx` so the text report generation is clean
* Outputs generated:

  * HTML report: `/tmp/performance_reports/master_performance_report_<timestamp>.html`
  * Text report: `/tmp/performance_reports/master_performance_report_<timestamp>.txt`
* Included sections:

  * system overview (CPU/memory/disk/network)
  * CPU performance summary (avg/peak/min/high-util counts)
  * memory summary (avg/peak/high usage counts)
  * disk summary (avg TPS/utilization/high periods)
  * recommendations

#### Subtask 5.2: Automated Monitoring Setup (Snapshots + Daily Reports + Cleanup)

* Created `setup_sar_automation.sh` to generate:

  * `sar_snapshot.sh` (every 10 minutes snapshot)
  * `run_daily_report.sh` (runs master report daily)
  * `cleanup_reports.sh` (keeps 7 days)
* Created cron file:

  * `/etc/cron.d/sar-automation`
* Verified cron entries:

  * snapshots every 10 minutes
  * daily report at 01:00
  * cleanup at 01:10

---

## ✅ Result

By completing this lab, I successfully:

* Verified `sar` availability and sysstat toolset on Ubuntu
* Enabled sysstat service and tuned collection interval to every 2 minutes
* Confirmed SAR logs are created under `/var/log/sysstat/`
* Generated controlled workloads for CPU, memory, and disk
* Captured real-time and historical performance data using `sar`
* Built dedicated analysis scripts to generate readable reports:

  * CPU analysis report
  * Memory analysis report
  * Disk analysis report
* Built a master HTML performance report with a text version
* Automated snapshots + daily report generation + cleanup via cron

---

## 📌 What I Learned

* `sar` provides **historical trend analysis**, not just real-time performance
* On Ubuntu, SAR logs commonly live in `/var/log/sysstat/` and use `debian-sa1/debian-sa2`
* How to interpret common `sar` metrics:

  * CPU: `%user`, `%system`, `%iowait`, `%steal`, `%idle`
  * Memory: `%memused`, buffers, cache, commit metrics
  * Disk: `tps`, `rkB/s`, `wkB/s`, `await`, `%util`
* How to validate collection is working by:

  * checking the log files (`saDD`, `sarDD`)
  * forcing collection (`/usr/lib/sysstat/sa1 1 1`)
* How to produce practical reports and automate monitoring tasks cleanly

---

## 🌍 Why This Matters

Real performance tuning relies on **trends** and **history**, not just one “top” screenshot.
With `sar` logging enabled, it becomes possible to:

* detect sustained CPU load over time
* identify gradual memory pressure and paging activity
* confirm whether disk I/O behavior matches the workload
* support capacity planning and proactive troubleshooting

---

## ✅ Conclusion

This lab focused on setting up and using `sar` for real performance analysis.

I:

* confirmed sysstat tooling
* enabled continuous collection (cron + sysstat service)
* validated correct Ubuntu log locations and fixed paths
* generated workload data for CPU/memory/disk
* wrote scripts to convert SAR binary logs into useful reports
* created a combined master report (HTML + text)
* automated snapshots, daily reporting, and cleanup for repeatable monitoring

✅ Lab completed successfully on Ubuntu cloud lab environment.
