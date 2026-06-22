# URFD_XLX_Interlink Installation Guide

Version: 1.0.1

---

# Overview

URFD_XLX_Interlink is a multi-protocol digital voice reflector supporting:

- D-Star
- DMR
- YSF
- NXDN
- P25
- M17
- G3
- XLX Interlink

Optional transcoding support is provided through TCD and DVSI ThumbDV AMBE devices.

This guide covers deployment on:

- Debian 13 (recommended)
- Raspberry Pi OS
- Ubuntu-family systems including Zorin OS

---

# Hardware Requirements

Minimum:

- 2 CPU cores
- 2 GB RAM
- 20 GB storage

Recommended:

- 4 CPU cores
- 4 GB RAM
- SSD storage

Validated Platforms:

- Raspberry Pi 3
- Debian 13 x86_64
- Debian 13 arm64

---

# Optional Hardware

For transcoding support:

- One DVSI ThumbDV for D-Star
- One DVSI ThumbDV for DMR/YSF/NXDN

ThumbDV Detection

The installer and TCD automatically detect connected
DVSI ThumbDV devices.

No serial number configuration is normally required.

Example:

    Detected 2 USB-FTDI-based DVSI devices

    Found ThumbDV, SN=D30G37AJ
    Found ThumbDV, SN=D30G37BA

Actual serial numbers will differ for each installation.

---

# Network Requirements

Recommended public ports:

Web Services:

    TCP 80     HTTP
    TCP 443    HTTPS

Digital Voice Services:

    UDP 20001  DPlus
    UDP 30001  DExtra
    UDP 30051  DCS
    UDP 62030  DMR
    UDP 42000  YSF
    UDP 41400  NXDN
    UDP 41000  P25
    UDP 17000  M17
    UDP 10002  XLX Interlink
    UDP 40000  G3

HTTP and HTTPS are strongly recommended.

The public dashboard, Sysop dashboard, RadioID services,
and management functions are designed to be accessed
through HTTPS.

For Internet-facing deployments, a valid TLS certificate
(Let's Encrypt recommended) should be configured.

---

# Initial Operating System Preparation

Update the system:

    sudo apt update
    sudo apt full-upgrade -y

Install Git:

    sudo apt install -y git

Reboot if required.

---

# Obtain URFD_XLX_Interlink

Clone repository:

    git clone https://github.com/ak7an/URFD_XLX_Interlink.git urfd

Enter repository:

    cd ~/urfd

Verify branch:

    git checkout main

Update repository:

    git pull

---

# FTDI D2XX Driver Requirement

TCD requires the FTDI D2XX library.

Download the appropriate Linux D2XX archive from FTDI:

    https://ftdichip.com/drivers/d2xx-drivers/

Select the Linux D2XX driver package appropriate for
your platform.

Example ARM64 archive:

    libftd2xx-linux-arm-v8-1.4.35.tgz

Example x86_64 archive:

    libftd2xx-linux-x86_64-<version>.tgz

Place the downloaded archive in:

    /tmp

or beside the repository.

The installer automatically detects and installs the archive.

Note:

Some FTDI downloads may not work correctly with command-line
download tools such as wget. Downloading the archive using a
web browser is recommended.

---

# Installation

Run:

    sudo ./install-all.sh

The installer performs:

- Dependency installation
- URFD installation
- IMBE vocoder installation
- FTDI D2XX installation
- TCD installation
- Dashboard installation
- RadioID setup
- Timer installation
- Service installation
- Validation checks

---

# Dashboard Configuration

Run:

    sudo ./scripts/install-dashboard-config.sh

You will be prompted for:

- Timezone
- Sysop credentials
- Calling Home enable/disable
- Dashboard information

---

# Starting Services

Start:

    sudo systemctl start urfd-tcd

Enable:

    sudo systemctl enable urfd-tcd

Check status:

    sudo systemctl status urfd-tcd

---

# Validation

Run:

    sudo ./scripts/check-install.sh

Expected:

    FAIL: 0

---

# Dashboard URLs

Public Dashboard:

    https://your-server/urf/urfd/

Sysop Dashboard:

    https://your-server/urf/urfd/sysop/

---

# Troubleshooting

Service status:

    sudo systemctl status urfd-tcd

Logs:

    journalctl -u urfd-tcd -f

Validation:

    sudo ./scripts/check-install.sh

Common causes:

- Missing FTDI archive
- Missing ThumbDV device
- Firewall configuration
- Dashboard configuration errors

---

# Project Repository

https://github.com/ak7an/URFD_XLX_Interlink

