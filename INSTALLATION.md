# URFD_XLX_Interlink Installation Guide

---

## Overview

URFD_XLX_Interlink is a deployable multi-protocol amateur radio reflector
platform based on URFD.

Supported protocols:

- D-Star
- DMR
- YSF
- NXDN
- P25
- M17
- G3
- XLX Interlink

The current architecture includes:

- URFD reflector services
- Optional TCD transcoding with DVSI ThumbDV devices
- Custom public dashboard
- Custom Sysop Dashboard
- RadioID SQLite lookup
- Optional XLX Calling Home directory publishing
- Native Sysop Dashboard service controls
- Automated installer and validation tooling

Monit was evaluated historically, but it is not part of the current required
installer flow. Native Sysop Dashboard service controls are the supported
service-control workflow.

---

## Minimum Requirements

Validated during development.

- Raspberry Pi 3 (or newer)
- 1 GB RAM
- 8 GB SD card
- Debian 13 or Raspberry Pi OS (64-bit preferred)
- Internet connection during installation
- Git installed (installer can install if needed)

This configuration has been successfully validated.

## Recommended Production Hardware

For public, continuously operating reflectors.

- Raspberry Pi 4 or Raspberry Pi 5
- 2 GB RAM or greater
- 16 GB or larger storage
- High-quality SD card or SSD
- Wired Ethernet connection

## Recommended x86 Hardware

For larger public systems.

Examples:

- Dell OptiPlex Micro
- HP EliteDesk Mini
- Intel NUC
- Similar low-power x86_64 systems

Recommended:

- Dual-core CPU or better
- 4 GB RAM or greater
- SSD storage

The minimum requirements represent successfully tested hardware. The
recommended configurations provide additional performance margin for public
reflectors, multiple linked protocols, long-term operation, and future
expansion.

Optional transcoding hardware:

- One DVSI ThumbDV for D-Star
- One DVSI ThumbDV for DMR/YSF/NXDN

ThumbDV serial numbers vary by device and test environment. TCD and the
validation tooling normally detect connected USB-FTDI-based DVSI devices
automatically, so fixed serial-number configuration is not normally required.

Example detection output:

```text
Detected 2 USB-FTDI-based DVSI devices
Found ThumbDV, SN=D30G37AJ
Found ThumbDV, SN=D30G37BA
```

---

## Network Requirements

Management:

```text
TCP 22     SSH, optional but recommended
```

Web:

```text
TCP 80     HTTP
TCP 443    HTTPS
```

Digital voice:

```text
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
```

Forward only the protocol ports you intend to use, plus web ports if the
dashboard will be public. HTTPS is strongly recommended for Internet-facing
dashboards.

---

## Pre-Installation Checklist

Before starting, gather:

- Reflector callsign, for example `URF277`
- Public hostname or fully qualified domain name
- Public IP address or router port-forwarding target
- Dashboard URL
- Country
- Sponsor or organization name
- Timezone
- Sysop dashboard username and password
- Whether XLX Calling Home should be enabled
- Whether DVSI ThumbDV/TCD transcoding will be used
- Any desired XLX interlink peers
- Any dashboard logo or branding image

Recommended preparation:

- Assign a static LAN IP address or DHCP reservation to the reflector server.
- Configure DNS before enabling public dashboard access.
- Confirm router/firewall access for required TCP and UDP ports.
- Download the FTDI D2XX archive before installation if ThumbDV/TCD support is
  required.

Use a URF-style reflector callsign for the URFD Callsign field:

```text
URF###
```

Examples:

```text
URF277
URF123
URF999
```

Do not use an `XLX###` value for the URFD Callsign field. If XLX Calling Home or
public directory listing will be enabled, choose a unique reflector number.

Existing public reflector assignments can be reviewed at:

```text
https://xlx.bitbybithams.com/index.php?show=reflectors
```

---

## Operating System Preparation

Update the system:

```sh
sudo apt update
sudo apt full-upgrade -y
```

Install Git:

```sh
sudo apt install -y git
```

Reboot if required.

---

## Obtain URFD_XLX_Interlink

Clone the repository:

```sh
git clone https://github.com/ak7an/URFD_XLX_Interlink.git ~/urfd
```

Enter the repository:

```sh
cd ~/urfd
```

Use the main branch:

```sh
git checkout main
git pull
```

---

## FTDI D2XX and TCD

TCD transcoding requires the proprietary FTDI D2XX library. The project does not
download or redistribute this driver.

If ThumbDV/TCD support is required, download the correct Linux D2XX archive from
FTDI before running the installer:

```text
https://ftdichip.com/drivers/d2xx-drivers/
```

Example ARM64 archive:

```text
libftd2xx-linux-arm-v8-1.4.35.tgz
```

Example x86_64 archive:

```text
libftd2xx-linux-x86_64-<version>.tgz
```

Place the archive in either:

```text
/tmp
```

or beside the repository.

Some FTDI downloads may return HTML or 403 responses when fetched with command
line tools. Downloading the archive with a web browser is often more reliable.

