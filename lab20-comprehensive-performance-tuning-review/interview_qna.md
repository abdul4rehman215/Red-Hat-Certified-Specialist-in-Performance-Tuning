# 🎤 Interview Q&A — Lab 20: Comprehensive Performance Tuning Review

> This Q&A is based strictly on what was performed in **Lab 20** (multi-tool collection → analysis → tuning → validation → reporting → automation).

---

## 1) What is the goal of a “comprehensive performance tuning review”?
To follow an end-to-end workflow:
**collect evidence → analyze metrics → identify bottlenecks → apply targeted tuning → validate with tests → document results → automate ongoing monitoring.**

---

## 2) Which tools did you use for performance data collection in this lab?
- **sar** (sysstat) for historical and interval-based CPU/memory/disk/network metrics  
- **top** for CPU/process snapshots (batch mode logging)  
- **iostat** for extended disk I/O stats  
- **perf** for low-level CPU profiling and hardware counter statistics  
- **ps** for top CPU and memory consuming processes

---

## 3) How did you organize performance artifacts so they are reviewable later?
Created a workspace under:
`/opt/performance-review`  
with folders:
- `cpu-data/`
- `memory-data/`
- `disk-data/`
- `network-data/`
- `reports/`

---

## 4) How did you pull historical performance data from the system?
Copied sysstat data from:
`/var/log/sa/sa*`  
into:
`/opt/performance-review/cpu-data/`

Then created reports using:
- `sar -u -f ...` (CPU)
- `sar -r -f ...` (memory)
- `sar -d -f ...` (disk)
- `sar -n DEV -f ...` (network)

---

## 5) How did you create a real-time baseline that captures multiple resources at once?
Used a single script (`monitor-system.sh`) that ran:
- `top -b` → CPU/process snapshot log
- `sar -u -r 300 12` → CPU+memory 1 hour sampling (5-min intervals)
- `iostat -x 300 12` → disk sampling
- `sar -n DEV 300 12` → network sampling

---

## 6) How did you generate controlled load to validate monitoring and reveal bottlenecks?
Used `stress-ng` for CPU and memory and `dd` for disk I/O:
- CPU: `stress-ng --cpu 2 --timeout 300s`
- Memory: `stress-ng --vm 1 --vm-bytes 512M --timeout 300s`
- Disk: `dd if=/dev/zero of=/tmp/testfile bs=1M count=1000`

---

## 7) What is the difference between `sar`, `top`, and `perf` in performance analysis?
- `sar`: time-series system metrics (trend + averages)
- `top`: real-time process view (who is consuming CPU/memory now)
- `perf`: low-level profiling (where CPU cycles go, call graphs, counters)

---

## 8) What did you do with `perf` in this lab?
- Captured system-wide profiling samples:
```bash
sudo perf record -g -a sleep 60
````

* Generated report:

```bash
sudo perf report --stdio > cpu-data/perf-report-....
```

* Captured performance counters:

```bash
sudo perf stat -a -d sleep 30 2> cpu-data/perf-stat-....
```

---

## 9) How did you identify resource-heavy processes?

Captured process lists into files:

* CPU heavy:

```bash
ps aux --sort=-%cpu | head -20 > cpu-data/top-cpu-processes.txt
```

* Memory heavy:

```bash
ps aux --sort=-%mem | head -20 > memory-data/top-memory-processes.txt
```

---

## 10) What checks did you perform to detect abnormal process states?

Checked for zombies/defunct:

```bash
ps aux | grep -E "(zombie|defunct)" > reports/problematic-processes.txt
```

In this lab result, it was:

* `0 reports/problematic-processes.txt`

---

## 11) What outputs did your analysis phase generate?

Scripts created structured reports:

* `reports/cpu-analysis-*.txt`
* `reports/memory-analysis-*.txt`
* `reports/disk-analysis-*.txt`

Each report included:

* current system snapshot
* trend snippet (sar tail)
* top consumers
* threshold-based recommendations

---

## 12) Why did CPU governor tuning not fully apply in this environment?

Because many cloud VMs do not expose `cpufreq` governors.
In the output, it showed:

* `N/A (cpufreq not available in this VM)`
  So the script handled it gracefully instead of failing.

---

## 13) What memory optimizations were applied?

* Dropped caches:

```bash
echo 3 > /proc/sys/vm/drop_caches
```

* Reduced swappiness to `10`
* Enabled memory overcommit (`vm.overcommit_memory=1`)
  Also appended settings to `/etc/sysctl.conf`

---

## 14) What disk optimizations were applied?

* Checked scheduler values under `/sys/block/*/queue/scheduler`
* Preferred `mq-deadline` where applicable
* Cleaned old temp files in `/tmp` and `/var/tmp`
* Added log rotation policy `/etc/logrotate.d/performance-optimization`
* Listed large files (>100MB) to identify cleanup targets

---

## 15) What system-wide tuning changes did you implement?

Created:

* `/etc/sysctl.d/99-performance-tuning.conf` (network + memory + fs)
* `/etc/systemd/system.conf.d/performance.conf` (timeouts)
* updated `/etc/security/limits.conf` (nofile + nproc)

Applied immediately using:

```bash
sysctl -p /etc/sysctl.d/99-performance-tuning.conf
```

---

## 16) How did you validate changes with repeatable testing?

Used `performance-test.sh` to:

* run stress workload for 5 minutes
* collect `sar` and `iostat` during the same test window
* store test evidence under:
  `/opt/performance-review/test-results/`

---

## 17) What final report did you generate and what did it include?

Generated:

* `reports/final-performance-report-*.txt`

Included:

* system specs (CPU model, memory size, storage size)
* summary metrics (load avg, mem %, swappiness, scheduler)
* list of optimizations applied
* ongoing monitoring command set
* recommendations

---

## 18) How did you set up ongoing performance monitoring?

Created:

* `/opt/performance-monitoring/daily-monitor.sh`
* `/opt/performance-monitoring/weekly-monitor.sh`

Installed cron jobs:

```bash
0 6 * * * /opt/performance-monitoring/daily-monitor.sh
0 7 * * 1 /opt/performance-monitoring/weekly-monitor.sh
```

---

## 19) Why is documentation and reporting critical in performance tuning?

Because tuning without evidence becomes guesswork. Reports create:

* baseline proof
* change history
* justification for adjustments
* repeatable verification steps

---

## 20) What would you do next in a real production environment?

* compare baseline test results before/after tuning (same workload)
* identify whether bottlenecks are CPU-bound, memory-bound, I/O-bound, or contention-based
* tune per workload type (web, database, batch processing)
* keep changes controlled and reversible (sysctl.d files, service configs)
* monitor continuously and alert on regression

---
