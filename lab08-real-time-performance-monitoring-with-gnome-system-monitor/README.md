# 🧪 Lab 08: Real-time Performance Monitoring with `gnome-system-monitor`

**Category:** Red Hat Certified Specialist in Performance Tuning (Exam Labs)  
**Environment:** Ubuntu 24.04.1 LTS (Cloud Lab Environment)  
**User:** `toor`  
**Host:** `ip-172-31-10-219`  
**Date:** 2026-02-25  

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Install and configure `gnome-system-monitor` for comprehensive system monitoring
- Navigate the `gnome-system-monitor` interface to view real-time system performance metrics
- Monitor CPU utilization patterns and identify performance bottlenecks
- Analyze memory usage and detect memory leaks or excessive consumption
- Track running processes and their resource consumption
- Identify performance issues through visual analysis of system metrics
- Implement basic system optimizations based on monitoring data
- Generate performance reports and document findings
- Understand the relationship between system resources and application performance

---

## ✅ Prerequisites

Before starting this lab, I had:

- Basic understanding of Linux OS and CLI
- Familiarity with system processes and resource management concepts
- Knowledge of CPU, memory, and disk I/O fundamentals
- Understanding of process management in Linux environments
- Basic troubleshooting skills for performance issues
- Familiarity with package management (`apt`, `dnf`, `yum`)

---

## 🧰 Lab Environment

This lab was performed in a cloud-based Linux environment:

| Component | Details |
|----------|---------|
| OS | Ubuntu 24.04.1 LTS |
| Host | ip-172-31-10-219 |
| CPU | 4 logical CPUs |
| Tools Installed | `gnome-system-monitor`, `htop`, `stress-ng`, `xvfb`, `net-tools`, `bc` |
| Note | Cloud environment is terminal-only (no display attached) |

---

## 📁 Repository Structure

