# 🧪 Lab 18: SystemTap for Kernel Performance Analysis

> **Track:** Red Hat Certified Specialist in Performance Tuning (Exam Labs)  
> **Environment:** CentOS/RHEL 8/9 (Cloud Lab Environment)  
> **Shell:** `-bash-4.2$`  
> **User:** `centos` (sudo available)

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Install and verify SystemTap on a Linux system
- Confirm kernel debuginfo/symbol availability for symbol-based tracing
- Write SystemTap scripts to trace I/O operations and system calls
- Monitor kernel events and identify performance bottlenecks
- Create custom probes for kernel/application debugging
- Interpret SystemTap output (statistics, slow events, histograms)
- Use SystemTap for real-time monitoring and troubleshooting workflows

---

## ✅ Prerequisites

- Linux system administration fundamentals
- Comfort with CLI and basic scripting
- Basic understanding of syscalls and kernel concepts
- Understanding of I/O operations and file systems
- Familiarity with performance monitoring concepts

---

## ☁️ Lab Environment

| Component | Details |
|---|---|
| OS | CentOS/RHEL 8/9 |
| Tools | `systemtap (stap)`, `rpm`, `dnf`, standard GNU utilities |
| Kernel symbols | `/usr/lib/debug/lib/modules/$(uname -r)/` contains `vmlinux` |
| Workloads used | `dd`, `cp`, `find`, `xargs`, `yes`, Python memory allocation loop |
| Output viewing | `tail -f`, background stap processes, log file (`/tmp/dashboard.log`) |

---

## 🗂️ Repository Structure

