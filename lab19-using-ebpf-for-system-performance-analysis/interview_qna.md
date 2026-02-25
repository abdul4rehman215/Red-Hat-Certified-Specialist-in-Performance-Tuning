# 🎤 Interview Q&A — Lab 19: Using eBPF for System Performance Analysis

> This Q&A set is for revision and interview preparation based strictly on the work performed in **Lab 19**.

---

## 1) What is eBPF and why is it useful for performance analysis?
eBPF (Extended Berkeley Packet Filter) is a kernel technology that allows safe, efficient programs to run in the Linux kernel for tracing, monitoring, and analytics. It’s useful because it provides **low-overhead kernel visibility** into system calls, networking, file operations, and more—often without modifying applications.

---

## 2) What minimum kernel version is generally required for eBPF, and what kernel did you use?
eBPF requires kernel **4.1+** (with many features improving significantly in later kernels). In this lab, the kernel was:
- `5.14.0-4xx.el9.x86_64`

---

## 3) How did you confirm the system was ready for eBPF tracing?
I verified:
- tracing filesystem exists: `/sys/kernel/debug/tracing/`
- `bpffs` is mounted:
  - `mount | grep bpf` showed `bpffs on /sys/fs/bpf`
- debugfs is mounted:
  - `mount | grep debugfs`

---

## 4) What are BCC tools and why did you install them?
BCC (BPF Compiler Collection) provides ready-to-use eBPF tracing tools like `syscount.py` and `gethostlatency.py`. They simplify using eBPF for troubleshooting without writing kernel probes manually.

---

## 5) What does `syscount.py` do?
`syscount.py` traces and counts **system calls** in real time. It can run:
- system-wide
- for a specific PID (`-p`)
- grouped by process/command (`-P`)
- filtered to specific syscalls (`-e`)
- printed as periodic intervals (`-i`)

---

## 6) How did you trace syscalls for a specific process?
I created a simple target process:
```bash
sleep 20 &
TARGET_PID=$!
````

Then traced syscalls for that PID:

```bash
sudo /usr/share/bcc/tools/syscount.py -p $TARGET_PID -d 5
```

---

## 7) What syscall pattern did you observe when tracing the `sleep` process?

The `sleep` process primarily produced timing-related syscalls:

* `nanosleep`
* `clock_nanosleep`

---

## 8) How did you generate a realistic workload for syscall monitoring?

I created a script that performed:

* file create/read/delete loops
* ping activity
* process listing and `/proc` listing

This produced a syscall-heavy I/O pattern observed by `syscount.py`.

---

## 9) What did your workload-based syscount results show?

During workload capture, the most frequent syscalls were:

* `read`, `write`, `openat`, `close`
* also metadata-related calls like `newfstatat` and `statx`
  This indicates I/O-heavy activity.

---

## 10) Why did you use `syscount.py -P`?

`-P` groups syscall counts by **process name (COMM)**, which helps identify which processes are generating which syscalls—for example, `bash`, `sshd`, `dnf`.

---

## 11) What does `gethostlatency.py` measure?

`gethostlatency.py` traces latency for DNS resolution-related functions:

* `getaddrinfo()`
* `gethostbyname()`

It prints per-event latency in milliseconds, along with PID, command, and hostname.

---

## 12) How did you generate DNS resolution activity for `gethostlatency.py`?

I created a script that repeatedly ran:

* `nslookup`
* `host`
* `dig`
  against multiple domains (and tested different DNS servers).

---

## 13) What did you do to capture DNS latency output for offline analysis?

I ran `gethostlatency.py` with timestamps and redirected output:

```bash
sudo /usr/share/bcc/tools/gethostlatency.py -t > dns_latency.log &
```

Then stopped it after tests using:

```bash
sudo pkill -f gethostlatency.py
```

---

## 14) What automation did you build to monitor multiple signals at once?

I created `comprehensive_monitor.sh` which ran:

* `syscount.py` (detailed)
* `gethostlatency.py` (timestamped)
* optional `opensnoop.py` (file opens)
* optional `execsnoop.py` (process executions)
  while generating workload and saving outputs into a timestamped folder.

---

## 15) What did your final report generator produce and why is it useful?

`generate_performance_report.py` produced:

* `performance_report.json`
* `performance_report.txt`

It summarized syscall and DNS data, detected issues (e.g., **high I/O syscall activity**), and generated practical recommendations. This turns raw eBPF output into actionable performance insights.

---
