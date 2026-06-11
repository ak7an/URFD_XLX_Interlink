# URFD_XLX_Interlink

URFD_XLX_Interlink is an enhanced URFD-based amateur radio reflector platform that combines reflector services, XLX interlinking, modern dashboard capabilities, RadioID integration, deployment automation, and remote maintenance tools.

The goal of the project is to provide a reflector platform that can be deployed and managed by a sysop with minimal manual configuration while maintaining compatibility with existing URFD and XLX ecosystems.

---

## Features

### Reflector Services

- URFD reflector operation
- XLX reflector interlink support
- D-Star support
- DMR support
- YSF support
- NXDN support
- P25 support
- M17 support
- TCD transcoder integration

### Public Dashboard

Accessible via HTTPS.

Features include:

- Reflector status
- Linked systems display
- Last Heard activity
- RadioID operator name lookup
- Recent node activity
- Automatic refresh
- Configurable local timezone support

### Sysop Dashboard

Administrative visibility without requiring SSH access.

Features include:

- URFD service status
- TCD service status
- Protocol listener status
- Transcoder status
- DVSI dongle status
- Server health monitoring
- Monit integration
- Maintenance dashboard access

### RadioID Integration

Integrated SQLite lookup database.

Current support:

- DMR records
- NXDN records

Provides:

- Operator name lookup
- Automated database updates
- Local lookup performance

### Monit Integration

Integrated remote maintenance platform.

Provides:

- Service monitoring
- Service restart capability
- Resource monitoring
- Remote sysop access
- HTTPS protected management interface

### Deployment Framework

Included tools:

- install-all.sh
- install-deps.sh
- install-dashboard.sh
- install-dashboard-config.sh
- install-monit.sh
- setup-radioid-db.sh
- install-radioid-tools.sh
- install-radioid-timer.sh
- configure-reflector.sh
- check-install.sh

---

## Project Scope

URFD_XLX_Interlink is designed as a multi-mode reflector platform with reflector-to-reflector interconnection.

Supported:

- URFD reflector operation
- XLX interlinking
- Dashboard integration
- RadioID integration
- Monit integration
- Deployment automation

Not Supported:

- BrandMeister DMR Master operation

The project intentionally focuses on reflector services and reflector interconnection rather than operation as a DMR network master.

This design:

- Avoids port conflicts
- Simplifies deployment
- Simplifies support
- Provides a predictable sysop experience

---

## Installation

Clone the repository:

    git clone https://github.com/ak7an/URFD_XLX_Interlink.git
    cd URFD_XLX_Interlink

Run the installer:

    sudo ./install-all.sh

The installer will:

- Install dependencies
- Configure dashboards
- Configure dashboard timezone
- Configure RadioID integration
- Configure Monit
- Configure maintenance authentication
- Configure reflector options
- Validate installation


---

## Project Status

Status: Stable

URFD_XLX_Interlink is a deployable multi-protocol reflector platform based on URFD with integrated XLX interlink support.

Current features include:

- D-Star reflector support
- XLX interlink support
- HTTPS dashboard
- Sysop dashboard
- RadioID lookups
- Monit service monitoring
- Automated deployment framework
- Automated RadioID updates
- Configurable dashboard timezone

The project is intended to provide a turnkey reflector solution that can be deployed and maintained by a system operator with minimal manual intervention.


---

## Copyright

URFD_XLX_Interlink contains enhancements and additions developed by:

Edward Nichols (AK7AN)

Additional project work includes:

- Custom public dashboard
- Custom sysop dashboard
- RadioID integration
- Deployment automation
- Monit integration
- Installation tooling
- Documentation

Copyright (C) 2026 Edward Nichols (AK7AN)

This project remains licensed under the GNU General Public License Version 3 (GPLv3).

Original copyright notices from upstream projects remain in effect and have been preserved.

