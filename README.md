# URFD_XLX_Interlink

URFD_XLX_Interlink is an enhanced URFD-based amateur radio reflector platform that combines reflector services, XLX interlinking, modern dashboard capabilities, RadioID integration, deployment automation, and native sysop service controls.

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
- Native URFD/TCD restart control
- Custom service controls
- Ham radio service discovery
- CSRF-protected service actions
- Audit logging

### RadioID Integration

Integrated SQLite lookup database.

Current support:

- DMR records
- NXDN records

Provides:

- Operator name lookup
- Automated database updates
- Local lookup performance

### Native Sysop Service Controls

Integrated service controls are provided directly through the Sysop Dashboard.

Provides:

- Core URFD/TCD restart control
- Configurable custom service controls
- Ham radio service discovery popup
- Checkbox-based service selection
- Support for Dire Wolf and common DVSwitch/MMDVM gateway services
- Root-owned helper scripts
- Restricted sudo policy
- CSRF protection
- Action logging

Custom service controls are stored in:

    /etc/urfd-dashboard/service-controls.conf

The discovery tool can populate common ham radio services automatically.
Sysops may also manually add other local systemd services to the config file.

### Deployment Framework

Included tools:

- install-all.sh
- install-deps.sh
- install-dashboard.sh
- install-dashboard-config.sh
- install-service-controls.sh
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
- Native sysop service controls
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
- Configure native sysop service controls
- Configure service-control sudo policy
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
- Native sysop service controls
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
- Native sysop service controls
- Installation tooling
- Documentation

Copyright (C) 2026 Edward Nichols (AK7AN)

This project remains licensed under the GNU General Public License Version 3 (GPLv3).

Original copyright notices from upstream projects remain in effect and have been preserved.


### Sysop Dashboard User Management

The Sysop Dashboard supports multiple authenticated administrators.

User accounts are intentionally managed from the server console and are not editable through the web interface.

This design prevents delegated dashboard administrators from granting additional access without approval from the primary system owner.

Manage Sysop Dashboard users with:

    sudo urfd-sysop-user add USERNAME
    sudo urfd-sysop-user remove USERNAME
    sudo urfd-sysop-user list

Examples:

    sudo urfd-sysop-user add Admin2
    sudo urfd-sysop-user remove Admin2

The user database is stored in:

    /etc/apache2/.htpasswd-urfd-sysop

Only users with server-level administrative access should manage Sysop Dashboard accounts.

