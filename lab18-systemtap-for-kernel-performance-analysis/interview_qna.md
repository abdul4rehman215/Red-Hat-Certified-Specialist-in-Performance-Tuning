# 🎤 Interview Q&A — Lab 18: SystemTap for Kernel Performance Analysis

> This Q&A set is for revision and interview preparation based strictly on the work performed in **Lab 18**.

---

## 1) What is SystemTap and why is it useful for performance analysis?
SystemTap is a Linux tracing and probing tool that allows you to instrument the kernel and user space to observe events such as system calls, I/O activity, scheduling, memory events, and kernel function execution. It provides deep visibility into performance bottlenecks that normal user-space tools may not explain.

---

## 2) How did you verify SystemTap was installed on the system?
I verified installation by checking installed RPMs and the SystemTap version:
- `rpm -qa | grep systemtap`
- `stap --version`

---

## 3) Why are kernel debugging symbols (debuginfo) important for SystemTap?
Kernel debuginfo provides symbol and type information SystemTap needs to resolve kernel functions and structures. Without it, kernel probes often fail or can’t attach reliably. In the lab, I confirmed debuginfo presence by checking:
- `/usr/lib/debug/lib/modules/$(uname -r)/` and verifying `vmlinux` exists.

---

## 4) What quick test did you run to confirm SystemTap could execute probes?
I ran a minimal inline script:
```bash
sudo stap -e 'probe begin { println("SystemTap is working!"); exit() }'
````

It printed "SystemTap is working!", confirming compilation and execution.

---

## 5) What did your `hello_systemtap.stp` script demonstrate?

It demonstrated:

* `probe begin` and `probe end`
* access to kernel version (`kernel_v`)
* access to time functions (`ctime(gettimeofday_s())`)
* timer-based probing (`probe timer.s(5)`) to print a message and exit

---

## 6) How did the basic I/O monitoring script (`io_monitor.stp`) measure I/O activity?

It attached to:

* `syscall.read` and `syscall.read.return`
* `syscall.write` and `syscall.write.return`
* `syscall.open`

It counted reads/writes per process and accumulated read/write bytes using `$return` from syscall return probes. It printed statistics every 10 seconds.

---

## 7) What is the purpose of using syscall return probes like `syscall.read.return`?

Return probes provide access to the syscall result, especially:

* `$return` which contains bytes read/written or negative error codes.
  This is necessary to measure how many bytes were actually transferred and to detect failures.

---

## 8) How did your latency script (`io_latency.stp`) calculate syscall latency?

It stored a start timestamp for each thread (`tid()`) when a syscall began, then on return computed:

* `latency = gettimeofday_us() - start_time`

It collected latency values into aggregates and printed statistics and histograms every 15 seconds.

---

## 9) What did the histogram output in the latency script represent?

It summarized the distribution of syscall latencies (microseconds) across the interval, showing how many read/write events fell into each bucket. In the lab output, most events were in the lowest bucket, indicating generally fast I/O.

---

## 10) What did the comprehensive syscall tracer (`syscall_tracer.stp`) measure?

It measured:

* syscall count per syscall name
* total time per syscall
* average time per syscall
* syscall errors (`$return < 0`)
  It also tracked syscall activity per process and printed periodic summaries.

---

## 11) How did you generate workload activity to trigger I/O and syscalls during tracing?

I used standard commands that produce syscalls:

* I/O generation: `dd`, `cp`, `find | xargs cat`, file remove
* syscall activity: `ls -la /etc/`, `find /var/log`, `ps aux`, `netstat`, `df -h`

---

## 12) What was the purpose of the process-specific monitor (`process_monitor.stp`)?

It focused monitoring on a set of target processes (e.g., `sshd`) and captured:

* file opens (`open/openat`)
* network activity (`socket`, `connect`, `bind`)
* memory calls (`mmap`, `brk`)
  This produces higher-signal output than tracing everything system-wide.

---

## 13) How did you detect I/O bottlenecks during stress testing?

Using `io_bottleneck_detector.stp`, I tracked:

* I/O queue depth
* slow I/O operations (threshold > 50ms)
* processes blocked on I/O
* read/write operations via VFS probes
  Then I ran the load generator while the detector printed interval reports.

---

## 14) What did your performance monitor (`performance_monitor.stp`) report during mixed load?

It reported:

* CPU sample distribution per core (via `timer.profile`)
* context switches per interval (warning if high)
* top CPU-consuming processes (`yes`, `stap`, `python3`)
* page faults by process (python3 was flagged)
* memory allocations via `mmap` return probe

---

## 15) Why build a real-time dashboard script (`realtime_dashboard.stp`)?

It created a compact repeated snapshot every 5 seconds that can be logged and tailed like a live dashboard, showing:

* CPU sample distribution
* context switches
* top syscalls
* read/write bytes
  This is useful for real-time troubleshooting while reproducing performance issues.

---