If FTDI D2XX is missing or invalid, `install-all.sh` skips TCD and the combined
URFD/TCD service. URFD, the dashboard, RadioID, service controls, Calling Home,
reflector configuration, and validation continue.

Missing FTDI/TCD items are expected `WARN` results on non-transcoding installs.

---

## Installation

Run the master installer:

```sh
sudo ./install-all.sh
```

The installer must be run as root. It runs the current install flow in this
order:

1. `scripts/install-deps.sh`
2. `scripts/install-urfd.sh`
3. `scripts/install-imbe-vocoder.sh`
4. `scripts/install-ftdi-d2xx.sh`
5. `scripts/install-tcd.sh`, only if FTDI D2XX installation succeeds
6. `scripts/install-urfd-tcd-service.sh`, only if FTDI D2XX installation succeeds
7. `scripts/install-dashboard-config.sh`
8. `scripts/install-dashboard.sh`
9. `scripts/setup-radioid-db.sh`
10. `scripts/install-radioid-tools.sh`
11. `scripts/install-radioid-timer.sh`
12. `scripts/install-service-controls.sh`
13. `scripts/install-callinghome-timer.sh`
14. `scripts/configure-reflector.sh`
15. `scripts/check-install.sh`

Do not run `scripts/install-dashboard-config.sh` separately after
`install-all.sh` unless you intentionally want to reconfigure dashboard settings.

---

## Dashboard Configuration

During installation, `scripts/install-dashboard-config.sh` prompts for:

- Dashboard timezone
- Dashboard logo URL or local path
- Sysop dashboard username
- Sysop dashboard password
- Whether XLX Calling Home should be enabled
- Calling Home directory settings, when enabled

Dashboard configuration is stored in:

```text
/etc/urfd-dashboard/dashboard.conf
```

Sysop dashboard users are stored in:

```text
/etc/apache2/.htpasswd-urfd-sysop
```

After installation, manage additional Sysop Dashboard users from the server
console:

```sh
sudo urfd-sysop-user add USERNAME
sudo urfd-sysop-user remove USERNAME
sudo urfd-sysop-user list
```

---

## Dashboard URLs

The dashboard files are installed to:

```text
/var/www/html/urf/urfd
```

The public URL depends on Apache `DocumentRoot` or alias configuration.

Fresh installer validation checks these URLs:

```text
https://your-server/urf/urfd/
https://your-server/urf/urfd/sysop/
```

Some production layouts set `/var/www/html/urf/urfd` as the Apache
`DocumentRoot`. In that layout, the equivalent URLs are:

```text
https://your-server/
https://your-server/sysop/
```

If the dashboard is reachable through one valid Apache layout but
`check-install.sh` warns on the other, treat that as an Apache mapping warning,
not necessarily a failed installation.

---

## HTTPS

The dashboard should be served through HTTPS for public deployments.

Let's Encrypt with Apache certbot is a common setup:

```sh
sudo apt install -y certbot python3-certbot-apache
sudo certbot --apache
```

Follow the prompts and select the hostname assigned to the reflector.

After HTTPS is configured, verify the dashboard using the URL layout configured
for your Apache site.

---

## RadioID

RadioID provides local operator lookup data for dashboard enrichment.

Runtime files:

```text
/var/lib/urfd-dashboard/radioid.sqlite
/etc/urfd-dashboard/radioid.conf
```

Installed tools:

```text
/usr/local/bin/urfd-radioid-import
/usr/local/bin/urfd-radioid-update
```

Systemd units:

```text
urfd-radioid-update.service
urfd-radioid-update.timer
```

Blank RadioID download URLs are allowed. In that case the database may exist
with no loaded records, and `check-install.sh` may report a warning rather than
a failure.

---

## Native Sysop Health Checks

The Sysop Dashboard uses the native URFD health engine for reflector health
summaries. This is the preferred dashboard health source and does not require
Monit.

Installed tool:

```text
/usr/local/bin/urfd-health
```

Dashboard source:

```text
/var/www/html/urf/urfd/bin/urfd-health
/var/www/html/urf/urfd/sysop/health.php
```

The health engine observes system state only. Service controls remain separate
and continue to use the service-control helpers for start, stop, and restart
actions.

Manual validation:

```bash
/usr/local/bin/urfd-health --pretty
/usr/local/bin/urfd-health --text
```

Monit remains optional external monitoring and can be installed separately when
desired. It is not required for Sysop Dashboard health.

---

## XLX Calling Home

XLX Calling Home is optional, disabled by default, and controlled by the sysop
during dashboard configuration.

Purpose:

- Publish reflector status to the XLX directory ecosystem
- Maintain XLX-style directory visibility
- Support host-file style reflector discovery

Enable Calling Home only when the reflector is ready for public directory
listing.

Configuration:

```text
/etc/urfd-dashboard/dashboard.conf
```

State files:

```text
/var/lib/urfd/callinghome.hash
/var/lib/urfd/lastcallhome
/var/lib/urfd/callinghome.response
```

Publisher:

```text
/usr/local/bin/urfd-callinghome
```

Systemd units:

