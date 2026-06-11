# PROJECT_STATE.md

## Project

URFD_XLX_Interlink

Fork of URFD with additional interoperability, transcoding, and dashboard enhancements.

Repository:

git@github.com:ak7an/URFD_XLX_Interlink.git

---

## Current Stable Release

Version:
v0.1-xlx-interlink

Tag:
v0.1-xlx-interlink

Status:
Stable

Validated Features:

- Native URFD reflector operation
- DPlus
- DExtra
- DCS
- DMRMMDVM
- NXDN
- YSF
- P25
- M17
- TCD integration
- Dual ThumbDV support
- XLX interlink peering via Brandmeister transport
- Service-based startup
- Apache HTTPS support available

---

## Custom Modifications

### XLX Interlink Support

Modified:

BMProtocol.cpp

Change:

Allow XLX peers defined in urfd.interlink to be treated as Brandmeister transport peers.

Original:

BM only reconnect logic.

Current:

BM and XLX reconnect logic.

Validation:

- XLX188 linked
- XLX578 linked
- Audio verified between URF277 and XLX systems

---

### P25 Stability Fix

Modified:

P25Protocol.cpp

Change:

Added packet validation safeguards.

Fixes:

- Invalid packet offsets
- Unknown packet types
- Buffer overruns
- Stream termination handling

Validation:

- P25 TX confirmed
- P25 RX confirmed
- No reflector crash observed

---

### TCD Rebuild

Date:
2026-06-08

Actions:

- Removed previous TCD installation
- Cloned clean source from GitHub
- Rebuilt from source
- Reinstalled service
- Verified FTDI/D2XX operation

Current Settings:

DStarGainOut = -10

ThumbDV Assignments:

D30G37BA -> D-Star

D30G37AJ -> DMR/YSF

Status:

Operational

---

## Dashboard Roadmap

Current:

Stock URFD dashboard

Planned Public Dashboard:

- Reflector status
- Linked systems
- Last heard
- Active streams
- Protocol status

Planned Sysop Dashboard:

- Connected clients
- Peer status
- Transcoder status
- ThumbDV status
- CPU and memory usage
- Service status
- Control functions

Web Access:

Apache2 reverse proxy

HTTPS certificate already installed and operational.

---

## Service Layout

Current Service:

urfd-tcd.service

Startup Sequence:

1. Start URFD
2. Wait for TCP listener on 127.0.0.1:10100
3. Start TCD
4. TCD connects to URFD

Current Result:

Stable operation.

---

## Known Issues

- DPlus disconnect/reconnect behavior still being observed
- XLX peer reconnect behavior should continue to be monitored
- Dashboard modernization not yet started

---

## Next Development Priorities

1. Dashboard redesign
2. Last-heard database
3. Linked peer visualization
4. Sysop controls
5. Service monitoring
6. HTTPS dashboard integration
7. Release v0.2-dashboard

---

## Session Handoff Notes

Current repository state is considered stable.

Clone:

git clone git@github.com:ak7an/URFD_XLX_Interlink.git

Repository:

git@github.com:ak7an/URFD_XLX_Interlink.git

Current Tag:

v0.1-xlx-interlink

Known Good State:

- P25 stable
- XLX188 linked
- XLX578 linked
- TCD operational
- Dual ThumbDV configuration operational
- urfd-tcd service operational
- HTTPS infrastructure available

For new ChatGPT sessions:

Read PROJECT_STATE.md before making changes.

Treat PROJECT_STATE.md as the authoritative project status document.


---

## Dashboard Architecture Decision

Date:
2026-06-10

Decision:

Do not heavily modify the stock URFD dashboard.

Instead, develop a separate modern dashboard that operates alongside the existing URFD web interface.

Reasoning:

- Preserve compatibility with future URFD updates
- Avoid maintaining large modifications against upstream code
- Allow rapid dashboard development without impacting reflector operation
- Simplify troubleshooting and upgrades

