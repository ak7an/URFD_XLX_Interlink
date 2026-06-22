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

Management Services:

    TCP 22     SSH (optional but recommended)

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

SSH access is recommended for remote administration,
updates, troubleshooting, backup, and recovery.

For Internet-facing deployments:

- Use key-based authentication when possible.
- Disable password authentication if practical.
- Restrict access by firewall where possible.
- Consider changing the default SSH port if desired.

Remote administration is not required for reflector
operation but is strongly recommended.

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


---

# Pre-Installation Checklist

Before beginning installation, gather the following information:

- Reflector callsign, for example URF277
- Public hostname or fully qualified domain name
- Public IP address or router port-forwarding target
- Dashboard URL
- Country
- Sponsor or organization name
- Timezone
- Sysop dashboard username
- Sysop dashboard password
- Whether XLX Calling Home should be enabled
- Whether DVSI ThumbDV / TCD transcoding will be used
- Any desired XLX interlink peers
- Any dashboard logo or branding image

Recommended preparation:

- Assign a static LAN IP address to the reflector server.
- Configure DNS before enabling public dashboard access.
- Confirm router/firewall access for required TCP and UDP ports.
- Download the FTDI D2XX archive before installation if ThumbDV/TCD support is required.

---

# DNS and Static IP Recommendation

A public reflector should use a stable hostname.

Recommended:

    xlx277.example.org

or:

    urf277.example.org

The server should also have a stable local network address.

Recommended options:

- DHCP reservation in the router
- Static IP configured on the server

Avoid using a changing LAN IP address for a production reflector.

---

# Router and Firewall Notes

For home or club installations behind a router, forward the required ports
from the router to the reflector server.

At minimum, forward the digital voice UDP ports for the protocols you plan
to support.

For dashboard access, forward:

    TCP 80
    TCP 443

HTTPS is strongly recommended for any Internet-facing dashboard.

---

# HTTPS Recommendation

The dashboard should be served through HTTPS for public deployments.

Recommended certificate provider:

    Let's Encrypt

Typical Apache HTTPS deployments use:

    certbot

Example package installation:

    sudo apt install -y certbot python3-certbot-apache

Example certificate request:

    sudo certbot --apache

Follow the prompts and select the hostname assigned to the reflector.

After HTTPS is configured, verify:

    https://your-hostname/urf/urfd/

and:

    https://your-hostname/urf/urfd/sysop/

---

# Reflector Identity

URFD_XLX_Interlink uses a URF-style reflector callsign.

Example:

    URF277

Replace the example callsign with the reflector
identifier assigned to your installation.

Do not use:

    XLX277

for the URFD Callsign field.

The reflector callsign must follow the format:

    URF###

where # is a numeric digit.

Examples:

    URF277
    URF123
    URF999

Before selecting a reflector number, verify that the
number is not already in use by another public reflector.

Duplicate reflector numbers can create confusion for users,
host files, dashboards, and directory listings.

If XLX Calling Home or public directory listing will be
enabled, selecting a unique reflector number is strongly
recommended.

A future installer release may prompt for this value.

---

# XLX Calling Home

XLX Calling Home is optional.

Purpose:

- Publish reflector status to the XLX directory ecosystem
- Maintain XLX-style directory visibility
- Support host-file style reflector discovery

Default:

    Disabled

Enable Calling Home only when the reflector is ready for public directory
listing.

Calling Home configuration is stored in:

    /etc/urfd-dashboard/dashboard.conf

Calling Home state files are stored under:

    /var/lib/urfd/

Important files:

    /var/lib/urfd/callinghome.hash
    /var/lib/urfd/lastcallhome

The Calling Home hash identifies the reflector to the XLX directory system.
Preserve this file during backup and restore.

---

# Backup Planning

Important configuration and identity files should be backed up before major
upgrades or system replacement.

Recommended backup targets:

    /etc/urfd-dashboard/
    /usr/local/etc/urfd.ini
    /usr/local/etc/urfd.interlink
    /usr/local/etc/urfd.blacklist
    /usr/local/etc/urfd.whitelist
    /usr/local/etc/urfd.terminal
    /var/lib/urfd-dashboard/
    /var/lib/urfd/
    /etc/apache2/.htpasswd-urfd-sysop

These files contain:

- Reflector identity
- Dashboard configuration
- Sysop authentication
- Calling Home identity
- RadioID database
- Interlink configuration
- Dashboard customization

Future releases are expected to include dedicated backup and restore tools.

---

# Upgrade Procedure

Update the repository:

    cd ~/urfd

    git pull

Run the installer again:

    sudo ./install-all.sh

Restart the reflector service:

    sudo systemctl restart urfd-tcd

Validate:

    sudo ./scripts/check-install.sh

Expected result:

    FAIL: 0

Review any WARN items before returning the reflector to service.

