# 🎤 Interview Q&A — Lab 17: Analyzing Application Performance with `ps`

> This Q&A set is for revision and interview preparation based strictly on the work performed in **Lab 17**.

---

## 1) What does `ps aux` show, and why is it commonly used for troubleshooting?
`ps aux` shows **all running processes** with detailed fields including user, PID, CPU usage, memory usage, process state, start time, and command. It's commonly used because it quickly reveals resource-heavy or abnormal processes.

---

## 2) Explain the key columns in `ps aux` output: `%CPU`, `%MEM`, `VSZ`, and `RSS`.
- **%CPU:** CPU usage percentage consumed by the process.
- **%MEM:** Percentage of physical RAM used by the process.
- **VSZ:** Virtual memory size (address space) in KB.
- **RSS:** Resident Set Size, actual physical memory currently used in KB.

---

## 3) What’s the difference between `ps aux` and `ps ux`?
- `ps aux` shows processes for **all users**.
- `ps ux` shows processes for the **current user** (in this lab, `centos`) with user-friendly formatting.

---

## 4) Why did you use `ps auxf` in this lab?
`ps auxf` shows processes in a tree-like format, revealing parent-child relationships. This helps trace how a process started (e.g., sshd → bash → scripts) and identify orphaned or suspicious process chains.

---

## 5) What does `ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu` help you analyze?
It outputs processes in a custom format including PID/PPID and resource usage, then sorts by highest CPU usage. This quickly pinpoints CPU bottlenecks and shows process hierarchy through PPID.

---

## 6) What does `ps -eLf` show and when is it useful?
`ps -eLf` shows **threads** (LWP) for processes along with thread counts. It’s useful when diagnosing multi-threaded applications or when a process uses high CPU due to many threads.

---

## 7) How did you create CPU and memory workloads for analysis?
- CPU workload: a bash infinite loop running repeated math operations via `bc`.
- Memory workload: a Python script allocating 1MB blocks gradually and reporting progress.

---

## 8) How did you identify the top CPU and top memory processes in real time?
Used `watch` with sorted `ps`:
- CPU:
  ```bash
  watch -n 2 'ps aux --sort=-%cpu | head -20'
````

* Memory:

  ```bash
  watch -n 2 'ps aux --sort=-%mem | head -20'
  ```

---

## 9) What does the `STAT` column represent, and which states did you focus on?

`STAT` indicates process state and flags. In this lab, I focused on:

* **R:** running/runnable (CPU consumer)
* **S:** sleeping (waiting)
* **Z:** zombie (terminated but not reaped)
* **D:** uninterruptible sleep (often I/O wait related)

---

## 10) Why did you inspect a specific PID using `ps -p <PID> -o ...`?

To drill into a particular process and confirm:

* CPU and memory usage (`pcpu`, `pmem`)
* runtime behavior (`etime`, `time`)
* state and waiting channel (`stat`, `wchan`)

This is essential when investigating one suspected bottleneck process.

---

## 11) What is “nice” value (NI), and how does `renice` help optimization?

The **nice value (NI)** affects scheduling priority:

* Lower NI → higher priority
* Higher NI → lower priority

`renice` allows adjusting a running process priority. In the lab, the CPU-intensive process was deprioritized with NI=10 to reduce system impact.

---

## 12) Why is safe termination recommended instead of immediately using `kill -9`?

Because `kill -9` (SIGKILL) forces termination without cleanup. Safe termination uses SIGTERM first, allowing an application to release resources, write state, and exit cleanly.

---

## 13) What steps did your safe termination script follow?

It:

1. Validated PID exists
2. Printed process details before killing
3. Sent TERM by default (or another signal if provided)
4. Verified whether the process terminated
5. Recommended SIGKILL only if needed

---

## 14) What did the `identify_issues.sh` script detect?

It flagged:

* processes with CPU usage > 50%
* processes with memory usage > 10%
* long-running processes (based on CPU time)
* processes with high thread counts (based on `ps -eLf`)

---

## 15) Why create a baseline (`system_baseline_YYYYMMDD.txt`) in performance work?

Baselines capture a reference state (load, memory usage, process counts, top consumers). They help compare future changes, confirm improvements, and support incident triage or performance regression analysis.

---