Proposed Layout:

Apache2
├── Existing URFD Dashboard
└── New Dashboard

Possible URLs:

https://urf277.com/

or

https://urf277.com/dashboard/

The existing URFD dashboard may later include a navigation link to the new dashboard.

---

## Dashboard Technology Stack

Frontend:

- Bootstrap
- Responsive mobile-friendly design
- AJAX live updates

Backend:

- PHP
- JSON status endpoints
- SQLite or MariaDB support if required

Transport:

- Apache2 reverse proxy
- HTTPS certificate already installed

Goal:

Modern dashboard experience similar to MultiMode Reflector while maintaining URFD compatibility.

---

## Dashboard Data Sources

URFD:

- Linked peers
- Connected users
- Active streams
- Protocol status
- Reflector uptime

TCD:

- Transcoder status
- ThumbDV device status
- Active transcoding sessions
- Codec activity

RadioID Data:

- DMR ID lookup
- NXDN ID lookup
- P25 ID lookup

Local Database:

- Last-heard records
- Historical activity
- Traffic statistics
- Stream history

---

## Dashboard Security Plan

Public Dashboard:

Accessible without authentication.

Displays:

- Reflector status
- Linked systems
- Last heard
- Active streams
- Protocol availability

Sysop Dashboard:

Location:

https://urf277.com/sysop/

Initial Authentication:

Apache Basic Authentication

Future Authentication:

- Role-based access
- Multiple administrator accounts
- Session management

Sysop Functions Planned:

- Peer management
- Service monitoring
- TCD monitoring
- ThumbDV monitoring
- Restart controls
- Configuration management

---

## Version Roadmap

v0.1-xlx-interlink

Status:

Released and stable.

Includes:

- URFD reflector operation
- XLX interlink support
- TCD integration
- Dual ThumbDV operation
- HTTPS support

v0.2-dashboard

Planned Features:

- New dashboard
- Last-heard database
- Linked peer visualization
- Sysop dashboard
- Service monitoring
- HTTPS dashboard integration

---

## Project Status Assessment

Core Reflector:
100%

XLX Interlink:
95%

TCD Integration:
100%

Dual ThumbDV Support:
100%

HTTPS Infrastructure:
100%

Dashboard:
0%

Last-Heard Database:
0%

Sysop Controls:
0%

Overall Status:

Stable production reflector ready for dashboard development phase.


---

## Dashboard Development Checkpoint

Date:
2026-06-10

New dashboard path:

https://xlx277.bitbybithams.com/urfd/

Sysop dashboard path:

https://xlx277.bitbybithams.com/urfd/sysop/

Architecture:

- New dashboard is separate from the stock URFD dashboard
- Stock dashboard remains at /urf/
- New dashboard files are under /var/www/html/urf/urfd/
- Dashboard reads live status from /var/log/xlxd.xml
- No URFD/TCD packet-path changes required for dashboard display

Public dashboard now includes:

- Reflector online/stale/offline status
- Protocol status cards
- Last Heard table
- Connected Nodes table
- Linked Systems table
- Active Streams placeholder

Sysop dashboard now includes:

- URFD/TCD service status
- Reflector uptime
- Running-since timestamp
- Server uptime
- CPU load
- CPU temperature from coretemp sensor
- Memory usage
- Disk usage

Last Heard:

- URFD internal last-heard cap increased
- LASTHEARD_USERS_MAX_SIZE changed from 20 to 40
- Trim logic corrected to keep up to LASTHEARD_USERS_MAX_SIZE entries
- Public dashboard displays up to 20 Last Heard entries

Status:

Dashboard phase started successfully.


---

## Deployment and Installation Philosophy

Date:
2026-06-10

Project goal:

A new sysop should be able to deploy URFD_XLX_Interlink with minimal manual intervention.

Target installation workflow:

git clone
configure
install
run

The project should not require a sysop to manually discover:

