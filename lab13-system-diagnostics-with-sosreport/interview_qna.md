# 💬 Interview Q&A — Lab 13: System Diagnostics with `sosreport`

> This Q&A is based on the work performed in **Lab 13**, focusing on generating and analyzing `sosreport` archives for troubleshooting and performance tuning.

---

## 1) What is `sosreport` and why is it used?

`sosreport` generates a compressed archive containing system configuration and diagnostic information (logs, configs, command outputs).  
It’s commonly used for:
- troubleshooting incidents
- performance investigations
- support escalation (standard diagnostic bundle)
- documenting system state at a point in time

---

## 2) What kind of data does `sosreport` collect?

It collects a wide range of evidence such as:
- `/etc` configuration files (networking, services, system config)
- `/proc` and `/sys` runtime kernel/system information
- logs (journald logs, messages, service logs depending on plugins)
- command outputs (ip, ss, lsblk, sysctl, rpm list, systemd units, etc.)

---

## 3) Why did you run `sosreport` with `--batch`?

`--batch` runs the report generation with **no interactive prompts**, which is important for:
- automation
- remote environments
- consistent report generation
- saving time during incident response

---

## 4) What’s the difference between a full report and a targeted report?

- **Full report:** runs many enabled plugins (system-wide snapshot, larger size).
- **Targeted report:** uses `--only-plugins=...` to collect only relevant areas (smaller, faster, focused).

Example targeted use cases from this lab:
- networking/firewall triage
- performance triage (cpu/memory/kernel/block)
- storage stack triage (block/filesys/lvm/md/multipath)

---

## 5) How do you list available plugins?

```bash
sosreport --list-plugins
````

This helped confirm what was enabled and what could be selectively collected.

---

## 6) How do you understand what a specific plugin collects?

Use:

```bash
sosreport --describe <plugin>
```

In this lab I used:

* `--describe networking`
* `--describe kernel`
* `--describe performance`

This showed what files and commands each plugin includes.

---

## 7) Where were your reports stored and what format were they?

Reports were stored under:

* `/var/tmp/sosreports/`

Format:

* `.tar.xz` compressed archives
  Example filename pattern:
* `sosreport-hostname-YYYY-MM-DD-HHMMSS.tar.xz`

---

## 8) What steps did you follow to examine the sosreport contents?

1. Identify latest report archive
2. Extract using `tar -xf`
3. Enter extracted directory
4. Explore layout with `find` (tree was missing)

Key directories observed:

* `etc/`
* `proc/`
* `var/log/`
* `sos_commands/`
* `sys/`

---

## 9) What are examples of “quick performance signals” you extracted from the report?

From extracted report files:

* `proc/loadavg` for system load average
* `proc/cpuinfo` for CPU model and CPU count
* `proc/meminfo` and `free` for memory usage
* `proc/pressure/memory` for memory pressure metrics
* `df`, `lsblk`, and `proc/diskstats` for storage usage and I/O indicators
* `proc/net/dev` for network errors/drops

---

## 10) What did you learn from memory pressure metrics?

The file:

* `proc/pressure/memory`

Shows:

* `some` pressure (memory contention affecting some tasks)
* `full` pressure (memory contention affecting all tasks)

In the lab output, pressure was near zero, indicating no active memory pressure.

---

## 11) Why did you create `analyze_performance.sh`?

To automate the repeated “first-pass triage” steps:

* count CPU cores
* read load averages
* summarize memory totals and availability
* flag high disk usage thresholds
* point to network error checks

This converts raw sosreport data into a quick summary for performance bottleneck identification.

---

## 12) Why did your load-per-CPU calculation show “calculation unavailable”?

The `bc` utility was not installed initially, so division fallback printed:

* `calculation unavailable`

Later, installing `bc` fixed the environment limitation:

```bash
sudo dnf install bc -y
```

---

## 13) What’s a best practice for keeping sosreport archives smaller?

Use targeted collection or skip heavy plugins:

* `--only-plugins=...` (small and focused)
* `--skip-plugins=logs,rpm` (reduces archive size)

This is useful when bandwidth/storage or time is limited.

---

## 14) When would you choose targeted plugins vs full report in real life?

* **Targeted plugins:** when you already know the area (network outage, storage issue, performance tuning).
* **Full report:** when the issue is unclear, intermittent, or you need comprehensive evidence for escalation.

---

## 15) What’s one major real-world use of sosreport beyond troubleshooting?

Documentation + audit evidence:

* capturing system configuration baselines
* tracking drift (before/after changes)
* building repeatable operational workflows (monthly/weekly reports)

This lab included example scripts for recurring collection and analysis.
