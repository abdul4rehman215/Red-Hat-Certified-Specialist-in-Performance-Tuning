# 🧪 Lab 16: Kernel Module Parameter Tuning

> **Track:** Red Hat Certified Specialist in Performance Tuning (Exam Labs)  
> **Environment:** CentOS/RHEL 8/9 (Cloud Lab Environment)  
> **User Context:** `centos` user with `sudo` (temporary root where required)

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand kernel module parameters and how they impact system performance
- Identify and modify network-related kernel module parameters
- Adjust storage subsystem kernel module parameters
- Evaluate performance changes using monitoring tools (`top`, `iostat`, `vmstat`, `mpstat`, `ss`)
- Measure resource consumption before and after tuning adjustments
- Apply systematic tuning approaches for specific workloads (throughput vs latency)
- Document and validate performance changes
- Make tuning persistent using `sysctl.d` and `systemd` services

---

## ✅ Prerequisites

- Basic Linux administration knowledge
- CLI usage and text editor familiarity
- Understanding of networking and storage fundamentals
- Monitoring tool experience: `top`, `iostat`, `sar` (or equivalent), `vmstat`
- Root/sudo access to apply kernel tuning

---

## ☁️ Lab Environment

| Component | Details |
|---|---|
| OS | CentOS/RHEL 8/9 |
| Kernel | 5.14.0-4xx.el9.x86_64 |
| Network Driver | `virtio_net` |
| Storage Driver | `virtio_blk` |
| Primary Interface | `eth0` (MTU 9001) |
| Primary Disk | `/dev/sda` |
| Tools Used | `sysctl`, `ethtool`, `iperf3`, `netperf`, `fio`, `hdparm`, `iostat`, `vmstat`, `mpstat`, `iotop`, `ss` |

---

## 🗂️ Repository Structure

```text
lab16-kernel-module-parameter-tuning/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── network_test.sh
    ├── storage_test.sh
    ├── system_monitor.sh
    ├── compare_performance.sh
    └── validate_tuning.sh
````

---

## 🧩 Lab Tasks Overview

### 🌐 Task 1: Network Kernel Parameter Analysis & Tuning

In this section, I:

* Audited current network sysctl parameters and recorded baseline values
* Verified loaded network modules and inspected driver tunables using `modinfo`
* Installed required network test tooling (`iperf3`, `netperf`) and saved baseline stats
* Increased TCP buffer defaults and max limits (`rmem`, `wmem`)
* Increased backlog limits to handle traffic bursts (`netdev_max_backlog`)
* Enabled and applied modern congestion control (`bbr`)
* Tuned interface-level performance settings using `ethtool`:

  * ring buffer RX/TX increase
  * enabled offloads (`tso`, `gro`)
  * enabled RPS for receive queues (`rps_cpus`)

---

### 💾 Task 2: Storage Subsystem Parameter Analysis & Tuning

In this section, I:

* Audited current I/O scheduler settings per block device
* Checked baseline queue parameters (`read_ahead_kb`, `nr_requests`)
* Verified storage modules and supported tunables using `modinfo`
* Installed benchmarking tools (`fio`, `hdparm`)
* Captured baseline storage performance using `iostat`
* Tuned I/O scheduling and queueing:

  * ensured a latency-friendly scheduler (`mq-deadline`)
  * increased read-ahead for sequential workloads
  * increased queue depth for better throughput
  * tuned scheduler expiry values (read/write)

---

### 🧠 Task 3: Performance Evaluation & Resource Consumption

I validated tuning effects using workload tests and monitoring:

* Created and executed a network test script using local `iperf3`
* Captured live interface stats during load (`/proc/net/dev`, `watch`)
* Measured CPU impact during networking (`ksoftirqd` monitoring)
* Captured socket memory status (`ss -m`)
* Evaluated interrupt activity (`/proc/interrupts`)
* Created and executed a storage benchmark script (random/sequential read/write using `fio`)
* Observed disk utilization and iowait behavior (`iostat`, `vmstat`, `iotop`)
* Performed system-wide monitoring snapshot using a script (CPU, memory, I/O, load, interrupts)

---

### 💡 Task 4: Persistence + Validation

To ensure changes survive reboot and remain measurable:

* Created a persistent sysctl config: `/etc/sysctl.d/99-performance-tuning.conf`
* Created a systemd oneshot service for storage tuning:

  * `/etc/systemd/system/storage-tuning.service`
* Created a network tuning script:

  * `/usr/local/bin/network-tuning.sh`
* Created a systemd oneshot service for network tuning:

  * `/etc/systemd/system/network-tuning.service`
* Applied configuration and validated current values
* Created a validation script to confirm parameters meet expected values

---

## ✅ Verification & Validation

I validated tuning using:

* `sysctl` reads of key network + VM parameters
* `ethtool -g` ring buffer verification
* scheduler and queue parameter verification via `/sys/block/sda/queue/`
* automated validation script which confirmed:

  * Net buffers and backlog tuned correctly
  * VM dirty/swap tuning applied
  * Scheduler recognized as `mq-deadline`

---

## 📌 Result

After applying the tuning:

* Network buffer maximums increased to support high throughput
* Backlog queue increased to better handle bursts of packets
* `bbr` congestion control enabled for improved throughput/latency balance
* Interface ring buffers scaled to max to reduce packet drops under load
* Storage queue settings tuned for better sequential throughput and stable latency
* Dirty page and swap behavior tuned to reduce unnecessary write stalls
* Persistent configuration created for repeatable performance behavior
* Validation script confirms tuning applied correctly with **0 failures**

---

## 💡 Why This Matters

Kernel parameter tuning is a core skill for performance engineering because:

* **Throughput and latency** can dramatically improve without changing hardware
* tuning enables higher workload density per server (cost efficiency)
* better defaults reduce bottlenecks in network-heavy and storage-heavy applications
* systematic benchmarking + validation prevents guesswork
* these are exam-relevant skills for performance tuning certifications

---

## 🌍 Real-World Applications

This workflow applies directly to:

* Web and API servers under heavy concurrent load
* High-throughput file transfers and proxies
* Database workloads needing predictable disk latency
* Virtualized cloud environments where `virtio` drivers are common
* Performance optimization and capacity planning tasks in production

---

## 🧾 Conclusion

In this lab, I successfully:

* Audited baseline kernel and module tuning parameters
* Tuned network buffers, backlog, congestion control, and interface offloads
* Tuned storage scheduler behavior and queue parameters
* Tuned VM dirty page behavior and swappiness for more predictable I/O performance
* Benchmarked and monitored system behavior before/after tuning
* Implemented persistent configurations via `sysctl.d` and `systemd`
* Verified correctness using automated validation scripts

✅ **Lab 16 completed successfully — kernel/module tuning applied, tested, persisted, and validated.**