```text
urfd-callinghome.service
urfd-callinghome.timer
```

The Calling Home hash identifies the reflector to the XLX directory system.
Preserve it during backup and restore. Existing XLXD deployments may choose to
reuse a legacy `/xlxd-ch/callinghome.php` hash during configuration.

Calling Home publishing can be disabled by design. The current installer still
installs the Calling Home service and timer, so missing timer/service warnings
should be reviewed even when publishing is disabled.

---

## Native Service Controls

The Sysop Dashboard includes native service controls for controlled
administrative actions. This is the current supported workflow; Monit is
historical/optional.

Controls are intentionally narrow:

- Dashboard actions use POST requests.
- Requests include CSRF validation.
- Allowed actions are `start`, `stop`, and `restart`.
- Services are allowlisted.
- Privileged actions go through root-owned helper scripts.
- Actions are logged.

Installed helpers:

```text
/usr/local/bin/urfd-service-control
/usr/local/bin/urfd-service-config
```

Sudoers policy:

```text
/etc/sudoers.d/urfd-dashboard-service-control
```

Action log:

```text
/var/log/urfd-dashboard-actions.log
```

Custom service controls are configured in:

```text
/etc/urfd-dashboard/service-controls.conf
```

Custom service format:

```ini
[Display Name]
service=systemd-unit.service
```

The built-in core service target is `urfd-tcd`, which maps to
`urfd-tcd.service` when the TCD stack is installed.

---

## Service Management

On full transcoding installs, the combined service is:

```text
urfd-tcd.service
```

Useful commands:

```sh
sudo systemctl status urfd-tcd
sudo systemctl restart urfd-tcd
journalctl -u urfd-tcd -f
```

On non-transcoding installs where FTDI D2XX was skipped, `urfd-tcd.service` may
not exist. In that case, review `check-install.sh` output and the installer log
to confirm the core URFD binary, configuration files, dashboard, RadioID, service
controls, Calling Home, and validation steps completed.

---

## Validation

Run validation:

```sh
sudo ./scripts/check-install.sh
```

Expected summary:

```text
FAIL: 0
```

Interpretation:

- `PASS` means the checked component matched the expected installed state.
- `WARN` means the item may be optional, skipped, inactive, not yet populated, or
  different because of local Apache/service layout.
- `FAIL` means a required component or required runtime contract is missing or
  broken.

Common expected warnings:

- FTDI D2XX/TCD warnings on non-transcoding installs
- ThumbDV device warnings when hardware is not attached
- Calling Home warnings when Calling Home is disabled
- RadioID database warnings when download URLs are blank or records are not yet
  loaded
- Apache URL mapping warnings when a valid alternate dashboard layout is used
- FTDI/TCD service warnings when the transcoding stack is intentionally skipped

Review every warning before considering the install complete, but warnings do
not automatically mean the reflector is unusable.

---

## Troubleshooting

Run validation first:

```sh
sudo ./scripts/check-install.sh
```

Check service status on full TCD installs:

```sh
sudo systemctl status urfd-tcd
```

Follow service logs:

```sh
journalctl -u urfd-tcd -f
```

Check timers:

```sh
systemctl list-timers urfd-radioid-update.timer urfd-callinghome.timer --no-pager
```

Common causes of warnings or failures:

- Missing or invalid FTDI D2XX archive
- ThumbDV devices not attached or not detected
- Firewall or router port-forwarding issues
- Apache virtual host or `DocumentRoot` layout mismatch
- Missing TLS certificate for public HTTPS
- Dashboard configuration errors
- Blank RadioID download URLs
- Calling Home disabled by design
- `urfd-tcd.service` absent because FTDI/TCD was intentionally skipped

---

## Backup Planning

Back up these files before major upgrades or system replacement:

```text
/etc/urfd-dashboard/
/usr/local/etc/urfd.ini
/usr/local/etc/urfd.interlink
/usr/local/etc/urfd.blacklist
/usr/local/etc/urfd.whitelist
/usr/local/etc/urfd.terminal
/var/lib/urfd-dashboard/
/var/lib/urfd/
/etc/apache2/.htpasswd-urfd-sysop
```

These contain reflector identity, dashboard configuration, sysop authentication,
Calling Home identity, RadioID data, interlink configuration, and dashboard
customization.

---

## Upgrade Procedure

Before upgrading, back up the configuration files listed in the Backup Planning section of this document.

This preserves your reflector identity, Calling Home hash, dashboard configuration, authentication database, and RadioID data.

Update the repository:

```sh
cd ~/urfd
git pull
```

Run the installer again:

```sh
sudo ./install-all.sh
```

The installer is interactive and may re-run dashboard and reflector
configuration prompts. Review prompts carefully before accepting defaults on an
existing system.

Restart the reflector service if the TCD stack is installed:

```sh
sudo systemctl restart urfd-tcd
```

Validate:

```sh
sudo ./scripts/check-install.sh
```

Expected result:

```text
FAIL: 0
```

Review all `WARN` items before returning the reflector to service.

---

## Project Repository

```text
https://github.com/ak7an/URFD_XLX_Interlink
```