```text
lab08-real-time-performance-monitoring-with-gnome-system-monitor/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── performance_checklist.txt
└── scripts/
    ├── cpu_monitor.sh
    ├── cpu_analysis.sh
    ├── memory_monitor.sh
    ├── memory_leak_sim.py
    ├── process_tree_demo.sh
    ├── cpu_intensive.sh
    ├── memory_intensive.sh
    ├── io_intensive.sh
    ├── process_manager.sh
    ├── system_stress.sh
    ├── performance_report.sh
    ├── system_optimizer.sh
    ├── performance_dashboard.sh
    ├── advanced_monitor.sh
    └── trend_analyzer.sh
````

---

## 🧩 Lab Tasks Overview

### ✅ Task 1: Installing and Configuring `gnome-system-monitor`

* Updated packages (`apt update && apt upgrade`)
* Installed:

  * `gnome-system-monitor` (GUI monitor)
  * `htop` (CLI monitor)
  * `stress-ng` (workload generator)
* Verified installation:

  * `which gnome-system-monitor`
  * `gnome-system-monitor --version`

#### Headless GUI Launch (Cloud Limitation)

The environment had no GUI display, so launching directly produced:

* `Gtk-WARNING **: cannot open display:`

To run it realistically in a terminal-only VM:

* Installed `xvfb`
* Launched the GUI headlessly using:

  * `xvfb-run -a gnome-system-monitor &`

---

### ✅ Task 2: Real-time CPU Utilization Monitoring

* Collected baseline CPU stats using:

  * `top -bn1`
* Built `cpu_monitor.sh` to log CPU % usage into `cpu_usage_log.txt`
* Generated controlled CPU load using `stress-ng`:

  * Full CPU utilization: `stress-ng --cpu 0 --timeout 120s --metrics-brief`
  * Partial load: `stress-ng --cpu 2 --timeout 60s`
  * Target intensity: `stress-ng --cpu 1 --cpu-load 75 --timeout 60s`
* Validated stress processes and CPU impact via:

  * `ps -eo pid,ppid,cmd,%cpu --sort=-%cpu`

---

### ✅ Task 3: Memory Usage Analysis and Monitoring

* Built `memory_monitor.sh` to log memory statistics into `memory_usage_log.txt`
* Ran memory stress scenarios using `stress-ng`:

  * `--vm 1 --vm-bytes 1G --timeout 120s --metrics-brief`
  * `--vm 4 --vm-bytes 256M --timeout 60s`
  * `--vm 1 --vm-bytes 2G --timeout 60s --vm-keep`
* Simulated a memory leak using `memory_leak_sim.py`

  * Verified increasing RSS:

    * `ps -p $LEAK_PID -o pid,%cpu,%mem,rss,cmd`
  * Stopped safely with:

    * `kill $LEAK_PID`

---

### ✅ Task 4: Process Management and Analysis

* Demonstrated process hierarchy using `process_tree_demo.sh`

  * Confirmed tree via:

    * `pstree -p <PID>`
* Created multiple workload processes:

  * CPU intensive loop (`cpu_intensive.sh`)
  * memory intensive allocation (`memory_intensive.sh`)
  * I/O intensive churn (`io_intensive.sh`)
* Captured resource snapshot:

  * `ps -p <pids> -o pid,%cpu,%mem,rss,stat,cmd`
* Tested priority tuning:

  * `renice +10 -p <PID>`
* Practiced termination methods:

  * `kill -TERM`, `kill -KILL`
* Built `process_manager.sh` to print PID info, memory details, and open file count

---

### ✅ Task 5: Performance Issue Identification and Optimization

* Created full-system stress scenario (`system_stress.sh`)
* Confirmed elevated CPU/memory during stress with:

  * `top -bn1`
* Stopped load early (realistic student workflow):

  * `pkill -f "stress-ng"`
* Built `performance_checklist.txt` (manual checklist used during monitoring)
* Built `performance_report.sh` to generate:

  * system information + CPU + memory + disk + network summary
* Installed `net-tools` for `netstat` compatibility on Ubuntu
* Created `system_optimizer.sh` (safe baseline “cleanup + checks” script)
* Created CLI dashboard (`performance_dashboard.sh`) and validated output using:

  * `timeout 6s ./performance_dashboard.sh`

---

### ✅ Task 6: Advanced Monitoring and Reporting

* Built `advanced_monitor.sh`:

  * Logs CPU, memory, processes, and alerts into `monitoring_logs/`
  * Used a shorter demo window (60s) for realism while keeping behavior the same
* Completed trend analysis with `trend_analyzer.sh`:

  * Computes avg/min/max CPU and memory
  * Counts threshold events
  * Summarizes alerts
  * Generates `monitoring_logs/trend_summary.txt`

---

## ✅ Result

By completing this lab, I successfully:

* Installed and verified `gnome-system-monitor` in Ubuntu
* Worked around cloud GUI limitations using `xvfb-run`
* Observed CPU/memory behavior through GUI concepts and validated with CLI outputs
* Generated CPU and memory workloads with `stress-ng`
* Simulated and identified a memory leak using Python
* Built multiple monitoring scripts and logging utilities
* Practiced process hierarchy analysis, priority adjustment, and termination
* Produced automated performance reports and trend summaries

---

## 📌 What I Learned

* How real-time monitoring tools correlate with CLI metrics (`top`, `ps`, `free`, `df`)
* How to reproduce bottlenecks using workload generators (`stress-ng`)
* How to identify runaway resource usage and isolate the responsible PID
* How to log metrics into files for repeatable, evidence-based troubleshooting
* How to apply basic tuning steps (priority changes, cleanup, monitoring automation)
* How to present performance findings in a professional report format

---

## 🌍 Why This Matters

Real-world performance troubleshooting is not only about “seeing high CPU” — it’s about:

* proving it with data,
* identifying the exact process,
* tracking behavior over time,
* documenting outcomes and recommendations.

This lab created an end-to-end workflow to do that reliably.

---

## ✅ Conclusion

In this lab, I performed real-time performance monitoring using `gnome-system-monitor` concepts and validated results using CLI tooling due to the terminal-only nature of the cloud environment.

I installed monitoring tools, generated CPU/memory load, simulated memory leaks, analyzed process trees and resource usage, and produced repeatable reports/logs for performance troubleshooting and basic optimization.

✅ Lab completed successfully on Ubuntu cloud lab environment.
