# 🛠️ Troubleshooting Guide — Lab 16: Kernel Module Parameter Tuning

> This file captures the troubleshooting steps and common issues encountered (or likely to occur) during kernel/network/storage tuning on CentOS/RHEL 8/9 cloud VMs using `virtio` drivers.

---

## ✅ 1) BBR Congestion Control Not Available

### 🔍 Symptom
- You try to set:
  ```bash
  sysctl -w net.ipv4.tcp_congestion_control=bbr
````

but BBR isn’t listed in:

```bash
cat /proc/sys/net/ipv4/tcp_available_congestion_control
```

### ✅ Fix / Validation Steps

1. Check if the module is loaded:

   ```bash
   lsmod | grep tcp_bbr
   ```

   Example output:

   ```text
   tcp_bbr                20480  1
   ```

2. If not loaded, try loading it:

   ```bash
   sudo modprobe tcp_bbr
   ```

3. Make it persistent across reboots:

   ```bash
   echo 'tcp_bbr' | sudo tee -a /etc/modules-load.d/bbr.conf
   ```

---

## ✅ 2) `ethtool` Commands Failing

### 🔍 Symptom

* Running commands like:

  ```bash
  ethtool -g eth0
  ethtool -K eth0 tso on
  ```

  fails with errors such as:
* `command not found`
* `Cannot get device ring settings`
* `No such device`

### ✅ Fix / Validation Steps

1. Ensure `ethtool` is installed:

   ```bash
   which ethtool || sudo yum install -y ethtool
   ```

   Example output:

   ```text
   /usr/sbin/ethtool
   ```

2. Confirm the interface name is correct:

   ```bash
   ip link show
   ```

   Example output:

   ```text
   2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 ...
   ```

3. If the environment uses different NIC naming (like `ens3`, `ens192`, etc.), replace `eth0` accordingly everywhere:

   * scripts
   * systemd unit files
   * `/sys/class/net/...` paths

---

## ✅ 3) No Output from `ethtool` / `sysctl -w` Commands

### 🔍 Symptom

* Commands like:

  ```bash
  sudo ethtool -G eth0 rx 4096 tx 4096
  sudo ethtool -K eth0 gro on
  ```

  produce no output and you’re unsure whether they worked.

### ✅ Fix / Validation Steps

* Verify current hardware settings after applying:

  ```bash
  ethtool -g eth0
  ```

  Example confirmation:

  ```text
  Current hardware settings:
  RX:             4096
  TX:             4096
  ```

* Verify sysctl settings:

  ```bash
  sysctl net.core.rmem_max net.core.wmem_max net.core.netdev_max_backlog
  ```

---

## ✅ 4) I/O Scheduler Change Not Working

### 🔍 Symptom

* You echo a scheduler (e.g., `deadline`) but the scheduler remains unchanged.

### ✅ Fix / Validation Steps

1. Check available schedulers for the target device:

   ```bash
   cat /sys/block/sda/queue/scheduler
   ```

   Example output:

   ```text
   [mq-deadline] kyber bfq none
   ```

2. Use a scheduler that exists in the list (cloud VMs commonly use `mq-deadline`):

   ```bash
   echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler
   ```

3. If your environment uses NVMe disks, the path may differ:

   ```bash
   ls /sys/block/nvme*/queue/scheduler
   ```

   Example output in this VM:

   ```text
   ls: cannot access '/sys/block/nvme*/queue/scheduler': No such file or directory
   ```

   ✅ Meaning: this system is using `sda` (virtio block), not NVMe.

---

## ✅ 5) Permission Denied When Writing to `/sys/*`

### 🔍 Symptom

* Errors like:

  * `Permission denied`
    when changing:
  * scheduler
  * read_ahead
  * nr_requests
  * iosched parameters

### ✅ Fix / Validation Steps

1. Confirm you are using sudo/root:

   ```bash
   sudo -i
   ```

2. Confirm file permissions:

   ```bash
   ls -la /sys/block/sda/queue/
   ```

   Example output snippet:

   ```text
   -rw-r--r--  1 root root 4096 ... read_ahead_kb
   -rw-r--r--  1 root root 4096 ... nr_requests
   -r--r--r--  1 root root 4096 ... scheduler
   ```

3. Always write via `sudo tee` when needed:

   ```bash
   echo 512 | sudo tee /sys/block/sda/queue/read_ahead_kb
   ```

4. Exit root shell when done:

   ```bash
   exit
   ```

---

## ✅ 6) systemd Service Doesn’t Apply Settings at Boot

### 🔍 Symptom

* You enabled the service:

  ```bash
  sudo systemctl enable storage-tuning.service
  ```

  but settings are not applied after boot (or when running manually).

### ✅ Fix / Validation Steps

1. Reload systemd after creating/modifying unit files:

   ```bash
   sudo systemctl daemon-reload
   ```

2. Start service and check for errors:

   ```bash
   sudo systemctl start storage-tuning.service
   sudo systemctl start network-tuning.service
   ```

3. Verify settings after service start:

   ```bash
   cat /sys/block/sda/queue/read_ahead_kb
   ethtool -g eth0
   ```

4. If the interface is not ready when service runs:

   * The script already includes:

     ```bash
     sleep 5
     ```
   * If still failing, increase delay (cloud environments sometimes need it).

---

## ✅ 7) Validation Script Reports Failure

### 🔍 Symptom

* `/tmp/validate_tuning.sh` shows failures (FAIL > 0)

### ✅ Fix / Validation Steps

1. Re-apply sysctl settings:

   ```bash
   sudo sysctl -p /etc/sysctl.d/99-performance-tuning.conf
   ```

2. Restart tuning services:

   ```bash
   sudo systemctl restart storage-tuning.service
   sudo systemctl restart network-tuning.service
   ```

3. Re-run validation:

   ```bash
   /tmp/validate_tuning.sh
   ```

---

## ✅ Notes (Best Practice)

* Always capture baseline metrics before changes:

  * `/tmp/network_baseline.txt`
  * `/tmp/storage_baseline.txt`
* Change one group of parameters at a time and measure impact
* Prefer applying tuning in test/staging first before production
* Keep a rollback plan (restore baseline configs / sysctl backup files)

---
