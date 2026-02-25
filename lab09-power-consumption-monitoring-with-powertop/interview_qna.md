# 🎤 Interview Q&A - Lab 9 (powertop + Power Optimization)

> This file contains interview-style questions and answers based on the work performed in **Lab 09: Power Consumption Monitoring with powertop**.

---

## 1) What is `powertop` and why is it used?
**Answer:**  
`powertop` is a Linux power diagnostic tool that measures and estimates power consumption, identifies power-hungry processes/devices, and provides tunable recommendations to improve power efficiency. It is commonly used on laptops to extend battery life, and on servers to reduce energy usage.

---

## 2) Why does `powertop` typically require root privileges?
**Answer:**  
Because it needs access to low-level hardware counters and power management interfaces (MSR registers, CPU frequency controls, device power control sysfs nodes). Many of those are restricted to root for security reasons.

---

## 3) What is the purpose of loading the `msr` module?
**Answer:**  
`msr` enables access to CPU Model-Specific Registers, which powertop uses to read hardware power/performance counters. Without it, power measurement accuracy and available metrics can be reduced.

---

## 4) What does `powertop --calibrate` do?
**Answer:**  
It performs calibration routines to improve measurement accuracy, including testing device power states and collecting baseline measurement samples. It can take several minutes and the system should be kept as idle as possible during calibration.

---

## 5) What are the main tabs in the powertop interactive UI?
**Answer:**  
- **Overview**: overall power usage + top consumers  
- **Idle stats**: CPU idle state statistics (C-states)  
- **Frequency stats**: CPU frequency state usage (P-states / scaling)  
- **Device stats**: per-device activity and power impact  
- **Tunables**: recommended power-saving toggles (Good/Bad)

---

## 6) How do you generate a report from powertop?
**Answer:**  
Common formats include:
```bash
sudo powertop --html=power_report.html --time=60
sudo powertop --csv=power_data.csv --time=30
````

These collect data for the specified duration and write reports to disk.

---

## 7) Why did the lab check `/sys/class/power_supply/`?

**Answer:**
Because it indicates whether the system has battery devices (`BAT*`) and whether AC power is online (e.g., `ACAD/online`). That determines whether the system is on battery or AC and influences tuning decisions.

---

## 8) In this lab, the system reported “AC Power detected” but powertop showed discharge rate. Why can that happen?

**Answer:**
Cloud VMs may simulate or expose incomplete/virtualized power telemetry. Powertop may still show estimated baseline/discharge rates using RAPL or internal estimation logic even without a real battery, especially in “simulated laptop” environments.

---

## 9) What does `powertop --auto-tune` do?

**Answer:**
It automatically applies the tunable recommendations from the “Tunables” tab, switching many devices and kernel settings into power-saving modes (where possible).

---

## 10) What is a CPU governor and why does it matter for power consumption?

**Answer:**
A CPU governor controls how CPU frequency scales.

* `performance` tends to hold higher frequencies (more power)
* `powersave` lowers frequency and favors efficiency
  Switching to `powersave` can reduce power usage and heat at the cost of peak performance.

---

## 11) Why did you enable laptop mode (`/proc/sys/vm/laptop_mode`)?

**Answer:**
Laptop mode increases how long the system delays disk writes, reducing disk spin-up frequency (useful on laptops/HDDs). In VMs/SSDs it may have less impact but it still demonstrates power-aware writeback behavior.

---

## 12) Why might the disk tuning loop over `/sys/block/sd*` do nothing in a cloud VM?

**Answer:**
Because many cloud instances use NVMe devices (`/sys/block/nvme*`) rather than `sdX`. The script still worked for CPU + USB + network settings, but disk scheduler tuning may not apply to NVMe in that script.

---

## 13) What does `cpu_power_mgmt.sh` change besides the governor?

**Answer:**
It:

* sets `powersave` across CPUs,
* reduces `scaling_max_freq` to 80% of max,
* applies Intel P-state percentage tuning if supported (`intel_pstate/max_perf_pct`, `min_perf_pct`).

---

## 14) What is the purpose of using `systemd` for persistent tuning?

**Answer:**
Many power settings reset after reboot. A `systemd` unit ensures the tuning script runs automatically at startup, applying the same power policy consistently.

---

## 15) Why use TLP when powertop exists?

**Answer:**
`powertop` is excellent for diagnostics and quick tunables, while **TLP** provides broader, policy-based power management and persistent configuration tailored for laptops and battery/AC switching. Using TLP makes the tuning approach more maintainable and consistent.

---
