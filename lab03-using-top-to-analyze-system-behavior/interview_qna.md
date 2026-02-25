# 🎤 Interview Q&A — Lab 03: Using `top` to Analyze System Behavior

> This Q&A is based on the exact workflow performed in the lab: using `top` interactively, generating CPU/memory/I/O workloads, identifying bottlenecks, and tuning process priority using `nice` and `renice`.

---

## 1) What is `top` used for in Linux?
`top` provides a real-time view of system behavior, including CPU usage, memory usage, load average, and a live process list. It's commonly used for quick troubleshooting of performance issues and identifying resource-intensive processes.

---

## 2) What does the load average in `top` represent?
Load average represents the average number of runnable and uninterruptible tasks over time (1, 5, 15 minutes).  
A common interpretation is to compare it to the number of CPU cores:
- Load ≈ cores → system is near full CPU capacity (or heavy I/O wait)
- Load >> cores → system is saturated or blocked (CPU contention or I/O pressure)

---

## 3) How do you interpret the CPU line in `top` (`%Cpu(s)` values)?
Key fields include:
- `us`: CPU time in user space
- `sy`: CPU time in kernel space
- `ni`: CPU time for niced processes
- `id`: idle time
- `wa`: I/O wait time
- `hi/si`: hardware/software interrupts
- `st`: stolen time (virtualization)

High `us` suggests CPU-bound workloads. High `wa` suggests disk or I/O bottlenecks.

---

## 4) What do `VIRT`, `RES`, and `SHR` mean in `top`?
- `VIRT`: total virtual memory used by a process (includes swapped, mapped files, etc.)
- `RES`: resident memory (actual RAM used by process)
- `SHR`: shared memory used (shared libraries and shared pages)

For memory pressure analysis, `RES` and `%MEM` are usually more meaningful.

---

## 5) How do you sort processes by CPU or memory usage in `top`?
- Press `P` to sort by CPU usage
- Press `M` to sort by memory usage

This quickly highlights CPU hogs and memory hogs.

---

## 6) What does the process state `D` mean in `top`?
`D` means **uninterruptible sleep**, often due to waiting on I/O (disk/network).  
If many processes are stuck in `D` state and `wa` is high, it can indicate storage latency or I/O bottlenecks.

---

## 7) How did you simulate CPU stress in this lab?
Using the `stress` tool:
```bash
stress --cpu 4 --timeout 300s &
````

This created CPU-heavy worker processes visible in `top` with high `%CPU`.

---

## 8) How did you simulate memory stress in this lab?

Using `stress`:

```bash
stress --vm 2 --vm-bytes 512M --timeout 300s &
```

This allocated memory and increased `RES`/`%MEM`, decreasing available memory.

---

## 9) What is the nice value in Linux, and what range does it have?

Nice value controls scheduling priority:

* Range: **-20** (highest priority) to **+19** (lowest priority)
* Default: `0`
  Lower nice values get CPU time earlier under contention.

---

## 10) What is the difference between `nice` and `renice`?

* `nice` starts a new process with a specific priority (nice value).
* `renice` changes the priority of an already running process.

---

## 11) Why does changing to a negative nice value require root privileges?

Negative nice values increase scheduling priority (more CPU access), which can impact system fairness and stability.
Linux restricts this to privileged users to prevent abuse.

---

## 12) What evidence in the lab showed that priority affects CPU allocation?

When running multiple CPU workloads with different nice values, CPU usage differed:

* Higher priority process (nice `-10`) received significantly higher `%CPU`
* Low priority process (nice `19`) received less `%CPU`

Example verification command used:

```bash
ps -o pid,ni,%cpu,comm -p <pids>
```

---

## 13) What is the purpose of saving `top` configuration with `W`?

Pressing `W` saves the current `top` layout (fields, sorting, display options) to `~/.toprc`.
This makes future performance investigations faster and consistent across sessions.

---

## 14) Why is it useful to automate `top` capture with a script?

Automation provides:

* repeatable evidence for troubleshooting
* logs you can compare over time
* visibility into short spikes that might be missed interactively
  In this lab, `top_monitor.sh` captured and summarized load averages, top CPU consumers, and memory patterns.

---

## 15) What are best practices when using `top` in real production incidents?

* Identify whether bottleneck is CPU-bound (`us` high), memory-bound (`RES/%MEM` high), or I/O-bound (`wa` high, many `D` tasks)
* Sort by CPU/memory (`P`, `M`)
* Locate suspect processes (`L`)
* Avoid killing critical services blindly—validate with `ps`, logs, and workload context
* Use `nice/renice` to reduce impact of background tasks instead of terminating them
* Capture output (`top -b`) for documentation and RCA

---
