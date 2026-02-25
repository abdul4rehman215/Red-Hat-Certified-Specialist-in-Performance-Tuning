# 🎤 Interview Q&A — Lab 16: Kernel Module Parameter Tuning

> This Q&A set is designed for quick revision and interview prep based on the work performed in **Lab 16**.

---

## 1) What are kernel module parameters and why do they matter for performance?
Kernel module parameters are tunable settings exposed by kernel modules (drivers/subsystems). They influence how the kernel handles networking, storage, memory, and hardware interactions. Correct tuning can improve throughput, reduce latency, and optimize resource usage for specific workloads.

---

## 2) What is the difference between `sysctl` parameters and module parameters shown by `modinfo`?
- **`sysctl` parameters** adjust runtime kernel settings (mostly under `/proc/sys/`) like TCP buffers, VM tuning, backlog sizes.
- **Module parameters** (seen via `modinfo`) are specific to a kernel module/driver (e.g., `virtio_net`, `virtio_blk`) and define behavior/features that driver supports.

---

## 3) Why did you increase `net.core.rmem_max` and `net.core.wmem_max`?
To allow larger socket receive/send buffers. For high-throughput transfers, default buffer limits can become bottlenecks. Increasing max buffer sizes helps sustain higher bandwidth and reduces throttling under load.

---

## 4) What does `net.core.netdev_max_backlog` control?
It controls the maximum number of packets allowed in the queue when the kernel is processing incoming packets faster than the network stack can handle them. Increasing it helps absorb bursts and reduces packet drops in high traffic scenarios.

---

## 5) What is TCP congestion control, and why did you set it to BBR?
Congestion control decides how TCP adapts to network conditions to avoid congestion. **BBR** (Bottleneck Bandwidth and RTT) often improves throughput and reduces latency in many modern environments compared to traditional algorithms like Reno or Cubic.

---

## 6) How did you confirm BBR availability and activation?
- Checked available algorithms via:
  - `/proc/sys/net/ipv4/tcp_available_congestion_control`
- Set it using:
  - `sysctl -w net.ipv4.tcp_congestion_control=bbr`
- Confirmed module loaded (if needed) using:
  - `lsmod | grep tcp_bbr`

---

## 7) What are NIC ring buffers and why did you increase RX/TX to 4096?
Ring buffers are memory structures used by the NIC driver to queue packets for receive/transmit. Increasing RX/TX ring sizes helps reduce packet drops and improves performance during bursts or high throughput traffic.

---

## 8) What do TSO and GRO do, and why enable them?
- **TSO (TCP Segmentation Offload):** Offloads TCP segmentation work to the NIC/driver, reducing CPU overhead.
- **GRO (Generic Receive Offload):** Coalesces multiple received packets into larger buffers before processing, improving efficiency and throughput.

---

## 9) What is RPS and what does setting `rps_cpus` do?
**Receive Packet Steering (RPS)** distributes packet processing across multiple CPUs. Writing a CPU mask to `rps_cpus` helps balance softirq processing (network receive handling) across cores, improving parallelism and reducing bottlenecks.

---

## 10) Why did you examine and tune the I/O scheduler on `/dev/sda`?
The I/O scheduler affects how read/write requests are ordered and dispatched. For certain workloads (databases, mixed I/O), schedulers like `mq-deadline` can provide more predictable latency and better fairness than alternatives.

---

## 11) What is `read_ahead_kb` and why did you increase it to 512?
Read-ahead controls how much data the kernel reads ahead during sequential reads. Increasing it can improve sequential throughput (streaming reads, backups, large file scans) by reducing I/O wait and improving prefetch efficiency.

---

## 12) Why did you increase `nr_requests` from 64 to 128?
`nr_requests` controls how many requests can be queued in the block layer. Increasing it can improve throughput under load by allowing deeper queues, especially useful when workloads generate many concurrent I/O operations.

---

## 13) What are VM dirty ratios and why tune `vm.dirty_ratio` and `vm.dirty_background_ratio`?
These settings control when dirty (modified) memory pages are flushed to disk:
- `dirty_background_ratio` triggers background writeback.
- `dirty_ratio` is the max percentage of dirty pages before processes are forced to write.
Lower values can reduce long write stalls and improve latency predictability on I/O-heavy systems.

---

## 14) Why lower `vm.swappiness` to 10?
Swappiness controls how aggressively the kernel swaps memory pages to disk. Lower swappiness reduces swapping tendency, improving performance for workloads that prefer RAM residency and avoiding unnecessary disk I/O.

---

## 15) How did you make tuning persistent across reboots?
- Used a sysctl config file:
  - `/etc/sysctl.d/99-performance-tuning.conf`
- Created systemd oneshot services for settings that must apply after boot:
  - `storage-tuning.service` (I/O scheduler + queue tuning)
  - `network-tuning.service` (interface ring buffers/offloads/RPS)
- Validated by re-applying `sysctl -p` and verifying settings via scripts.

---
