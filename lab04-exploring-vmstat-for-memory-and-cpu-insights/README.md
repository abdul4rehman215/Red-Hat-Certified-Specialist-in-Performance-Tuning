# 🧪 Lab 04: Exploring `vmstat` for Memory and CPU Insights

> **Environment:** RHEL 9 (Cloud Lab Environment)  
> **User:** `root`  
> **Focus:** Understand `vmstat` output → monitor trends → simulate memory/swap/CPU/I/O scenarios → build baselines + dashboards

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand the purpose and functionality of the `vmstat` command
- Use `vmstat` to monitor real-time system performance metrics
- Analyze memory usage patterns and identify memory bottlenecks
- Monitor swap activity and understand its impact on system performance
- Interpret CPU utilization statistics and identify performance issues
- Recognize signs of system resource contention
- Apply `vmstat` analysis techniques for performance tuning scenarios

---

## 🧰 Prerequisites

Before starting this lab, the following knowledge was required:

- Basic Linux command line usage
- General system administration concepts
- Memory management basics (RAM, swap, virtual memory)
- CPU basics (user space, kernel space, I/O wait)
- Terminal access (root/sudo)

---

## 🖥️ Lab Environment

This lab was performed on a **cloud-hosted Linux sandbox VM** with:

- RHEL/CentOS family system
- `procps-ng` tools installed (includes `vmstat`)
- Root or sudo privileges
- Enough resources to generate observable performance metrics

> Note: The original lab text mentions the provider name; this repo documents work completed in a **guided cloud lab environment (sandbox VM)**.

---

## 🗂️ Repository Structure

