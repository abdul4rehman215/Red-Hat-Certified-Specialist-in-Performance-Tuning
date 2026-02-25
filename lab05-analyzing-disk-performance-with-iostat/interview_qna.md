# 🎤 Interview Q&A — Lab 05: Analyzing Disk Performance with `iostat`

> This Q&A is based on the hands-on workflow from the lab: using `iostat` for disk performance monitoring, generating synthetic workloads, detecting bottlenecks, testing multiple I/O schedulers, persisting changes via udev rules, and validating improvements.

---

## 1) What is `iostat` and what package provides it on RHEL?
`iostat` is a performance monitoring tool used to report CPU statistics and I/O statistics for block devices.  
On RHEL, it comes from the **sysstat** package.

---

## 2) What is the difference between `iostat` and `iostat -x`?
- `iostat` provides **high-level** CPU + device throughput stats (e.g., TPS and KB/s).
- `iostat -x` provides **extended stats** needed for bottleneck analysis, such as:
  - latency metrics (`await`, `r_await`, `w_await`)
  - queue size (`aqu-sz`)
  - utilization (`%util`)

---

## 3) What does `%util` indicate and what is a common “red flag” threshold?
`%util` is the percentage of time the device is busy handling I/O requests.  
A common red-flag threshold is **> 80%** consistently, suggesting potential saturation (device bottleneck).

---

## 4) What does `await` mean and why does it matter?
`await` is the average time (in milliseconds) that I/O requests spend **waiting in queue + being serviced**.  
High `await` typically means higher latency and slower application response.

---

## 5) What do `r/s`, `w/s`, `rkB/s`, and `wkB/s` show?
They show the **rate of operations and throughput**:
- `r/s`: read operations per second
- `w/s`: write operations per second
- `rkB/s`: kilobytes read per second
- `wkB/s`: kilobytes written per second  
These help you understand workload type (read-heavy vs write-heavy) and throughput.

---

## 6) What does `aqu-sz` indicate?
`aqu-sz` is the **average queue size** (average number of I/O requests waiting).  
If queue size stays high (example threshold > 2 for small systems), it may indicate the disk is struggling to keep up.

---

## 7) How do you identify a disk bottleneck using iostat?
Look for a combination of:
- high `%util` (saturation)
- high `await`/`r_await`/`w_await` (latency)
- elevated `aqu-sz` (queue buildup)
If these persist during normal workload, storage is a likely bottleneck.

---

## 8) Why did `iostat -x 2 /dev/sda /dev/sdb` fail in this lab?
Because the VM used **NVMe devices** (e.g., `nvme0n1`, `nvme1n1`) instead of traditional `sda/sdb`.  
Correct approach: use `lsblk` to identify real device names.

---

## 9) Why do we run `iostat -x 2` during synthetic workloads?
Because it samples performance **during load**, revealing:
- how utilization changes
- whether latency rises
- whether queues build up  
This is more meaningful than idle measurements.

---

## 10) What is an I/O scheduler and why does it matter?
The I/O scheduler controls how the kernel **orders and dispatches I/O requests** to block devices.  
Different schedulers optimize for different goals:
- throughput
- latency consistency
- fairness between processes

---

## 11) What schedulers were available on this NVMe system and which were tested?
Available schedulers shown in `/sys/block/nvme0n1/queue/scheduler`:
- `mq-deadline`
- `none`
- `kyber`
- `bfq`

All were tested using the scheduler performance test script.

---

## 12) Why might `none` or `kyber` be preferred on NVMe/SSD?
- `none`: minimal scheduling overhead; useful when hardware handles queueing efficiently.
- `kyber`: targets consistent latency; often a good fit for latency-sensitive services (databases, interactive workloads).

---

## 13) How do you make scheduler changes persistent across reboots?
A common approach is to use **udev rules** (e.g., `/etc/udev/rules.d/60-io-schedulers.rules`) to apply scheduler settings whenever devices are added/changed, then reload udev rules.

---

## 14) Why does `sudo echo kyber > /sys/block/.../scheduler` often fail?
Because shell redirection (`>`) happens **before** `sudo` elevates privileges.  
Correct pattern:
```bash
echo kyber | sudo tee /sys/block/nvme0n1/queue/scheduler
````

---

## 15) What is the value of baseline testing (idle vs loaded) before tuning?

Baselines provide a reference point to:

* compare before/after tuning results
* detect regressions later
* establish performance expectations (SLA/SLO thresholds)
  Without baselines, “improvement” is guesswork.

---