- package dependencies
- Apache configuration
- PHP modules
- SQLite requirements
- dashboard permissions
- service permissions
- filesystem ownership requirements
- RadioID database setup
- dashboard installation paths

Future development shall favor:

- automated installers
- setup scripts
- dependency validation
- installation verification

Planned installation scripts:

scripts/install-deps.sh
scripts/install-dashboard.sh
scripts/setup-radioid-db.sh
scripts/install-service.sh
scripts/check-install.sh

Expected dependency coverage:

- URFD
- TCD
- Apache2
- PHP
- PHP SQLite support
- SQLite3
- Dashboard files
- Dashboard permissions
- RadioID database
- Systemd services
- HTTPS support

Expected validation coverage:

[PASS] URFD present
[PASS] TCD present
[PASS] Apache2 running
[PASS] PHP SQLite available
[PASS] Dashboard installed
[PASS] RadioID database present
[PASS] XML status readable
[PASS] Service installed
[PASS] HTTPS configured

Long-term objective:

Reduce installation effort from hours of troubleshooting to a repeatable scripted deployment.


---

## New Checkpoint Title

Date:
2026-06-10

Summary:

- Item
- Item
- Item

Status:

Current state here.

Next:

- Next item
- Next item


---

## Dashboard and Deployment Framework Milestone

Date:
2026-06-10

Major accomplishment:

Project focus expanded from reflector functionality
to deployment and sysop usability.

Dashboard progress:

- New dashboard deployed at /urfd/
- Separate sysop dashboard deployed at /urfd/sysop/
- Dashboard now reads live reflector data from /var/log/xlxd.xml
- Public dashboard layout finalized:
  - Last Heard
  - Connected Nodes
  - Linked Systems
- Protocol online/offline status indicators added
- Sysop dashboard displays:
  - URFD/TCD service status
  - Reflector uptime
  - Server uptime
  - CPU load
  - CPU temperature
  - Memory usage
  - Disk usage

RadioID / Lookup subsystem:

- SQLite database framework created
- radioid.sqlite stored under /var/lib/urfd-dashboard/
- DMR import validated:
  - 322,450 records imported
- NXDN import validated:
  - 16,441 records imported
- Total lookup database:
  - 338,891 records

Lookup validation:

AK7AN successfully resolved from database.

Deployment framework:

Added:

- scripts/setup-radioid-db.sh
- scripts/install-radioid-tools.sh
- scripts/install-radioid-timer.sh
- scripts/check-install.sh
- scripts/configure-reflector.sh

Validation system:

check-install.sh successfully validates:

- URFD
- TCD
- Apache2
- PHP
- SQLite3
- Dashboard
- HTTPS
- XML status feed
- RadioID database
- RadioID updater

Current validation result:

PASS: 26
WARN: 0
FAIL: 0

Project direction:

Goal is now a deployable reflector package
that can be installed and configured by a new sysop
with minimal manual intervention.

Planned:

- install-all.sh master installer
- automatic RadioID update integration
- dashboard callsign enrichment using SQLite lookup data
- continued URFD/XLX interlink improvements


---

## Checkpoint: Deployment Framework and Custom Dashboard Enhancements

Date: 2026-06-10

### Deployment Framework

Completed deployment framework for new sysop installations.

Added:

- install-all.sh
- scripts/install-deps.sh
- scripts/install-dashboard.sh
- scripts/setup-radioid-db.sh
- scripts/install-radioid-tools.sh
- scripts/install-radioid-timer.sh
- scripts/configure-reflector.sh
- scripts/check-install.sh

Validation:

- Shell syntax checks passed
- Installer framework committed
- Deployment framework committed to main

Commit:

- 3d10075 Add deployment installer framework

### Dashboard Direction Clarification

Important project decision:

The project is NOT modifying or extending the original XLXD dashboard.

Development is focused on the new custom URFD dashboard located at:

    dashboard/index.php
    dashboard/sysop/index.php

