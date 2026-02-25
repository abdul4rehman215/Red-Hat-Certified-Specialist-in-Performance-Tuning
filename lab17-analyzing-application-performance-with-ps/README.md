# 🧪 Lab 17: Analyzing Application Performance with `ps`

> **Track:** Red Hat Certified Specialist in Performance Tuning (Exam Labs)  
> **Environment:** CentOS/RHEL 8 (Cloud Lab Environment)  
> **Shell:** `-bash-4.2$`  
> **User:** `centos` (sudo available)

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Master the `ps` command and its key options for process monitoring
- Analyze running applications and interpret CPU/memory consumption patterns
- Identify performance bottlenecks and resource-intensive processes
- Apply optimization strategies using priority control (nice/renice)
- Terminate inefficient applications safely using correct signals
- Interpret process statistics, states, and system utilization indicators
- Automate process analysis into reusable scripts and reports

---

## ✅ Prerequisites

- Basic Linux CLI knowledge
- Familiarity with file navigation and common commands
- Understanding of processes (PID, PPID, states, threads)
- Awareness of system resources (CPU, memory, I/O)
- Basic editor skills (`nano`, `vim`)

---

## ☁️ Lab Environment

| Component | Details |
|---|---|
| OS | CentOS/RHEL 8 |
| Access | Cloud VM (sudo available) |
| Tools Used | `ps`, `watch`, `awk`, `kill`, `nice`, `renice`, `timeout`, `dd`, `iostat`, `pmap`, `free`, `uptime` |
| Workloads Created | CPU-intensive bash loop, memory allocation python script |

---

## 🗂️ Repository Structure

```text
lab17-analyzing-application-performance-with-ps/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── cpu_intensive.sh
    ├── memory_intensive.py
    ├── process_monitor.sh
    ├── track_process.sh
    ├── identify_issues.sh
    ├── safe_terminate.sh
    ├── process_manager.sh
    ├── resource_tracker.sh
    ├── analyze_logs.sh
    └── system_baseline.sh
````

---

## 🧩 Lab Tasks Overview

### 🧾 Task 1: Understanding and Using `ps` for Process Analysis

In this section, I practiced:

* Viewing processes with full details using `ps aux`
* Understanding column meanings like `%CPU`, `%MEM`, `VSZ`, `RSS`, `STAT`, `TIME`
* Displaying processes as a tree using `ps auxf`
* Filtering to the current user with `ps ux`
* Creating custom formatted process views with sorting:

  * by CPU usage (`--sort=-%cpu`)
  * with columns: PID, PPID, CMD, %MEM, %CPU

I also inspected thread-level output using:

* `ps -eLf` (thread count and LWP)

---

### 🧪 Task 2: Creating Sample Workloads for Performance Analysis

To simulate real bottlenecks, I created and ran:

* A CPU-intensive bash loop (continuous computation)
* A memory-intensive python script (allocates memory gradually)

Both processes were launched in the background and tracked using PIDs.

---

### 📊 Task 3: Resource Monitoring & Bottleneck Identification

I used `watch` + `ps` sorting to observe resource consumers in real time:

* Top CPU consumers (`ps aux --sort=-%cpu`)
* Top memory consumers (`ps aux --sort=-%mem`)

Then I automated analysis into scripts:

* A **process monitoring report** script (top CPU, top MEM, user counts, zombies, load average)
* A **tracking script** to record CPU/MEM/VSZ/RSS over time for a given PID
* A **performance issue identification** script to flag:

  * CPU > 50%
  * MEM > 10%
  * long CPU-time processes
  * high thread count processes

---

### ⚙️ Task 4: Optimization & Safe Termination

I applied optimization strategies:

* Checked nice values (NI) and adjusted priority using `renice`
* Started a low-priority workload using `nice -n`

Then I implemented safe process control:

* Built a safe termination helper that:

  * validates PID exists
  * prints process details before kill
  * sends TERM by default
  * suggests KILL only when required
  * confirms termination status

---

### 🧠 Task 5: Advanced Reporting & Baseline Creation

To create repeatable performance baselines:

* Built a **process manager tool** (argument-based utility) to:

  * show top consumers
  * filter by user
  * search by keyword
  * monitor continuously
  * generate a full report file

* Implemented long-term logging:

  * resource tracker script logs top CPU consumers every interval into `process_resources.log`
  * analyzer script finds:

    * max CPU events
    * max MEM events
    * most frequent high-resource commands
    * simple average summaries over time

* Created a **system baseline snapshot** script to store:

  * system info (kernel/cpu/memory)
  * process counts by state
  * top CPU/MEM processes
  * per-user process counts

---

## ✅ Verification Summary

The lab outputs validate:

* `ps` listing and sorting correctly identifies top CPU and memory consumers
* PID-specific inspection provides state/time usage visibility
* automated scripts generate reproducible reports and logs
* process termination procedures work safely (TERM first, KILL if needed)
* baseline artifacts are created for future comparison and auditing

---

## 📌 Result

✅ I successfully created controlled workload processes, analyzed them using `ps` (including sorting, formatting, and threads), generated automation scripts for monitoring/reporting, optimized process priorities, and safely terminated inefficient processes while preserving a documented performance baseline.

---

## 💡 Why This Matters

Process analysis is foundational for:

* identifying bottlenecks before users complain
* diagnosing system slowdowns and runaway workloads
* capacity planning and system baselining
* operational stability (safe termination + prioritization)
* performance tuning and certification readiness

---

## 🌍 Real-World Applications

* Finding CPU spikes caused by a misbehaving job or script
* Identifying memory hogs leading to OOM risk
* Monitoring suspicious or abnormal process behavior
* Automating reporting for daily ops or incident triage
* Establishing “before/after” baselines during tuning projects

---

## 🧾 Conclusion

In this lab, I:

* mastered `ps` views for processes, trees, sorting, and custom formatting
* created CPU + memory workloads to simulate real bottlenecks
* scripted monitoring, issue identification, and time-series tracking
* applied priority tuning using `nice`/`renice`
* implemented safe termination patterns using signals
* generated reports and baselines to support ongoing performance work

✅ **Lab 17 completed successfully — process analysis, monitoring automation, optimization, and safe control implemented.**

---

> Next file: **`commands.sh` (only commands executed, in order, no explanations)**
