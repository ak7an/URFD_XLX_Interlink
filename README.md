# URFD_XLX_Interlink

URFD_XLX_Interlink is a deployable multi-protocol amateur radio reflector platform based on URFD.

The project combines:

* URFD reflector services
* XLX reflector interlinking
* TCD transcoding
* Dual DVSI ThumbDV support
* HTTPS Public Dashboard
* HTTPS Sysop Dashboard
* RadioID integration
* XLX Calling Home support
* Automated deployment tools
* Installation validation tools

The goal is to provide a turnkey reflector solution that can be deployed, validated, and maintained by a system operator with minimal manual configuration.

---

## Current Status

Status:

```
Stable
```

Validated Platforms:

* Debian 13 x86_64
* Raspberry Pi 3 Debian 13 arm64

Validated Components:

* URFD
* TCD
* IMBE Vocoder
* FTDI D2XX
* Dual ThumbDV
* Public Dashboard
* Sysop Dashboard
* RadioID Integration
* XLX Calling Home
* Service Controls

---

## Supported Protocols

* D-Star
* DMR
* YSF
* NXDN
* P25
* M17
* G3
* XLX Interlink

---

## Dashboard Features

### Public Dashboard

Accessible through HTTPS.

Features:

* Reflector status
* Linked systems
* Last Heard activity
* Recent node activity
* RadioID operator lookup
* Configurable timezone support
* Automatic refresh

### Sysop Dashboard

Administrative visibility without requiring SSH access.

Features:

* URFD status
* TCD status
* Protocol listener status
* DVSI ThumbDV status
* Transcoder status
* Server health monitoring
* Start / Stop / Restart controls
* Custom service controls
* CSRF protection
* Audit logging

---

## Deployment Framework

Master installer:

* install-all.sh

Current install-all.sh flow:

* install-deps.sh
* install-urfd.sh
* install-imbe-vocoder.sh
* install-ftdi-d2xx.sh
* install-tcd.sh
* install-urfd-tcd-service.sh
* install-dashboard-config.sh
* install-dashboard.sh
* setup-radioid-db.sh
* install-radioid-tools.sh
* install-radioid-timer.sh
* install-service-controls.sh
* install-callinghome-timer.sh
* configure-reflector.sh
* check-install.sh

If FTDI D2XX installation is skipped or unavailable, the installer skips the TCD
and URFD/TCD service steps while continuing with URFD, dashboard, RadioID,
service controls, Calling Home, reflector configuration, and validation.

Monit is historical/optional and is not part of the current master installer
flow.

---

## Quick Start

Clone the repository:

```
git clone https://github.com/ak7an/URFD_XLX_Interlink.git ~/urfd
```

Install:

```
cd ~/urfd

sudo ./install-all.sh
```

Validate:

```
sudo ./scripts/check-install.sh
```

Expected result:

```
FAIL: 0
```

---

## Documentation

Deployment Guide:

```
INSTALLATION.md
```

Project History and Development Notes:

```
PROJECT_STATE.md
```

---

## Screenshots

Dashboard screenshots are stored under:

```
docs/screenshots/
```

Planned screenshots:

- Public Dashboard
- Sysop Dashboard
- Service Controls
- XLX Calling Home Status
- RadioID Last Heard Lookup

---

## Sysop Dashboard User Management

The Sysop Dashboard supports multiple authenticated administrators.

User accounts are intentionally managed from the server console and are not editable through the web interface.

Manage Sysop Dashboard users with:

```
sudo urfd-sysop-user add USERNAME
sudo urfd-sysop-user remove USERNAME
sudo urfd-sysop-user list
```

Examples:

```
sudo urfd-sysop-user add Admin2
sudo urfd-sysop-user remove Admin2
```

The user database is stored in:

```
/etc/apache2/.htpasswd-urfd-sysop
```

Only users with server-level administrative access should manage Sysop Dashboard accounts.

---

## License

Copyright (C) 2026 Edward Nichols (AK7AN)

Licensed under the GNU General Public License Version 3 (GPLv3).

See LICENSE for details.