The legacy XLXD dashboard code remains present in the repository for reference and compatibility purposes but is not the primary development target.

Future dashboard work should be performed against the custom dashboard unless a specific reason exists to modify the legacy dashboard.

### Public Dashboard Improvements

Added operator name enrichment using RadioID SQLite lookups.

Last Heard now displays:

- Callsign
- Operator Name
- Via Node
- Module
- Via Peer

Commit:

- ec82dc6 Add operator names to public last heard

### Active Streams Section

Original placeholder:

- D-Star 0
- DMR 0
- YSF 0
- NXDN 0
- P25 0
- M17 0

Replaced with recent activity view using XML node information.

Current implementation:

- Parses NODE entries from xlxd.xml
- Displays recent node activity
- Uses LastHeardTime
- Active window = 120 seconds

Current limitation:

The XML feed does not expose actual stream lifecycle information.

Current display is therefore:

"Recent Node Activity"

rather than true active transcoding streams.

Future enhancement:

Add native URFD XML reporting for active streams including:

- Callsign
- Protocol
- Module
- Start Time
- Duration

Commit:

- 4bd45e2 Show recent active node streams on dashboard

### Automatic Dashboard Refresh

Added automatic browser refresh.

Current refresh interval:

- 30 seconds

Implementation:

<meta http-equiv="refresh" content="30">

Commit:

- 9496f45 Add public dashboard auto refresh

### RadioID Integration Status

SQLite database operational.

Validated:

- DMR import
- NXDN import
- 338,891 records loaded

Dashboard currently uses RadioID database for:

- Operator name enrichment

Future possibilities:

- Sysop city/state display
- Numeric ID display
- Protocol-specific lookup tools

### Current Priorities

1. Complete install-all.sh deployment workflow
2. Improve RadioID automation and maintenance
3. Expand custom dashboard functionality
4. Enhance URFD/XLX interlink operation
5. Investigate true active stream reporting from URFD


---

## Checkpoint: Monit Remote Maintenance Integration

Date: 2026-06-10

Monit was installed and validated as a remote sysop maintenance tool.

Purpose:

- Remote service monitoring
- Remote service restart
- Server health visibility
- Optional administrative recovery actions

Architecture decision:

The custom URFD sysop dashboard should not directly perform privileged restart/reboot actions.

Instead:

- Custom sysop dashboard provides status visibility
- Monit provides authenticated service maintenance controls
- Apache HTTPS reverse proxy exposes Monit securely
- Monit itself binds to localhost

Current Monit access model:

- Apache reverse proxy path: /monit/
- Apache Basic Auth protects access
- Monit web UI listens on 127.0.0.1:2812
- Username/password currently configured locally

Important deployment requirement:

Monit credentials must NOT be hardcoded in installer scripts.

Future installer behavior:

During install-all.sh or install-monit.sh, prompt the sysop for:

- Monit username
- Monit password
- Apache Basic Auth username
- Apache Basic Auth password

Recommended simplification:

Use one shared credential pair for both Apache Basic Auth and Monit internal auth unless the sysop chooses otherwise.

Example prompt flow:

- Enter Monit/admin username
- Enter Monit/admin password
- Confirm password

The installer should then generate:

- /etc/apache2/.htpasswd-monit
- /etc/monit/conf-enabled/urfd-monit-webui
- /etc/apache2/conf-available/urfd-monit.conf
- /etc/monit/conf-enabled/urfd-services

Current monitored URFD processes:

- /home/ed/urfd/reflector/urfd
- /usr/local/bin/tcd

Current service control target:

- urfd-tcd.service

Dashboard direction:

The sysop dashboard should provide a link to the Monit dashboard for maintenance actions.

No restart or reboot buttons should be added directly to dashboard PHP at this stage.

Status:

Monit access validated.
Remote dashboard access validated.
URFD process monitor corrected from pidfile monitoring to process matching.

---