```text
lab18-systemtap-for-kernel-performance-analysis/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── hello_systemtap.stp
    ├── io_monitor.stp
    ├── io_latency.stp
    ├── syscall_tracer.stp
    ├── process_monitor.stp
    ├── io_bottleneck_detector.stp
    ├── performance_monitor.stp
    ├── kernel_event_tracer.stp
    ├── realtime_dashboard.stp
    └── generate_io_load.sh
````

---

## 🧩 Lab Tasks Overview

### ✅ Task 1: SystemTap Installation & Setup

In this section, I:

* Verified SystemTap is installed via RPM queries and confirmed the version
* Verified kernel debuginfo availability by checking the debug modules path
* Confirmed SystemTap can compile and run a simple probe (begin probe test)
* Re-verified required build/debug packages (`systemtap-runtime`, `kernel-debuginfo`, `kernel-devel`, `gcc`) were present
* Created and executed a baseline SystemTap script (`hello_systemtap.stp`) to confirm:

  * kernel version visibility
  * time functions and probes working
  * timer-based probe execution

---

### 📁 Task 2: Writing SystemTap Scripts for I/O Tracing

In this section, I created two I/O-focused scripts:

* **Basic I/O monitoring** (`io_monitor.stp`)

  * Counts read/write syscalls per process
  * Tracks bytes read/written
  * Logs file open events (`OPEN:` lines)
  * Prints summary every 10 seconds and resets counters for interval-based analysis

* **I/O latency tracking** (`io_latency.stp`)

  * Tracks per-thread syscall start time
  * Calculates latency in microseconds
  * Stores latency distributions and prints histograms
  * Logs slow operations (threshold > 1ms)

Then I tested these scripts by generating real I/O using:

* `dd` to create files
* `cp` to copy files
* `find | xargs cat` to trigger many open/read operations

---

### 🧾 Task 3: System Call Tracing & Analysis

In this section, I wrote syscall tracing scripts for broader visibility:

* **Comprehensive syscall tracer** (`syscall_tracer.stp`)

  * Tracks syscall count per syscall name
  * Tracks cumulative syscall time and average cost
  * Detects syscall errors (`return < 0`)
  * Logs slow syscalls (> 10ms)
  * Prints periodic summaries and top syscall activity per process

* **Process-specific monitor** (`process_monitor.stp`)

  * Watches selected target services (e.g., `sshd`)
  * Tracks file opens and network-related syscalls (socket/connect/bind)
  * Flags memory-related activity (`mmap`, `brk`)
  * Prints periodic summaries and resets counters

These were validated by generating activity via:

* listing directories
* searching logs
* checking network listeners
* validating running service state (sshd)

---

### 🧱 Task 4: Performance Analysis During I/O Bottlenecks

In this section, I simulated I/O stress and traced bottleneck signals:

* **I/O bottleneck detector** (`io_bottleneck_detector.stp`)

  * Tracks queue depth, I/O wait, blocked processes
  * Logs slow operations over threshold
  * Reports disk queue depth and top I/O activity per interval

* **Mixed CPU + memory + I/O performance monitor** (`performance_monitor.stp`)

  * Tracks CPU sampling per core, context switches
  * Tracks page faults and memory allocations (`mmap`)
  * Reports high context switch warnings and heavy processes

* **I/O load generator** (`generate_io_load.sh`)

  * Spawns multiple workers generating random and pseudo-random I/O patterns
  * Adds filesystem stress using library copies from `/usr`
  * Used as repeatable stress harness during stap monitoring

---

### 🧠 Task 5: Advanced SystemTap Techniques

In this section, I built advanced kernel-level tracing:

* **Kernel event tracer** (`kernel_event_tracer.stp`)

  * Tracks kernel function probes for process create/exit
  * Tracks interrupts and simplified lock contention counters
  * Tracks memory allocation/free events and basic network TX/RX events
  * Prints periodic structured summaries and resets counters

* **Real-time “dashboard” view** (`realtime_dashboard.stp`)

  * Outputs compact metrics every 5 seconds:

    * CPU sample distribution per core
    * context switches count
    * top syscalls
    * I/O bytes read/write
  * Runs in background and logs to `/tmp/dashboard.log`
  * Viewed live using `tail -f` to simulate a dashboard workflow

> Note: The lab text included an incomplete dashboard section; the provided workflow was completed and validated using log output and a live tail view.

---

## ✅ Verification Summary

This lab validates SystemTap functionality by demonstrating:

* Successful execution of begin/timer probes
* Kernel symbol access via debuginfo presence (vmlinux available)
* Real-time syscall and I/O tracing with interval reporting
* Latency measurement and histogram output for reads/writes
* Identification of busy syscalls and syscall-heavy processes
* Bottleneck detection during induced I/O stress
* Kernel event tracing via kernel.function probes
* Live dashboard-style monitoring via timed summary output into a log

---

## 📌 Result

✅ SystemTap was verified as operational and used to build and run multiple custom tracing scripts, including I/O monitors, syscall tracers, bottleneck detectors, kernel event probes, and a real-time dashboard workflow. Outputs demonstrate meaningful kernel-level visibility beyond normal user-space tools.

---

## 💡 Why This Matters

SystemTap enables deep observability into **kernel and syscall behavior** that typical tools may not fully explain. It’s especially valuable when:

* applications “feel slow” but CPU looks normal
* intermittent I/O latency spikes occur
* kernel scheduling or paging triggers bottlenecks
* root-cause requires syscall-level timing + evidence
* you need real-time tracing while reproducing performance issues

---

## 🌍 Real-World Applications

* Diagnosing slow file servers and filesystem hot paths
* Identifying syscall bottlenecks in high-throughput services
* Pinpointing I/O wait and blocked processes during incident response
* Detecting memory allocation patterns and excessive page faults
* Building lightweight dashboards for short-term live debugging sessions

---

## 🧾 Conclusion

In this lab, I successfully:

* Verified SystemTap installation and kernel debuginfo readiness
* Built and executed multiple SystemTap scripts for:

  * I/O counts and bytes
  * I/O latency distributions
  * system call activity, slow syscalls, and errors
  * process-specific file/network/memory syscall activity
  * I/O bottleneck detection during stress
  * CPU/memory monitoring during mixed workloads
  * kernel event tracing for process/interrupt/memory/lock signals
  * real-time dashboard output and log viewing
* Demonstrated end-to-end kernel-level performance analysis workflows using controlled load generation and repeatable scripts

✅ **Lab 18 completed successfully — SystemTap used for real-time kernel/syscall tracing, bottleneck detection, and live dashboard monitoring.**
