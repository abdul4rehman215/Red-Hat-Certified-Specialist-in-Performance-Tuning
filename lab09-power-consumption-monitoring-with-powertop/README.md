# 🔋 Lab 09: Power Consumption Monitoring with `powertop`

**Category:** Red Hat Certified Specialist in Performance Tuning (Exam Labs)  
**Environment:** CentOS/RHEL 8/9 (Cloud Lab Environment)  
**User:** `centos`  
**Shell:** `-bash-4.2`  
**Date:** 2026-02-25  

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Install and configure `powertop` for power consumption monitoring
- Analyze power usage patterns and identify power-hungry activity
- Apply power optimization strategies (auto-tune + custom tuning)
- Configure persistent power optimization via `systemd`
- Generate power usage reports (HTML + CSV) for documentation and analysis
- Apply advanced power tuning using `TLP`
- Build custom power profiles and automated power management logic

---

## ✅ Prerequisites

Before starting this lab, I had:

- Linux CLI basics and system administration awareness
- Understanding of processes, CPU frequency, I/O, and networking
- Familiarity with `systemd` services and configuration files
- Basic knowledge of CPU governors and power management concepts

---

## 🧰 Lab Environment

This lab was performed in a cloud-based CentOS/RHEL environment.

| Component | Details |
|----------|---------|
| OS | CentOS/RHEL 8/9 |
| Access | `sudo` available |
| Power Source | AC (no physical battery exposed in `/sys/class/power_supply/BAT*`) |
| Tools Installed | `powertop`, `kernel-tools`, `kernel-tools-libs`, `tlp`, `tlp-rdw` |
| Notes | Cloud VMs often expose limited power telemetry compared to real laptops |

---

## 📁 Repository Structure

```text
lab09-power-consumption-monitoring-with-powertop/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── reports/
│   ├── power_report.html
│   ├── power_data.csv
│   └── power_optimization_report.txt
├── benchmark/
│   └── (reference paths used in lab: /tmp/power_benchmark/*.csv)
└── scripts/
    ├── analyze_power.sh
    ├── power_optimize.sh
    ├── cpu_power_mgmt.sh
    ├── power_dashboard.sh
    ├── power_benchmark.sh
    ├── generate_power_report.sh
    ├── power_profiles.sh
    └── auto_power_mgmt.sh
└── systemd/
    ├── power-optimize.service
    └── auto-power-mgmt.service
````

> ✅ In the actual VM, `powertop` generated `power_report.html` and `power_data.csv` in `/home/centos`.
> In the repo, these belong under `reports/` for clean organization.

---

## 🧩 Lab Tasks Overview

### ✅ Task 1: Installing and Configuring `powertop`

* Updated system packages using `dnf`
* Installed:

  * `powertop`
  * `kernel-tools` (and libs)
* Verified installation:

  * `powertop --version`
* Prepared environment:

  * Confirmed power supply status under `/sys/class/power_supply/`
  * Loaded the `msr` module (`modprobe msr`) for hardware counters

---

### ✅ Task 2: Power Consumption Analysis + Reports

* Ran calibration:

  * `sudo powertop --calibrate`
* Used interactive mode to review:

  * Overview / Idle stats / Frequency stats / Device stats / Tunables
* Generated reports for documentation:

  * HTML report (`--html=... --time=60`)
  * CSV report (`--csv=... --time=30`)
* Built `analyze_power.sh` to log:

  * power source (AC vs battery)
  * top CPU processes
  * CPU frequency
  * active network interfaces
  * disk activity via `iostat`

---

### ✅ Task 3: Implementing Power Optimization Strategies

* Applied automatic tunables:

  * `sudo powertop --auto-tune`
* Built `power_optimize.sh` to apply:

  * CPU governor → `powersave`
  * laptop mode (`/proc/sys/vm/laptop_mode`)
  * USB autosuspend
  * network device power control
  * disk scheduler tweak (note: cloud VM uses NVMe, original loop targets `/sys/block/sd*`)

---

### ✅ Task 4: Measuring Improvements + Reporting

* Built `power_dashboard.sh` (terminal dashboard style)
* Built `power_benchmark.sh` to capture “baseline vs stress” snapshots into CSV:

  * baseline power CSV + baseline load CSV
  * stress power CSV + stress load CSV
* Built `generate_power_report.sh`:

  * collects system info, power supply, CPU governors, laptop mode, USB and network power settings
  * outputs a single readable report (`power_optimization_report.txt`)

---

### ✅ Task 5: Advanced Power Tuning Techniques

* Installed and enabled `TLP`:

  * `dnf install tlp tlp-rdw`
  * `systemctl enable --now tlp`
  * `tlp start` + `tlp-stat -s`
* Created custom profile framework:

  * `power_profiles.sh` supports: `performance`, `balanced`, `powersave`, `list`
* Implemented automated profile switching:

  * `auto_power_mgmt.sh` decides profile based on AC status + battery %
  * deployed via `systemd` service: `auto-power-mgmt.service`

---

## ✅ Result

At the end of this lab, I had:

* Working `powertop` installation + calibration workflow
* Generated HTML/CSV reports for power analysis
* Implemented auto tuning + custom tuning scripts
* Persistent optimization via `systemd`
* Advanced management using TLP
* Custom profiles + automated selection service

---

## 📌 What I Learned

* How `powertop` identifies tunables and estimates power usage
* How to apply and persist power-saving settings safely using `systemd`
* The difference between one-time tuning vs persistent tuning
* How to structure power benchmarking evidence (before/after CSV logs)
* How to build realistic power automation (profiles + policies)

---

## 🌍 Why This Matters

Power tuning is useful in real environments like:

* Laptops: extend battery life and reduce heat
* Servers: reduce energy cost and improve efficiency
* Enterprise fleets: enforce power policies centrally
* Performance roles: balance performance vs power trade-offs

---

## ✅ Conclusion

In this lab, I installed and configured `powertop`, generated detailed reports, and applied power tuning using both built-in tools and custom automation. I also made power optimizations persistent with `systemd`, and implemented advanced control with TLP + custom profiles—creating a complete workflow for power monitoring and optimization.

✅ Lab completed successfully on a CentOS/RHEL cloud lab environment.