## Checkpoint: Monit Integration and Remote Sysop Maintenance

Date: 2026-06-10

### Objective

Provide remote maintenance and recovery capability for reflector sysops without embedding privileged restart controls directly into the custom dashboard.

### Architecture

Custom Dashboard:

- Status monitoring
- Reflector visibility
- Protocol visibility
- Sysop operational visibility

Monit:

- Service monitoring
- Service restart
- Process monitoring
- Resource monitoring
- Maintenance interface

### Security Model

Monit web interface:

- Bound to localhost
- Accessed through Apache reverse proxy
- HTTPS protected
- Authenticated access required

Current URL:

    /monit/

Dashboard integration:

Custom Sysop Dashboard now provides:

- Maintenance Tools section
- Monit Dashboard link

### Monitored Components

Current process monitoring:

- URFD
- TCD

Current service control target:

- urfd-tcd.service

Current system monitoring:

- CPU load
- Memory usage

Future monitoring candidates:

- Disk usage
- XML feed freshness
- RadioID update status
- Apache service state

### Installer Integration

Monit is now considered a supported deployment component.

Added:

- scripts/install-monit.sh

Installer workflow now includes:

- Dependency installation
- Dashboard installation
- RadioID installation
- RadioID update automation
- Monit installation
- Reflector configuration
- Validation

### Credential Handling

Installer requirement:

Monit credentials must be generated during installation.

Installer prompts should request:

- Monit username
- Monit password

The installer automatically generates:

- Apache Basic Auth credentials
- Monit web credentials

No usernames or passwords should be hardcoded.

### Validation Coverage

check-install.sh now validates:

- Monit installed
- Monit running
- Monit configuration present
- Apache proxy configuration present
- Authentication file present
- Local Monit web service responding

### Future Improvement

Current Monit process definitions contain development-path references.

Future work:

Replace hardcoded path assumptions with deployment-aware process detection.

Example:

Current:

    /home/ed/urfd/reflector/urfd

Future:

    Automatically discover installed URFD path

### Status

Monit integration complete.

Remote maintenance access validated.

Sysop dashboard integration validated.

Monit is now an official supported component of the URFD_XLX_Interlink deployment framework.


---

## Project Direction Clarification

Date: 2026-06-10

### XLX Interlink Policy

URFD_XLX_Interlink is intended to operate as a multi-mode reflector platform with reflector-to-reflector interconnection.

Supported architecture:

    Radio / Repeater / Hotspot
               ↓
         URFD Reflector
               ↓
         XLX Interlink
               ↓
       Other Reflectors

Supported:

- URFD reflector services
- XLX interlinking
- D-Star
- DMR
- YSF
- NXDN
- P25
- M17
- TCD transcoding
- Dashboard integration
- Monit integration

Not Supported:

- BrandMeister DMR Master operation

Rationale:

- Avoids port 10002 conflicts
- Simplifies deployment
- Simplifies support
- Keeps project focused on reflector services
- Provides consistent sysop experience

Future installer and documentation should assume XLX Interlink as the supported interconnect model.

BrandMeister integration should not be added to installer workflows or deployment documentation.

This is an intentional project design decision.

Status:

Approved.

---

## Clarification: XLX Calling Home Integration Approach

Date: 2026-06-11

The XLX calling-home / keepalive host-file item should not automatically become a separate project subsystem.

Current thinking:

This appears to be leftover behavior from the legacy XLXD/Luc dashboard and XLX ecosystem configuration.

Preferred approach:

Incorporate any required calling-home / host-file configuration into the existing deployment and configuration workflow.

Primary scripts to review/update first:

- install-all.sh
- scripts/configure-reflector.sh
- scripts/check-install.sh
- scripts/install-dashboard.sh

Only create a separate script if the implementation becomes large enough to justify it.

The goal is:

- Avoid unnecessary extra processes
- Avoid duplicating legacy XLXD behavior blindly
- Reuse the existing installer/configuration framework
- Keep calling-home optional and sysop-controlled
- Keep the custom dashboard as the primary dashboard target

