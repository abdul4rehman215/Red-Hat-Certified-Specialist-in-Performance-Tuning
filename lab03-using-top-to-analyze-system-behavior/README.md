# 🧪 Lab 03: Using `top` to Analyze System Behavior

> **Environment:** RHEL 9 (Cloud Lab Environment)  
> **User:** `root`  
> **Focus:** Real-time visibility with `top` → generate controlled workloads → analyze bottlenecks → manage priorities (`nice`/`renice`) → automation + cleanup

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Master the `top` command to monitor real-time system performance
- Analyze CPU utilization, memory consumption, and process behavior
- Identify resource-intensive processes and system bottlenecks
- Understand process priorities and their impact on system performance
- Modify process priorities using `nice` and `renice`
- Interpret system load averages and performance metrics
- Implement performance optimization strategies based on `top` analysis

---

## 🧰 Prerequisites

Before starting this lab, the following knowledge was required:

- Basic Linux command line skills
- Familiarity with Linux process concepts
- Basic system administration commands
- CPU and memory fundamentals
- Terminal access with admin privileges (or sudo)

---

## 🖥️ Lab Environment

This lab was performed on a **cloud-hosted Linux sandbox VM** with:

- RHEL/CentOS family system
- Pre-installed monitoring tools (`top`, `htop` available)
- Ability to install additional tools (`stress`)
- Root / sudo privileges

> Note: The original lab text mentions the provider name; this repo documents work completed in a **guided cloud lab environment (sandbox VM)**.

---

## 🗂️ Repository Structure

```text
lab03-using-top-to-analyze-system-behavior/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── resource_test.sh
    ├── system_monitor.sh
    ├── priority_manager.sh
    ├── performance_test.sh
    ├── top_monitor.sh
    └── monitoring_best_practices.sh
````

---

## ✅ Task Overview (What I Did)

### ✅ Task 1: Use `top` to monitor CPU, memory, and process behavior

* Launched `top` and reviewed:

  * header: uptime, load average, tasks, CPU breakdown, memory + swap
  * process table: PID, user, priority, nice, memory columns, CPU%
* Practiced essential interactive controls:

  * `h` help, `1` per-core view, `m` memory view toggle, `f` field management, `q` quit
* Validated sorting and filtering workflows:

  * `P` sort by CPU
  * `M` sort by memory
  * `u` filter by user (root)

### ✅ Task 1.3: Create CPU-intensive workload and observe behavior in `top`

* Verified `stress` was not installed, attempted `yum` (not available on RHEL 9), then installed via `dnf`
* Created controlled CPU load:

  * `stress --cpu 4 --timeout 300s &`
* Observed in `top`:

  * CPU utilization near saturation (~95% user CPU)
  * load average rising above CPU core count
  * stress processes appearing at top of the list

### ✅ Task 1.4: Create memory-intensive workload and observe behavior in `top`

* Created memory stress:

  * `stress --vm 2 --vm-bytes 512M --timeout 300s &`
* Observed in `top` (sorted by memory):

  * available memory dropping significantly
  * stress processes showing high `RES` and `%MEM`
  * still no swap usage (swap remained free)

### ✅ Task 2: Identify resource hogs and inefficiencies

* Created a workload simulation script (`resource_test.sh`) to generate:

  * CPU hog (looping compute via `bc`)
  * Memory hog (Python allocation loop with progress prints)
  * I/O hog (`dd` + repeated reads)
* Ran each workload in background and captured PIDs
* Observed in `top`:

  * CPU hog at ~99% CPU
  * memory hog using significant resident memory (~10%+)
  * I/O task showing state `D` (uninterruptible sleep) during disk operations

### ✅ Task 2.2: Use interactive top features for deeper analysis

* Used interactive controls for operational workflows:

  * filter by user (`u`)
  * color highlighting (`z`) and highlight sort column (`x`)
  * locate a process (`L`) and search for `python3`

### ✅ Task 2.3: Analyze system inefficiencies with a lightweight report script

* Built `system_monitor.sh` to print:

  * date, CPU cores, load average
  * memory summary
  * top CPU and memory processes
  * disk usage
  * simple network connection count using `netstat`
* Handled the realistic case where `netstat` may be missing (install `net-tools` if needed)

### ✅ Task 3: Modify process priorities using `nice` and `renice`

* Reviewed nice range and priority behavior:

  * `-20` (highest priority) → `+19` (lowest priority)
* Checked current nice values using `ps`
* Started multiple CPU workloads with different priorities:

  * low priority: `nice -n 19 ...`
  * high priority: `sudo nice -n -10 ...`
  * normal priority: default
* Verified impact:

  * higher priority received higher CPU share
  * lower priority received reduced CPU allocation
* Updated priorities of running processes:

  * `renice 15 <pid>` (lower priority)
  * `sudo renice -5 <pid>` (higher priority)

### ✅ Advanced monitoring: save `top` configuration + automate collection

* Customized top display fields and saved configuration using `W` (saved to `~/.toprc`)
* Built `top_monitor.sh` to:

  * capture `top -b` output for a fixed duration
  * parse and summarize:

    * load average trends
    * top CPU consumers
    * memory usage patterns

### ✅ Best practices and lab cleanup

* Created `monitoring_best_practices.sh` that generates:

  * `/tmp/system_check.sh` for periodic logging
  * `/tmp/resource_alert.sh` for simple threshold alerts
* Cleaned up:

  * killed background workloads (`resource_test`, `stress`)
  * removed lab scripts + temporary files

---

## 📌 Key Observations from This Lab

* Load average rose sharply during CPU stress (example: **3.85** on a 2-core VM)
* Sorting in `top` (`P` / `M`) quickly identifies CPU or memory hogs
* Memory stress reduced available memory significantly but swap remained unused (healthy state)
* I/O operations can show processes in `D` state during heavy disk activity
* Process priority strongly affects CPU time allocation when the system is saturated

---

## ✅ Result

* Successfully installed and used tooling to simulate real bottlenecks:

  * CPU stress and memory stress via `stress`
  * multi-type workloads via custom `resource_test.sh`
* Used `top` for real-time investigation:

  * sorting, filtering, locating processes, and saving configuration
* Practiced priority management:

  * started processes with `nice`
  * modified active processes with `renice`
* Built automation scripts to capture and summarize system behavior
* Completed cleanup to ensure the environment was returned to normal state

---

## 🧠 What I Learned

* `top` is not just a viewer — it’s an investigation tool:

  * identify bottlenecks fast
  * validate if a process is CPU-bound vs memory-bound vs blocked (I/O)
* Load average must be interpreted relative to CPU cores and `%iowait`
* Process priorities matter most when the system is under contention
* Automating monitoring (even simple scripts) turns “observations” into repeatable evidence

---

## 🌍 Why This Matters

In enterprise environments, performance incidents often look like:

* “server is slow” / “application timing out”
* intermittent spikes under load
* background tasks consuming resources unexpectedly

Knowing how to **observe, identify, and control** resource-heavy workloads using `top`, `nice`, and `renice` is essential for:

* performance tuning
* incident triage
* stability under peak load

---

## 🏁 Conclusion

This lab delivered a complete workflow:

✅ Observe (`top`) → ✅ Induce workload → ✅ Identify bottleneck → ✅ Adjust priorities → ✅ Automate monitoring → ✅ Cleanup
