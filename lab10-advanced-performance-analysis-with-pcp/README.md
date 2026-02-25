# 📊 Lab 10: Advanced Performance Analysis with PCP (Performance Co-Pilot)

**Category:** Red Hat Certified Specialist in Performance Tuning (Exam Labs)  
**Environment:** CentOS/RHEL 8/9 (Cloud Lab Environment)  
**Primary (Monitoring Server):** `pcp-monitor`  
**Targets:** `target-1`, `target-2`  
**User:** `centos`  
**Date:** 2026-02-25  

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Install and configure **Performance Co-Pilot (PCP)** on multiple Linux systems
- Start and validate PCP services (`pmcd`, `pmlogger`) for live + historical monitoring
- Configure and verify essential **PMDAs** (metric domain agents)
- Monitor real-time CPU, memory, disk, and load metrics across **multiple hosts**
- Configure `pmlogger` for long-term metric collection across remote systems
- Analyze historical archives with `pmval` and `pmdumptext`
- Configure alerting rules using **pmie** and validate them under load
- Create basic dashboards/reports and automate monitoring via cron

---

## ✅ Prerequisites

- Linux administration fundamentals
- Comfort with CLI + scripting (bash)
- Awareness of performance metrics: CPU, memory, disk, network
- Basic networking + SSH to multiple hosts
- Familiar with editing files using nano/vim

---

## 🧰 Lab Environment

This lab simulated a small distributed monitoring setup:

| Role | Hostname | Notes |
|------|----------|------|
| Monitoring Server | `pcp-monitor` | PCP installed + collects local + remote metrics |
| Target | `target-1` | PCP agent + logger enabled |
| Target | `target-2` | PCP agent + logger enabled |

All systems were reachable over the internal lab network (`192.168.1.0/24`).

---

## 📁 Repository Structure

```text
lab10-advanced-performance-analysis-with-pcp/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── scripts/
│   ├── multi_system_monitor.sh
│   ├── pmstat_all.sh
│   ├── generate_load.sh
│   ├── performance_dashboard.sh
│   ├── trend_analysis.sh
│   ├── comparative_analysis.sh
│   ├── comprehensive_report.sh
│   └── automated_monitoring.sh
├── config/
│   ├── pmcd.conf.snippet.txt
│   ├── pmcd.options.appended.txt
│   ├── pmlogger.control.appended.txt
│   └── pmie_rules.conf
└── reports/
    ├── pcp_reports_samples.txt
    ├── pcp_comprehensive_report_sample.html
    └── pcp_monitoring_log_sample.txt
````

✅ Notes:

* The lab created reports under `/tmp/pcp_reports/` and `/tmp/*.html`.
  In the repo, they belong under `reports/`.
* The pmie rules were created in `/tmp/pmie_rules` then copied to `/etc/pcp/pmie/config.local`.
  In the repo, store them as `config/pmie_rules.conf`.

---

## 🧩 Tasks Overview

### ✅ Task 1: Install PCP on All Systems + Enable Services

* Verified primary host identity (`hostname`, `whoami`)
* Installed PCP packages:

  * `pcp`, `pcp-gui`, `pcp-system-tools`
  * additional exporters/importers + PMDAs
* Started + enabled services:

  * `pmcd`
  * `pmlogger`
* Repeated core PCP install + services on `target-1` and `target-2` over SSH

---

### ✅ Task 2: Configure PMDAs + Validate Metrics

* Checked installed PMDAs under:

  * `/var/lib/pcp/pmdas/`
* Verified agent status with:

  * `pminfo -f pmcd.agent.status`
* Validated metrics and sampling:

  * `pminfo kernel.all.load`
  * `pmval -s 5 kernel.all.load`

---

### ✅ Task 3: Multi-System Monitoring Setup

* Verified PMDA entries exist in:

  * `/etc/pcp/pmcd/pmcd.conf`
* Appended access rules into `pmcd.options` (lab flow) and restarted pmcd
* Confirmed remote metric access:

  * `pminfo -h target-1 kernel.all.load`
  * `pminfo -h target-2 kernel.all.load`
  * also verified with IPs

---

## 📈 Real-Time Monitoring Done

* Sampled CPU usage:

  * `pmval -s 10 -t 2 kernel.all.cpu.user`
* Parallel collection from targets:

  * `pmval -h target-1 ... &`
  * `pmval -h target-2 ... &`
* Used `pmstat` for quick summary
* Created scripts for repeatable monitoring:

  * `multi_system_monitor.sh`
  * `pmstat_all.sh`

---

## 🗃️ Historical Monitoring with `pmlogger`

* Updated `/etc/pcp/pmlogger/control` to log remote hosts:

  * `target-1`
  * `target-2`
* Restarted `pmlogger`
* Generated load using `stress-ng` + disk writes for realistic metrics
* Verified archives exist:

  * `/var/log/pcp/pmlogger/localhost/`
  * `/var/log/pcp/pmlogger/target-1/`
  * `/var/log/pcp/pmlogger/target-2/`
* Queried archives:

  * `pmval -a ... kernel.all.load`
  * `pmdumptext -a ... kernel.all.cpu.user ...`

---

## 🚨 Alerting with `pmie`

* Created pmie rules:

  * High CPU usage > 80%
  * High memory usage > 90%
  * High load average > 4
  * Low disk space for `/dev/sda1`
* Enabled and started pmie service
* Tested alert behavior under generated load
* Verified log evidence:

  * `/var/log/pcp/pmie/localhost/pmie.log`

---

## 📊 Reporting + Automation

* Built a dashboard script generating per-host summaries:

  * `/tmp/pcp_reports/*_summary_*.txt`
* Built scripts for:

  * trend analysis
  * comparative analysis across hosts
  * comprehensive HTML report generation
* Installed automated monitoring script to:

  * `/usr/local/bin/automated_monitoring.sh`
* Scheduled it via cron every 5 minutes:

  * `/etc/crontab`

---

## ✅ Result

At the end of the lab, I had a working distributed PCP monitoring setup:

* PCP installed on **monitor + 2 targets**
* Real-time multi-host monitoring working with `pminfo` / `pmval`
* Historical archives collected via `pmlogger`
* Alert rules with `pmie` validated under load
* Automated monitoring with logs + scheduled execution

---

## 🧠 What I Learned

* PCP architecture: **pmcd + PMDAs + pmlogger + pmie**
* How distributed monitoring works (remote host queries)
* How to build evidence: real-time samples + historical archives + reports
* How to automate collection and alerting like in real environments
* How to troubleshoot missing metrics, PMDA issues, and connectivity problems

---

## 🌍 Why This Matters (Real-World Use)

PCP is an enterprise-grade monitoring tool used for:

* Fleet monitoring across many Linux servers
* Capacity planning and performance trending
* Root-cause analysis of CPU/memory/disk bottlenecks
* Alerting on thresholds and performance anomalies
* Building reports for stakeholders and operations teams

---

## ✅ Conclusion

In this lab, I successfully deployed and validated a distributed PCP monitoring environment across three systems, implemented both real-time and historical performance monitoring, and added automated alerting and reporting. This workflow matches production monitoring practices and builds strong preparation for performance tuning work in enterprise environments.
