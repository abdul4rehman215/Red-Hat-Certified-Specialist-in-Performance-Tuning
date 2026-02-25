# 🎤 Interview Q&A — Lab 02: Installing Performance Monitoring Tools

> This Q&A is based on the tasks performed in this lab: installing sysstat tooling, enabling SAR collection, running top/vmstat/iostat/sar, automating monitoring with scripts + cron, and managing logs with logrotate.

---

## 1) What is the purpose of installing performance monitoring tools on RHEL?
To proactively observe CPU, memory, disk, and network behavior, establish baselines, detect bottlenecks early, and support incident response and root-cause analysis with real metrics.

---

## 2) Which package provides `sar`, `iostat`, and `mpstat` on RHEL?
The **`sysstat`** package. After installing it, these tools become available and can be verified with `which sar`, `which iostat`, and `which mpstat`.

---

## 3) Why does `sar` need sysstat service/collection enabled to be useful?
`sar` becomes significantly more valuable when sysstat continuously collects data into `/var/log/sa/`.  
Without collection, historical reporting and trending analysis won’t work properly.

---

## 4) Why did `nethogs` fail to install initially?
Because `nethogs` is typically not in the default RHEL BaseOS/AppStream repos. It often comes from **EPEL**, so installing `epel-release` enables the repository and resolves the package.

---

## 5) What information does `top` provide that helps identify performance issues?
`top` provides real-time visibility into:
- CPU usage breakdown (`us`, `sy`, `id`, `wa`)
- memory usage (used, free, buffers/cache, available)
- process list with CPU and memory consumption
- load average and system uptime
This helps quickly spot runaway processes and high load conditions.

---

## 6) What does `vmstat` show that `top` does not emphasize?
`vmstat` focuses on system-wide performance counters like:
- run queue (`r`) and blocked processes (`b`)
- swap activity (`si`, `so`)
- block I/O (`bi`, `bo`)
- interrupts and context switches (`in`, `cs`)
It is very useful for identifying memory pressure and scheduling pressure.

---

## 7) What are the key metrics in `iostat -x` that indicate disk bottlenecks?
Common indicators include:
- `%util` (device utilization)
- `await` (average I/O wait time)
- high read/write operations (`r/s`, `w/s`)
- throughput (`rkB/s`, `wkB/s`)
If `%util` stays high and `await` increases, storage may be a bottleneck.

---

## 8) Why did `iostat -x sda` fail, and what is the correct approach?
It failed because the VM used **NVMe** storage (`nvme0n1`) rather than `sda`.  
Correct approach:
- verify device names using `lsblk` or `iostat` output
- then run `iostat -x nvme0n1 ...`

---

## 9) What is the difference between real-time monitoring and historical monitoring?
- **Real-time monitoring**: views current state (e.g., `top`, `vmstat 2 10`, `iostat 2 5`)
- **Historical monitoring**: uses collected data to analyze trends (e.g., `sar -u`, `sar -f /var/log/sa/sa25`)
Historical analysis is essential for identifying slow performance degradation over time.

---

## 10) Where does sysstat store its collected data on RHEL?
Sysstat stores data files under:
- `/var/log/sa/`
Examples:
- `sa25` (binary daily file)
- `sar25` (text summary file)

---

## 11) What is the purpose of `/etc/cron.d/sysstat`?
It schedules sysstat collection commands:
- `sa1` runs periodically (every 10 minutes in this lab)
- `sa2` runs daily to generate summary reports
This ensures continuous performance data collection.

---

## 12) Why is automating monitoring important in enterprise environments?
Because performance issues can be intermittent. Automation ensures:
- consistent data collection
- minimal human error
- repeatable evidence for troubleshooting
- quick trend and baseline comparisons
This improves reliability and speeds up root-cause analysis.

---

## 13) How did you implement continuous monitoring in this lab?
By creating a monitoring script (`system_monitor.sh`) and scheduling it with **cron** to run every 15 minutes:
```bash
*/15 * * * * /tmp/system_monitor.sh > /dev/null 2>&1
````

---

## 14) Why did you configure log rotation for monitoring logs?

Automated monitoring generates many logs. Without log rotation, logs can fill disk space and create new performance problems.
Using logrotate ensures:

* limited retention (rotate 7)
* compression
* safe cleanup of old logs

---

## 15) What is the purpose of the baseline creation script?

To capture “normal” operating conditions for CPU, memory, disk I/O, and network into a structured directory (`/tmp/performance_baseline`).
This baseline becomes a reference point to compare future performance states and detect abnormal behavior.

---
