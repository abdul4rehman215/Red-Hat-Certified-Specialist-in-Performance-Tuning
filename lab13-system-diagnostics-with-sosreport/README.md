# 🧪 Lab 13: System Diagnostics with `sosreport`

> **Track:** Red Hat Certified Specialist in Performance Tuning (Exam)  
> **Lab Range in this repo:** Labs 11–15 (this folder = Lab 13)

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand the purpose and functionality of **`sosreport`** for system diagnostics
- Generate comprehensive diagnostic archives using **default** and **targeted plugin** collections
- Navigate and analyze extracted sosreport contents to locate system configuration and runtime data
- Interpret diagnostic data to identify potential performance bottlenecks
- Recognize common misconfigurations through report evidence (logs, services, network config, storage config)
- Apply best practices for structured troubleshooting using sosreport data

---

## ✅ Prerequisites

- Basic Linux CLI usage
- Familiarity with system administration concepts
- Understanding Linux filesystem structure
- Basic knowledge of logs and configuration files
- Basic networking concepts
- Root/sudo access

---

## 🧰 Lab Environment

This lab was performed in an online cloud lab environment.

| Component | Details |
|---|---|
| OS | RHEL 9.x (cloud VM) |
| Tool | `sosreport` (sos `4.7.2`) |
| Access | sudo/root |
| Output | `.tar.xz` diagnostic archives saved under `/var/tmp/sosreports` |

---

## 📁 Folder Name

`lab13-system-diagnostics-with-sosreport/`

---

## 🗂️ Repository Structure (Lab 13)

```text
lab13-system-diagnostics-with-sosreport/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── scripts/
│   ├── analyze_performance.sh
│   ├── sosreport-analyzer
│   ├── monthly-sosreport
│   └── sosreport-workflow
└── artifacts/
    └── system_health_report.txt
````

> 📌 **Notes**
>
> * In the lab VM, some scripts were created in `/tmp/` or `/usr/local/bin/`.
>   For GitHub organization, they are placed under `scripts/` with the same content.
> * `system_health_report.txt` is a generated report artifact, stored under `artifacts/`.

---

## 🧾 Lab Summary

This lab focused on collecting and analyzing **system-wide diagnostics** using `sosreport`, which bundles important configuration, logs, and command outputs into a compressed archive. I generated:

1. A **full** sosreport using default plugin selection
2. Multiple **targeted** sosreports for:

   * networking + firewall
   * performance + kernel + memory + block devices
   * storage stack (block/filesys/lvm/md/multipath)
3. Extracted a report archive and explored its structure using `find` (because `tree` was not installed)
4. Performed manual analysis of report contents:

   * system identity (hostname, OS, kernel, uptime)
   * CPU, memory, pressure metrics
   * storage layout + diskstats
   * network config + stats + DNS + services
   * processes/services and quick bottleneck indicators
5. Built reusable scripts to:

   * automate performance analysis of extracted sosreport data
   * generate a simple system health report
   * create a lightweight workflow for report generation + extraction + analysis
   * prepare “monthly collection” logic for operational best practices

---

## ✅ Tasks Overview

### ✅ Task 1: Understanding and Running `sosreport`

* Verified installation and version
* Reviewed help/options and plugin list
* Used `--describe` to understand what specific plugins collect
* Generated:

  * full sosreport (`--batch`)
  * targeted plugin reports (`--only-plugins`)
* Saved output archives to `/var/tmp/sosreports`

### ✅ Task 2: Extract and Examine Report Structure

* Listed report archives and selected the most recent one
* Extracted `.tar.xz` archive
* Explored top-level directories (`etc/`, `proc/`, `var/log/`, `sos_commands/`, etc.)
* Used `find` as a fallback when `tree` was unavailable

### ✅ Task 3: Analyze Report for Issues & Bottlenecks

* System overview:

  * hostname, uptime, date, os-release, uname, loadavg
* CPU analysis:

  * model, MHz, cache size
* Memory analysis:

  * meminfo, free output, pressure metrics
* Storage analysis:

  * `df`, mounts, `lsblk`, diskstats, filesystem error scan
* Network analysis:

  * ip addr/route, interface stats, DNS config, systemd unit overview
* Services/process analysis:

  * process snapshot, failed services check, load-per-CPU calculation attempt (noted missing `bc`)
* Log analysis:

  * messages scan, kernel log tail, auth failures check

### ✅ Task 4: Automation & Reporting

Created automation/reporting assets:

* `scripts/analyze_performance.sh` → summarizes CPU/memory/disk/network indicators from extracted report data
* `artifacts/system_health_report.txt` → compact health summary and recommendations
* `scripts/sosreport-analyzer` → reusable analyzer for a given extracted directory
* `scripts/monthly-sosreport` → example scheduled report generation logic
* `scripts/sosreport-workflow` → end-to-end pipeline: generate → extract → analyze

---

## ✅ Verification & Validation

I validated successful completion by confirming:

* `sosreport` exists and version is visible (`sos-4.7.2`)
* sosreport archives were generated successfully under `/var/tmp/sosreports/`
* targeted plugin reports were created with smaller sizes (network-focused, performance-focused, storage-focused)
* extraction produced expected directory structure (`etc/`, `proc/`, `var/`, `sos_commands/`)
* manual analysis files existed inside the extracted report (e.g., `hostname`, `uname`, `proc/*`, `etc/*`)
* analyzer scripts executed and produced expected summaries

---

## 📌 Result

* Multiple diagnostic archives produced successfully:

  * full system snapshot
  * targeted snapshots for specific investigative areas
* Report extraction and analysis completed
* Created a reusable tooling set to streamline future sosreport review and basic bottleneck identification

---

## 🧠 What I Learned

* How `sosreport` collects system state in a standardized, shareable format
* How to limit collection scope with plugin filters to reduce archive size
* Where key evidence lives in extracted archives (CPU/memory/storage/network/services/logs)
* How to build quick analysis scripts that convert raw report data into actionable summary
* How to think like a support/performance engineer: gather → narrow scope → validate signals → recommend next steps

---

## 💡 Why This Matters (Performance Tuning Context)

When troubleshooting performance, the hardest part is often gathering **complete and consistent evidence**.
`sosreport` creates a repeatable diagnostic snapshot that can be used to:

* confirm resource constraints (CPU load, memory pressure)
* inspect storage layout and I/O patterns
* validate network configuration and errors/drops
* identify misconfigurations in services, sysctl, firewall, etc.
* share findings with other teams or support channels in a structured way

---

## 🌍 Real-World Applications

* Production incident response and triage
* Performance bottleneck investigations (CPU/memory/disk/network)
* Baseline documentation for environments
* Support escalation packages (standardized evidence bundle)
* Regular health checks (monthly/weekly workflows)

---

## 🏁 Conclusion

In this lab, I generated and analyzed multiple `sosreport` archives (full + targeted), extracted report contents, reviewed key performance signals, and built reusable scripts for report analysis and workflow automation. This is directly relevant to real-world Linux performance troubleshooting and aligns with performance tuning certification objectives.

✅ **Lab 13 completed successfully on a RHEL-based cloud environment.**
