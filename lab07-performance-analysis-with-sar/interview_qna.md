# 🎤 Lab 07 — Interview Q&A (sar + Historical Performance Analysis)

> This file contains interview-style questions and answers based on the work performed in **Lab 07: Performance Analysis with sar**.

---

## 1) What is `sar` and what problem does it solve?
**Answer:**  
`sar` (System Activity Reporter) is part of the `sysstat` package and is used to collect and report historical performance data for CPU, memory, disk, and network. It solves the problem of “only seeing the current moment” by allowing analysis of system behavior over time.

---

## 2) What package provides `sar` and how do you verify it’s installed?
**Answer:**  
`sar` is provided by the `sysstat` package. On Ubuntu/Debian:
```bash
sudo apt install -y sysstat
sar -V
````

The `sar -V` output confirms the sysstat version.

---

## 3) How does `sar` get its historical data?

**Answer:**
`sar` reads binary data collected by `sadc` via scheduled jobs (cron/systemd timers depending on distro). These collectors run `sa1` / `sa2` (or `debian-sa1` / `debian-sa2` on Ubuntu) which writes daily activity logs.

---

## 4) Where are SAR data files stored on Ubuntu in this lab?

**Answer:**
On this Ubuntu system, SAR logs were stored in:

* `/var/log/sysstat/saDD`
* `/var/log/sysstat/sarDD`
  The `/var/log/sa/` path did not exist.

---

## 5) Why did the command `sar -u -f /var/log/sa/sa25` fail?

**Answer:**
Because `/var/log/sa` is common on some distributions, but on Ubuntu the sysstat logs were located in `/var/log/sysstat`. So the correct file path was:

```bash
sar -u -f /var/log/sysstat/sa25
```

---

## 6) What does `sar -u` show and how do you interpret it?

**Answer:**
`sar -u` shows CPU usage metrics such as:

* `%user`, `%system`, `%iowait`, `%steal`, `%idle`
  High `%user` indicates application load, high `%system` indicates kernel overhead, high `%iowait` points to storage delays, and high `%steal` can indicate hypervisor contention in virtual environments.

---

## 7) What is the difference between `sar -u` and `sar -P ALL`?

**Answer:**

* `sar -u` shows overall CPU metrics (aggregate, usually `all`).
* `sar -P ALL` breaks down CPU utilization per CPU/core so you can detect uneven load distribution or pinning effects.

---

## 8) How did you ensure data collection happens more frequently?

**Answer:**
I edited `/etc/cron.d/sysstat` to change the collection from every 10 minutes to every 2 minutes using Ubuntu’s `debian-sa1` and `debian-sa2` tooling:

```text
*/2 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1
53 23 * * * root command -v debian-sa2 > /dev/null && debian-sa2 -A
```

---

## 9) How did you validate that sysstat collection was actually working?

**Answer:**
I checked:

* sysstat service status (`systemctl status sysstat`)
* presence of log files in `/var/log/sysstat/`
* forced an immediate collection using:

```bash
sudo /usr/lib/sysstat/sa1 1 1
```

Then verified output:

```bash
sar -u 1 1
```

---

## 10) What does `sar -r` provide and why is it useful?

**Answer:**
`sar -r` provides memory usage statistics like free/used memory, cache, buffers, and `%memused`. It’s useful to identify memory pressure, trending increases in memory consumption, and support capacity planning.

---

## 11) How did you monitor swap and paging behavior in this lab?

**Answer:**
I used:

* `sar -S` for swap usage
* `sar -B` for paging activity (faults, page in/out, major faults)
  In this environment, swap was `0`, which is common for small cloud instances.

---

## 12) What does `sar -d` show and what disk metrics matter most?

**Answer:**
`sar -d` shows disk device performance:

* `tps` (transactions per second)
* `rkB/s`, `wkB/s` (read/write throughput)
* `await` (average request latency)
* `%util` (device busy time)
  High `await` and high `%util` together often indicate disk bottlenecks.

---

## 13) Why did you create stress scripts (CPU/memory/disk) for this lab?

**Answer:**
Historical monitoring is only useful if meaningful workload data exists. The stress scripts created controlled load so that `sar` logs captured measurable behavior and the analysis scripts produced realistic reports.

---

## 14) What was the purpose of the master performance report script?

**Answer:**
The master report script combined CPU, memory, and disk summaries into one report and generated:

* HTML report (for structured viewing)
* Text report (for quick review / terminal use)
  It also added status classification and recommendations.

---

## 15) How did you automate reporting and snapshots?

**Answer:**
I created `setup_sar_automation.sh` which:

* generates periodic snapshots every 10 minutes
* runs the master report daily at 01:00 AM
* cleans up old reports (keeps 7 days)
  It installed cron entries in `/etc/cron.d/sar-automation`.

---
