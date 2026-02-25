# 🧪 Lab 05: Analyzing Disk Performance with `iostat`

> **Environment:** RHEL 9 (Cloud Lab Environment)  
> **User:** `root`  
> **Primary Tools:** `iostat` (sysstat), `lsblk`, `ionice`, scheduler tuning via `/sys/block/*/queue/scheduler`  
> **Workloads:** Synthetic mixed read/write workloads + automated monitoring scripts

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Monitor disk I/O performance using `iostat` and interpret key metrics
- Identify disk I/O bottlenecks using utilization, latency (await), and throughput metrics
- Test and optimize storage performance by changing disk I/O schedulers
- Implement storage performance tuning strategies for Linux environments
- Generate synthetic workloads to validate performance improvements

---

## 🧰 Prerequisites

- Linux CLI basics (navigation, file editing)
- Understanding of file systems and storage fundamentals
- Familiarity with performance metrics (latency, throughput, utilization)
- Root/sudo privileges for scheduler changes and tuning
- Process/job management including background execution

---

## 🖥️ Lab Environment

This lab was performed in a **guided cloud lab environment (sandbox VM)** with:

- RHEL/CentOS family system
- `sysstat` installed (provides `iostat`)
- NVMe block devices (not traditional `/dev/sda`)
- Tools available for generating I/O load and validating changes

> Note: The original lab text mentions the provider name; this repo documents the work completed in a **cloud sandbox VM** without including provider branding in repo content.

---

## 🗂️ Repository Structure

```text
lab05-analyzing-disk-performance-with-iostat/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── disk_monitor.sh
    ├── iostat_metrics_guide.txt
    ├── io_workload_generator.sh
    ├── bottleneck_analyzer.sh
    ├── baseline_measurement.sh
    ├── check_schedulers.sh
    ├── scheduler_guide.txt
    ├── scheduler_performance_test.sh
    ├── optimize_schedulers.sh
    ├── make_persistent.sh
    └── validate_optimization.sh
````

---

## ✅ Task Overview (What I Did)

### ✅ Task 1: Monitor Disk Performance with iostat

* Verified `iostat` availability and version (`iostat -V`)
* Confirmed sysstat package is installed (`rpm -q sysstat`)
* Collected baseline disk stats:

  * `iostat` (basic device throughput)
  * `iostat -x` (extended metrics like await/queue/%util)
* Ran continuous monitoring (`iostat -x 2`) and stopped manually
* Attempted legacy device names (`/dev/sda`, `/dev/sdb`) and corrected using NVMe naming via `lsblk`
* Built an automated monitoring script (`disk_monitor.sh`) that logs extended stats to timestamped files

### ✅ Task 1.3: Build a metrics reference guide

* Documented and saved a **key metrics guide** for iostat:

  * utilization, throughput, latency, queue depth
  * bottleneck thresholds (e.g., %util > 80%, await > 20ms, queue > 2)

---

## 🔎 Task 2: Identify Bottlenecks Using Workloads + Analysis Scripts

### ✅ Generate Synthetic I/O Workloads

* Created a workload generator (`io_workload_generator.sh`) supporting:

  * random read load
  * sequential write load
  * mixed I/O load
* Observed workload impact live using `iostat -x 2`

### ✅ Automated Bottleneck Detection

* Created `bottleneck_analyzer.sh` which:

  * collects iostat samples
  * checks for:

    * high `%util` (> 80%)
    * high `await` (> 20ms)
    * high `aqu-sz` (> 2)
  * writes a timestamped report

### ✅ Establish Baselines (Idle vs Loaded)

* Created `baseline_measurement.sh` that collects:

  * system info
  * idle iostat sample logs
  * loaded iostat sample logs (during synthetic workload)
  * a baseline summary report for comparisons over time

---

## ⚙️ Task 3: Change Disk I/O Schedulers to Improve Performance

### ✅ Identify Current and Available Schedulers

* Created `check_schedulers.sh` to enumerate schedulers:

  * highlighted current scheduler in `[]` brackets

### ✅ Learn Scheduler Characteristics

* Saved a scheduler comparison reference (`scheduler_guide.txt`) explaining:

  * `mq-deadline`, `kyber`, `bfq`, `none`
  * common selection criteria for SSD/NVMe vs HDD workloads

### ✅ Benchmark Schedulers with a Controlled Test

* Used `scheduler_performance_test.sh` to:

  * enumerate available schedulers for a given device
  * apply each scheduler
  * run test workload and capture iostat logs
  * generate a comparison report with avg %util and await

> Real-world correction used in lab: initial `sda` failed because the VM uses `nvme0n1`.

### ✅ Apply Recommended Scheduler

* Used `optimize_schedulers.sh` to apply recommended scheduler:

  * selected **kyber** for NVMe SSD
  * applied only to `nvme0n1` and skipped `nvme1n1`

### ✅ Make Scheduler Persistent Across Reboots

* Created `make_persistent.sh` that writes udev rules:

  * `/etc/udev/rules.d/60-io-schedulers.rules`
  * includes scheduler + nr_requests tuning

> Authenticity note kept in repo: rule line uses `mqdeadline` (no hyphen). Some kernels expect `mq-deadline`, but this is stored exactly as used in the lab flow.

---

## ✅ Task 3.4: Validate Performance Improvements

* Created `validate_optimization.sh` to:

  * capture current scheduler config
  * run post-optimization workload test
  * collect `iostat` logs and produce a validation report:

    * avg utilization
    * avg await
    * avg queue size

---

## 📌 Key Observations from This Lab

* **Device naming matters in cloud VMs:** `/dev/sda` may not exist; NVMe naming (`nvme0n1`) is common.
* `iostat -x` is the most useful view for diagnosing performance:

  * `%util` (saturation)
  * `await` / `r_await` / `w_await` (latency)
  * `aqu-sz` (queue pressure)
* Scheduler tuning can measurably impact latency under load:

  * this lab showed lower average await after selecting kyber for NVMe

---

## 🧠 What I Learned

* How to confirm storage health and performance quickly using `iostat`
* How to separate:

  * **throughput problems** vs **latency problems** vs **saturation**
* How to safely test schedulers in a controlled way:

  * baseline → change → retest → validate
* How to persist tuning using udev rules rather than manual post-boot commands

---

## 🌍 Why This Matters

Storage bottlenecks often become the limiting factor in real systems:

* slow web apps or databases
* increased request latency under load
* high load average caused by I/O wait
* queue buildup during backup jobs or ETL tasks

Being able to diagnose and tune disk I/O using open-source tools (`iostat`, scheduler tuning, `ionice`) is a core skill for Linux performance engineering and production troubleshooting.

---

## 🏁 Conclusion

This lab built a complete storage performance workflow:

✅ Measure (`iostat`) → ✅ Generate load → ✅ Detect bottlenecks → ✅ Tune scheduler → ✅ Persist changes → ✅ Validate results

---