```text
lab04-exploring-vmstat-for-memory-and-cpu-insights/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── memory_test.sh
    ├── swap_test.sh
    ├── memory_analysis.sh
    ├── cpu_test.sh
    ├── io_test.sh
    ├── cpu_analysis.sh
    ├── memory_trend.sh
    ├── system_baseline.sh
    ├── performance_simulator.sh
    └── monitor_dashboard.sh
````

---

## ✅ Task Overview (What I Did)

### ✅ Task 1: Understand vmstat basics and initial system analysis

* Verified `vmstat` exists (`which vmstat`)
* Reviewed `vmstat` documentation (`man vmstat`, `vmstat --help`)
* Ran a default snapshot (`vmstat`) and mapped each column group:

  * **procs:** `r` runnable, `b` blocked
  * **memory:** `swpd`, `free`, `buff`, `cache`
  * **swap:** `si`, `so`
  * **io:** `bi`, `bo`
  * **system:** `in`, `cs`
  * **cpu:** `us`, `sy`, `id`, `wa`, `st`
* Performed continuous monitoring:

  * `vmstat 2` (manual stop)
  * `vmstat 3 5` (fixed count)

### ✅ Task 2: Memory analysis and bottleneck identification

* Created a memory load generator (`memory_test.sh`)
* Monitored memory effects in real-time:

  * watched `free` decrease
  * tracked `buff/cache` shifts
  * validated whether swap (`swpd`, `si`, `so`) activated

### ✅ Task 2.2: Swap activity monitoring

* Verified swap configuration and current usage:

  * `free -h`, `swapon --show` (zram-based swap present)
* Created swap pressure tool (`swap_test.sh`) which uses `stress` if present
* Observed swap usage under pressure in `vmstat`:

  * `swpd` increased and `so` appeared during pressure
  * confirmed reduced free memory during the test

### ✅ Task 2.3: Memory bottleneck identification report

* Created `memory_analysis.sh` to generate:

  * `free -h`, swap summary (`swapon`)
  * `/proc/meminfo` breakdown
  * top memory consumers
  * `vmstat 1 5` summary sample for quick reading
* Documented interpretation rules:

  * low free memory + rising `swpd` + frequent `si/so` + higher `b` indicates bottleneck

### ✅ Task 3: CPU performance analysis

* Captured baseline CPU with `vmstat 2 10`
* Built a CPU load generator (`cpu_test.sh`) with two phases:

  * user-space compute load
  * mixed I/O + compute
* Observed CPU signals in vmstat:

  * `us` increased during compute
  * `sy` increased during mixed work
  * `id` decreased during busy periods
  * `wa` increased when I/O was involved (if storage became the bottleneck)

### ✅ Task 3.2: I/O wait analysis

* Created `io_test.sh` to generate real disk read/write pressure
* Observed:

  * increased `bi/bo` during disk ops
  * `b` (blocked) can rise under I/O contention
  * `wa` may rise if disk latency becomes dominant

### ✅ Task 3.3: CPU bottleneck identification report

* Created `cpu_analysis.sh` which outputs:

  * CPU model and core count
  * load average
  * CPU usage snapshot
  * top CPU processes
  * `vmstat 2 10` sample
  * interpretation rules: high `us+sy`, high `r`, high `wa`

### ✅ Task 4: Advanced vmstat usage and tuning workflows

* Disk stats:

  * `vmstat -d` and `vmstat -d 3 5`
* Partition stats:

  * attempted `/dev/sda1` (failed)
  * verified correct device via `lsblk`
  * reran using `/dev/nvme0n1p1` successfully

### ✅ Task 4.2: Memory stats deep dive

* Used `vmstat -s` for event counters and totals
* Built a trend exporter `memory_trend.sh` that logs CSV lines every few seconds

  * Noted a realistic minor CSV formatting imperfection (extra value) but kept as-is per lab flow

### ✅ Task 4.3: Establish a performance baseline (for future comparisons)

* Created `system_baseline.sh` to generate a single baseline file capturing:

  * system info, CPU, memory, disk, interfaces
  * vmstat baseline samples + vmstat -s + vmstat -d
* Produced a timestamped baseline file for historical comparisons

### ✅ Task 5: Simulating performance issues and real-time monitoring

* Built a menu-driven simulator (`performance_simulator.sh`) for:

  * memory leak simulation
  * CPU spike simulation
  * I/O bottleneck simulation
  * all simulations combined
* Built a `vmstat` dashboard (`monitor_dashboard.sh`) that:

  * refreshes every 2 seconds
  * parses `vmstat` line into variables
  * prints colored status (normal/warning/critical) for:

    * user CPU, system CPU, I/O wait
    * swap activity detection (si/so)
    * run queue `r` vs CPU cores
    * blocked processes `b`

---

## 📌 Key Observations from This Lab

* `vmstat` is excellent for *fast bottleneck classification*:

  * **CPU-bound:** high `us/sy`, low `id`, `r` grows
  * **I/O-bound:** higher `wa`, `b` grows, higher `bi/bo`
  * **Memory pressure:** rising `swpd`, active `si/so`, very low free/available memory
* Partition tooling must match actual device names in cloud VMs:

  * `sda1` may not exist; NVMe naming (`nvme0n1p1`) is common
* Swap in this lab was backed by zram:

  * swap can appear without physical disk swap partitions

---

## ✅ Result

* Successfully used `vmstat` for:

  * real-time monitoring
  * trend analysis
  * bottleneck detection (CPU/memory/I/O)
* Simulated realistic performance problems and confirmed their signatures in `vmstat`
* Generated automation tools:

  * memory/swap/CPU/I/O load scripts
  * baseline generator
  * real-time dashboard analyzer

---

## 🧠 What I Learned

* `vmstat` gives a compact, high-signal view of system health:

  * scheduler pressure (`r`)
  * I/O contention (`b`, `wa`, `bi/bo`)
  * swap activity (`si/so`) and memory pressure (`swpd`)
* You can troubleshoot “system slow” quickly by correlating:

  * load average + `r/b` + `us/sy/id/wa` + swap signals
* Baselines are powerful:

  * capture normal behavior → compare during incidents → find what changed

---

## 🌍 Why This Matters

In enterprise environments, performance issues often show up as:

* slow applications and timeouts
* unexplained high load
* sudden swap usage and latency spikes

Knowing how to interpret `vmstat` allows faster triage and more accurate root-cause direction:

* CPU scaling vs query optimization
* memory tuning vs fixing leaks
* storage throughput/latency vs workload scheduling

---

## 🏁 Conclusion

This lab established a complete `vmstat` workflow:

✅ Observe (`vmstat`) → ✅ simulate issues → ✅ interpret bottleneck signals → ✅ automate dashboards → ✅ generate baselines