Important distinction:

The legacy XLXD dashboard files may contain useful configuration references, especially:

    dashboard/pgs/config.php

but they should be treated as reference material, not as the primary development target.

Next review should determine:

- Which config.php values still matter for URFD_XLX_Interlink
- Which values are only legacy dashboard leftovers
- Whether calling-home behavior is required for XLX interlink compatibility
- Whether host/hash-file generation belongs in configure-reflector.sh
- Whether check-install.sh should validate required host-file/calling-home configuration

Installer default:

Calling-home should remain disabled unless the sysop explicitly enables it.

Status:

Needs review after long weekend trip.

---

## XLX Calling Home Integration Framework

Date: 2026-06-11

Objective:

Integrate XLX Calling Home support into the URFD deployment
framework while maintaining compatibility with existing XLXD
directory listings and host-file ecosystem updates.

Design Decisions:

Calling Home remains:

- Optional
- Disabled by default
- Sysop controlled

Installer now prompts:

- Enable XLX Calling Home
- Directory publishing participation

Calling Home state storage:

Created reflector-owned state directory:

    /var/lib/urfd

Calling Home files:

    /var/lib/urfd/callinghome.hash
    /var/lib/urfd/lastcallhome

Reasoning:

Calling Home identity belongs to the reflector,
not the dashboard subsystem.

Hash ownership:

    root:root
    600 permissions

Legacy XLXD Migration Support:

Installer now detects:

    /xlxd-ch/callinghome.php

If present:

Sysop is prompted whether to reuse the
existing XLXD Calling Home hash.

Reuse preserves:

- Existing XLX directory listing identity
- Existing reflector registration
- Existing host-file ecosystem continuity

New installations:

Generate a new random Calling Home hash.

Dashboard Configuration:

Added support for:

    CALLING_HOME_ENABLED
    CALLING_HOME_DASHBOARD_URL
    CALLING_HOME_API_URL
    CALLING_HOME_COUNTRY
    CALLING_HOME_COMMENT
    CALLING_HOME_OVERRIDE_IP
    CALLING_HOME_INTERLINK_FILE
    CALLING_HOME_HASH_FILE
    CALLING_HOME_LAST_FILE

Stored in:

    /etc/urfd-dashboard/dashboard.conf

Calling Home Publisher:

Added:

    dashboard/bin/urfd-callinghome

Purpose:

Reuses LX1IQ XLXD Calling Home API format.

Publisher generates:

    <query>CallingHome</query>
    <reflector>...</reflector>
    <interlinks>...</interlinks>

and submits to:

    http://xlxapi.rlx.lu/api.php

Compatibility Goal:

Maintain XLXD API compatibility while
remaining integrated into the URFD
deployment framework.

Systemd Integration:

Added:

    scripts/install-callinghome-timer.sh

Installs:

    urfd-callinghome.service
    urfd-callinghome.timer

Timer interval:

    OnBootSec=2min
    OnUnitActiveSec=10min

Installer Integration:

Added Calling Home timer installation to:

    install-all.sh

Dashboard Installation:

Added deployment of:

    /usr/local/bin/urfd-callinghome

Validation Integration:

check-install.sh now validates:

- Calling Home enabled/disabled state
- Dashboard URL presence
- API URL presence
- Hash file readability
- Interlink file readability
- Publisher installation
- Systemd timer installation
- Systemd timer enablement

Outstanding Review Items:

- Eliminate duplicate identity prompts
- Read Callsign from urfd.ini
- Read Country from urfd.ini
- Read Sponsor from urfd.ini
- Read DashboardUrl from urfd.ini

Desired final architecture:

    reflector/urfd.ini
        ↓
    Reflector identity

    dashboard.conf
        ↓
    Calling Home behavior

Current Status:

Framework implemented.

Pending live validation against XLX API.

