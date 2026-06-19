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


---

## XLX Calling Home Integration Completed

Date: 2026-06-11

Goal:

Implement XLXD-compatible Calling Home support for URFD_XLX_Interlink while preserving compatibility with existing XLX directory listings and host-file generation.

Implementation:

Added:

- dashboard/bin/urfd-callinghome
- scripts/install-callinghome-timer.sh

Installer integration:

- install-dashboard.sh now installs:
  - /usr/local/bin/urfd-callinghome

- install-all.sh now installs:
  - Calling Home timer/service

Dashboard configuration:

Added support for:

- CALLING_HOME_ENABLED
- CALLING_HOME_DASHBOARD_URL
- CALLING_HOME_API_URL
- CALLING_HOME_COUNTRY
- CALLING_HOME_COMMENT
- CALLING_HOME_OVERRIDE_IP
- CALLING_HOME_INTERLINK_FILE
- CALLING_HOME_HASH_FILE
- CALLING_HOME_LAST_FILE

Hash handling:

New installations:

- Generate new random Calling Home hash

Legacy XLXD upgrades:

- Detect:
  /xlxd-ch/callinghome.php

- Offer sysop option to reuse existing hash

Purpose:

- Preserve existing XLX directory identity
- Avoid 72-hour stale listing timeout
- Allow seamless XLXD -> URFD migration

Active system validation:

Legacy hash imported:

    09pHYL2xfik6uDAX

Stored at:

    /var/lib/urfd/callinghome.hash

Permissions:

    root:root
    0600

Calling Home publisher validated:

    [PASS] XLX Calling Home published: URF277

Timer:

    urfd-callinghome.timer

Publishing interval:

    Every 10 minutes

Dashboard visibility:

Sysop dashboard now displays:

- Calling Home enabled/disabled state
- Timer state
- Hash file protection status
- Hash file path
- Last successful publish timestamp
- Interlink file status

Apache/dashboard cleanup:

Public dashboard moved to root URL.

Previous:

    https://xlx277.bitbybithams.com/urfd/

Current:

    https://xlx277.bitbybithams.com/

Sysop dashboard:

    https://xlx277.bitbybithams.com/sysop/

Apache DocumentRoot:

    /var/www/html/urf/urfd

Calling Home interlink file:

Moved from development path:

    /home/ed/urfd/reflector/urfd.interlink

To deployment path:

    /usr/local/etc/urfd.interlink

Reason:

- Readable by www-data
- Suitable for production deployment
- Matches installer expectations

Current status:

Calling Home framework complete and operational.

Validation:

- Publisher functional
- Timer functional
- Dashboard integration functional
- Legacy hash migration functional
- XLXD API compatibility retained

Commit history:

0b6a392 Add XLX Calling Home integration framework
81ecaf4 Fix Calling Home reflector identity parsing
749275e Show XLX Calling Home status on sysop dashboard

---

## RadioID Importer Enhancement

Date: 2026-06-11

Issue:

Operator names were not appearing for some DMR users.

Example:

    K4MMG

Dashboard showed:

    Callsign present
    Operator blank

Investigation:

RadioID SQLite contained:

    DMR | 3185130 | K4MMG

But:

    first_name = NULL
    last_name  = NULL

Source file:

    /var/lib/mmdvm/DMRIds.dat

Contained:

    3185130 K4MMG Rick

Root cause:

urfd-radioid-import only supported:

- CSV
- Semicolon-delimited records

DMRIds.dat uses whitespace-delimited format.

Fix:

Added:

    import_whitespace_simple()

Importer now detects:

    <id> <callsign> <name>

and imports:

- callsign
- first_name
- last_name

Validation:

Before:

    DMR|3185130|K4MMG||

After:

    DMR|3185130|K4MMG|Rick|

Result:

Public dashboard now correctly displays operator names for DMR users sourced from DMRIds.dat.

Commit:

fe3a17c Parse whitespace DMR ID files with operator names


---

## Checkpoint: Full Reflector Installer Direction

Date: 2026-06-15

### Goal Clarification

The installer goal is a complete reflector installation, not only dashboard and management tooling.

A new sysop should be able to start from a clean supported system and run:

    sudo ./install-all.sh

and end with a working URFD_XLX_Interlink reflector stack.

Target supported platforms:

- Debian 13
- Ubuntu
- Raspberry Pi OS / Raspberry Pi hardware

### Required Installed Stack

The installer should ultimately cover:

- URFD build and install
- TCD build and install
- URFD/TCD combined systemd service
- Apache2
- PHP
- SQLite
- Custom public dashboard
- Custom sysop dashboard
- RadioID database setup
- RadioID updater timer
- XLX Calling Home publisher
- XLX Calling Home timer
- Monit remote maintenance
- Validation through check-install.sh

### Installer Progress

Added:

- scripts/install-urfd.sh
- scripts/install-tcd.sh
- scripts/install-urfd-tcd-service.sh

install-all.sh now runs:

- scripts/install-deps.sh
- scripts/install-urfd.sh
- scripts/install-tcd.sh
- scripts/install-urfd-tcd-service.sh
- scripts/install-dashboard-config.sh
- scripts/install-dashboard.sh
- scripts/setup-radioid-db.sh
- scripts/install-radioid-tools.sh
- scripts/install-radioid-timer.sh
- scripts/install-monit.sh
- scripts/install-callinghome-timer.sh
- scripts/configure-reflector.sh
- scripts/check-install.sh

### URFD Installer

scripts/install-urfd.sh now:

- Builds URFD from local reflector/ source
- Installs urfd to /usr/local/bin/urfd
- Installs default config to /usr/local/etc/urfd.ini if missing
- Installs default interlink file to /usr/local/etc/urfd.interlink if missing
- Preserves existing production config files

### TCD Installer

scripts/install-tcd.sh now:

- Uses upstream TCD repository:
  https://github.com/nostar/tcd.git

- Expects TCD source beside URFD source:
  ../tcd

- Clones TCD if missing
- Builds TCD
- Installs tcd to /usr/local/bin/tcd
- Installs default config to /usr/local/etc/tcd.ini if missing

Important TCD source requirement:

TCD expects the URFD source tree to be available as a sibling path:

    ../urfd

because several TCD source files are symlinks to the adjacent URFD reflector source tree.

### Combined Service Installer

scripts/install-urfd-tcd-service.sh now:

- Creates /usr/local/bin/start-urfd-tcd.sh
- Creates /etc/systemd/system/urfd-tcd.service
- Uses production paths:
  - /usr/local/bin/urfd
  - /usr/local/etc/urfd.ini
  - /usr/local/bin/tcd
  - /usr/local/etc/tcd.ini
- Enables urfd-tcd.service

### Remaining Full-Install Blockers

The installer is closer to full-stack deployment, but not yet complete for a clean machine.

Remaining blockers:

1. libimbe_vocoder install/build
2. FTDI D2XX install per architecture
3. Raspberry Pi / ARM handling
4. check-install.sh validation updates for TCD installer
5. Fresh-machine install test

### Known Required Libraries

Current working system links TCD against:

- /usr/local/lib/libimbe_vocoder.so
- /usr/local/lib/libftd2xx.so

install-tcd.sh currently checks for these libraries and fails clearly if missing.

Future work should add installation or guided setup for:

- IMBE vocoder library
- FTDI D2XX library

### Current Status

URFD and TCD are now included in the installer flow.

The project direction is confirmed as:

    Full reflector appliance installer

not merely:

    Dashboard/support tooling installer

### Raspberry Pi 3B+ Full Installer Validation

Date: 2026-06-15

Objective:

Validate that a completely clean Debian 13 Raspberry Pi installation
can deploy URFD_XLX_Interlink using only:

    sudo ./install-all.sh

without requiring manual dependency discovery.

Hardware:

- Raspberry Pi 3B+
- 1 GB RAM
- USB SSD boot device
- Debian 13 (Trixie) arm64

System baseline:

Hostname:
    reflector

Operating System:
    Debian GNU/Linux 13 (trixie)

Kernel:
    6.18.29+rpt-rpi-v8

Architecture:
    arm64

Memory:
    905 MB RAM

Storage:
    117 GB root filesystem

Initial cleanup validation:

Verified system contained no:

- URFD
- TCD
- XLX
- DVSwitch
- MMDVM
- AllStar
- Asterisk
- Monit reflector services

System effectively represented a clean installation target.

SSH recovery:

Lost SSH credentials after extended inactivity.

Recovery process:

- Mounted Pi SSD on development workstation
- Verified hostname and users
- Verified ssh.service enabled
- Examined shadow password database
- Reset user password offline
- Restored SSH access

Validated:

    ssh ed@reflector.local

successfully authenticated.

Installer validation findings:

Issue #1

Missing package:

    nlohmann-json3-dev

Failure:

    nlohmann/json.hpp not found

Resolution:

Install:

    nlohmann-json3-dev

Future action:

Add to install-deps.sh

Issue #2

DHT dependency failure:

    opendht.h not found

Cause:

Default config:

    DHT = true

in reflector/urfd.mk

Resolution:

Changed:

    DHT = false

Future action:

Installer should disable DHT automatically
or install OpenDHT dependencies.

Issue #3

Missing CURL development headers.

Failure:

    curl/curl.h not found

Resolution:

Install:

    libcurl4-openssl-dev

Future action:

Add to install-deps.sh

Issue #4

Configuration files expected in:

    reflector/

but repository stores canonical copies under:

    config/

Failure:

    install: cannot stat reflector/urfd.ini

Resolution during test:

Copied:

    config/urfd.ini
    config/urfd.interlink
    config/urfd.blacklist
    config/urfd.whitelist

into reflector/

Future action:

install-urfd.sh should source configuration
files directly from config/.

Issue #5

IMBE installer validation failure.

Observed:

imbe_vocoder cloned and compiled successfully.

Installed:

    /usr/local/lib/libimbe_vocoder.a

Installer expected:

    libimbe_vocoder.so

Result:

    [FAIL] libimbe_vocoder not found after install

Cause:

ARM build generated static library only.

Future action:

install-imbe-vocoder.sh and check-install.sh
must accept either:

    libimbe_vocoder.a
    libimbe_vocoder.so

Current status:

Validated:

- Installer framework launches correctly
- Dependency discovery process working
- URFD compiles successfully on Raspberry Pi arm64
- inicheck builds successfully
- dbutil builds successfully
- IMBE vocoder compiles successfully
- SSH recovery procedures documented

Outstanding validation:

- FTDI D2XX installation on ARM
- TCD compilation on ARM
- Combined URFD/TCD service deployment
- Dashboard deployment validation
- RadioID database installation
- Calling Home timer validation
- Final check-install.sh validation

Project direction reaffirmed:

Goal is now a true turnkey deployment system.

Target outcome:

Fresh Debian 13 installation
+
git clone
+
sudo ./install-all.sh

Result:

Fully operational URFD reflector with:

- URFD
- TCD
- IMBE vocoder
- FTDI D2XX
- Dashboard
- Sysop dashboard
- RadioID database
- Calling Home
- Monit
- Systemd services

without manual intervention.

---

## Checkpoint: Public Dashboard Enhancements

Date: 2026-06-16

### Linked Repeaters / Nodes Section

Added new public dashboard section:

    Linked Repeaters / Nodes

Purpose:

Provide visibility into currently connected repeaters,
gateways, hotspots, and client nodes separately from
reflector-to-reflector links.

Dashboard layout now:

- Reflector Status
- Protocol Status
- Linked Systems
- Last Heard
- Linked Repeaters / Nodes
- Recent Node Activity

Displayed fields:

- Callsign
- Protocol
- Module
- IP Address (masked)
- Last Heard

### IP Address Privacy

Node IP addresses are no longer displayed in full.

Current format:

    *.*.37.195
    *.*.135.17

Purpose:

- Distinguish nodes
- Preserve operational visibility
- Avoid exposing full public IP addresses

### Node Activity Sorting

Linked Repeaters / Nodes table now sorts by:

    LastHeardTime descending

Result:

Most recently active nodes appear first.

Benefits:

- Easier monitoring
- Active systems immediately visible
- Better operational awareness

### QRZ Callsign Integration

Added clickable callsign links.

Applies to:

- Last Heard
- Linked Repeaters / Nodes
- Active Streams

Behavior:

Clicking a callsign opens:

    https://www.qrz.com/db/<CALLSIGN>

Callsign normalization added for:

- D-Star style callsigns
- Callsigns containing module suffixes
- Callsigns containing slash-delimited device names

Examples:

    AK7AN B
    AK7AN / ID31

correctly resolve to:

    AK7AN

for QRZ lookup purposes.

### Public Dashboard Status

Current Public Dashboard Features:

- Reflector Status
- Protocol Status
- Linked Systems
- Last Heard
- RadioID Operator Name Lookup
- QRZ Callsign Lookup Links
- Linked Repeaters / Nodes
- Recent Node Activity
- Auto Refresh

Status:

Feature complete and operational.


---

## Checkpoint: Public Dashboard Enhancements

Date: 2026-06-16

### Linked Repeaters / Nodes

Added new public dashboard section:

    Linked Repeaters / Nodes

Purpose:

Provide visibility into connected repeaters,
gateways, hotspots, and client nodes separately
from reflector-to-reflector links.

Displayed fields:

- Callsign
- Protocol
- Module
- Masked IP Address
- Last Heard

### Node Privacy

Node IP addresses are masked.

Display format:

    *.*.37.195
    *.*.135.17

Purpose:

- Preserve operational visibility
- Avoid exposing full public IP addresses

### Node Activity Sorting

Linked Repeaters / Nodes table now sorts by:

    LastHeardTime descending

Benefits:

- Most active systems appear first
- Easier operational monitoring
- Better visibility of current activity

### QRZ Integration

Added clickable callsign links.

Applies to:

- Last Heard
- Linked Repeaters / Nodes
- Active Streams

Behavior:

Callsigns open directly to:

    https://www.qrz.com/db/<CALLSIGN>

Callsign normalization supports:

- D-Star callsigns
- Callsigns with module suffixes
- Callsigns containing slash-delimited device names

Examples:

    AK7AN B
    AK7AN / ID31

resolve correctly to:

    AK7AN

for QRZ lookups.

### Dashboard Branding Support

Added configurable dashboard logo support.

Configuration:

    DASHBOARD_LOGO=/assets/logo.png

stored in:

    /etc/urfd-dashboard/dashboard.conf

Public and Sysop dashboards support optional
custom branding logos.

If no logo is configured, dashboards operate normally.

Intended uses:

- Club branding
- Reflector branding
- Organization logos
- Custom deployments

### Dashboard Visibility Improvements

Updated hyperlink colors for improved visibility
on dark dashboard themes.

QRZ callsign links now display using high-contrast
highlight colors for improved readability.

### Current Public Dashboard Features

- Reflector Status
- Protocol Status
- Linked Systems
- Last Heard
- RadioID Operator Lookup
- QRZ Callsign Links
- Linked Repeaters / Nodes
- Recent Node Activity
- Dashboard Branding Support
- Auto Refresh

Status:

Operational and deployed.


-------------------------------------------------------------------------------

## Checkpoint: Raspberry Pi Deployment Validation Complete

Date: 2026-06-16

Repository:
URFD_XLX_Interlink

Validation Platform:

- Raspberry Pi 3B+
- Debian 13 (trixie)
- ARM64 (aarch64)

Objective:

Validate complete deployment using installer framework on a clean
Raspberry Pi environment.

Results:

PASS: 53
WARN: 3
FAIL: 0

Validated Components:

Core Reflector:

- URFD builds successfully on ARM64
- URFD installs successfully
- URFD service framework validated

Transcoder:

- TCD builds successfully on ARM64
- TCD installs successfully
- TCD service integration validated

Vocoder Support:

- IMBE vocoder builds successfully
- FTDI D2XX installs successfully
- ThumbDV detection validated

Dual ThumbDV Validation:

Detected devices:

- D30G37BA
- D30G37AJ

Validated operation:

- D-Star ThumbDV assigned
- DMR/YSF/NXDN ThumbDV assigned
- TCD successfully connects to URFD
- Hybrid Transcoder starts successfully

Reflector Validation:

URFD successfully starts and listens on:

- DPlus
- DExtra
- DCS
- DMR
- YSF
- NXDN
- P25
- M17
- G3
- XLX Interlink

Dashboard Validation:

Validated:

- Public Dashboard deployment
- Sysop Dashboard deployment
- XML status generation
- Dashboard configuration
- Dashboard branding support

RadioID Validation:

Validated:

- SQLite database creation
- Importer installation
- Updater installation
- Timer installation

Monit Validation:

Validated:

- Monit installation
- Monit web interface
- Apache integration
- Authentication support

Calling Home Validation:

Validated:

- Publisher installation
- Timer installation
- Configuration framework

Installer Issues Found During Validation:

1. IMBE validation accepted only .so libraries

Fixed:
- Accept .so or .a

2. TCD installer did not deploy tcd.mk

Fixed:
- Deploy tcd.mk
- Deploy tcd.ini
- Deploy tcd.service

3. Dashboard timezone validation failure

Fixed:
- Accept valid zoneinfo entries

4. OpenDHT dependency handling

Decision:
- OpenDHT remains optional
- DHT disabled by default for installer deployments

5. URFD deployment path assumptions

Validated and corrected for installer deployment.

GitHub:

Commit:

f85370e
Fix Raspberry Pi ARM installer validation issues

Project Status:

Stable

Installer Framework:

Validated on Raspberry Pi ARM64.

Current Priority:

- Update RadioID database population workflow
- Review Monit Apache detection warning
- Optional HTTPS validation on fresh deployment
- Continue Calling Home integration testing


---

## Checkpoint: Native Sysop Service Controls and Monit Replacement

Date: 2026-06-18

Objective:

Replace Monit-based service action controls with native Sysop Dashboard
service controls that are secure, installer-supported, and simple for
sysops to use.

Project Direction:

Monit is no longer required for the supported service-control workflow.

The Sysop Dashboard now provides native service controls directly.

Core Reflector Controls:

Added dedicated Sysop Dashboard control for:

- URFD/TCD restart

Implemented with:

- CSRF protection
- POST-only service actions
- Allowlisted service names
- Restricted sudo helper
- Action logging

Files added:

- dashboard/sysop/service-control.php
- dashboard/bin/urfd-service-control
- scripts/install-service-controls.sh

Installed runtime files:

- /usr/local/bin/urfd-service-control
- /etc/sudoers.d/urfd-dashboard-service-control
- /var/log/urfd-dashboard-actions.log

Security Model:

Dashboard PHP does not run arbitrary commands.

The dashboard may only call root-owned helper scripts through a narrow
sudoers policy.

The helper only accepts allowlisted services.

Service actions are logged to:

    /var/log/urfd-dashboard-actions.log

Custom Service Controls:

Added configurable custom service controls backed by:

    /etc/urfd-dashboard/service-controls.conf

Config format:

    [Display Name]
    service=systemd-unit.service

Example:

    [YSFGateway]
    service=ysfgateway.service

    [Dire Wolf]
    service=direwolf.service

The dashboard reads this file and automatically displays restart buttons
for configured services.

Sysops may manually add non-ham-radio services by editing this file.

Ham Radio Service Discovery:

Added popup-based service discovery workflow.

Sysop Dashboard now includes:

    Find Ham Radio Services

Behavior:

- Opens service-discovery.php in a popup window
- Scans installed systemd service units
- Shows known ham radio stack services as checkboxes
- Checked services appear on the Sysop Dashboard
- Unchecked services are removed from dashboard display
- Save Changes updates service-controls.conf
- Popup closes automatically
- Parent dashboard refreshes automatically

Files added:

- dashboard/sysop/service-discovery.php
- dashboard/sysop/service-config.php
- dashboard/bin/urfd-service-config

Known discovered services include:

- MMDVM_Bridge
- Analog_Bridge
- MD380 Emulator
- DVSwitch
- YSFGateway
- NXDNGateway
- P25Gateway
- ircDDBGateway
- DStarRepeater
- MMDVMHost
- Dire Wolf

Important behavior:

The discovery workflow only manages known ham radio services.

Manual non-ham entries in service-controls.conf are preserved when
Save Changes is used.

Installer Integration:

install-all.sh now installs native service controls through:

    scripts/install-service-controls.sh

check-install.sh now validates:

- Service control helper
- Service config helper
- sudoers policy
- action log
- sysop control endpoint
- custom service controls config

Monit installer/check path was removed from the required install flow.

Validation:

Live validation completed successfully.

Results:

    PASS: 58
    WARN: 0
    FAIL: 0

Validated actions:

- URFD/TCD restart from Sysop Dashboard
- YSFGateway restart from Sysop Dashboard
- NXDNGateway restart from Sysop Dashboard
- Custom service discovery
- Checkbox add/remove workflow
- Popup close and parent dashboard refresh
- Action logging

Current Status:

Native Sysop Service Controls are feature-complete for current release.

Monit is no longer part of the required production architecture.


Sysop Dashboard User Management:

Added helper utility:

    /usr/local/bin/urfd-sysop-user

Supported commands:

    sudo urfd-sysop-user add USERNAME
    sudo urfd-sysop-user remove USERNAME
    sudo urfd-sysop-user list

Purpose:

Provide a simple administration interface for managing Sysop Dashboard
authentication accounts without requiring sysops to remember Apache
htpasswd command syntax.

Security Decision:

Sysop account management is intentionally not exposed through the web
dashboard.

Only administrators with server-level access may add or remove Sysop
Dashboard users.

This prevents delegated dashboard administrators from granting access
to additional users without approval from the primary system owner.

Authentication storage:

    /etc/apache2/.htpasswd-urfd-sysop

Status:

Implemented and validated.


---

## Dashboard Enhancement: Linked Systems Dashboard URLs

Implemented automatic clickable dashboard links in the Public Dashboard Linked Systems section.

Behavior:

- Linked peers are still read from:

    /var/log/xlxd.xml

- Dashboard now fetches XLX reflector directory data from:

    http://xlxapi.rlx.lu/api.php?do=GetReflectorList

- Directory data is cached locally at:

    /var/lib/urfd-dashboard/xlx-reflector-list.xml

- Cache refresh interval:

    24 hours

- Linked peer callsigns are matched against XLX directory reflector names.

- If a dashboardurl is found, the peer callsign is rendered as a clickable hyperlink.

- If no URL is available, the API is unreachable, or the reflector is not listed, the dashboard falls back to plain text.

Design decision:

This feature does not modify:

- urfd.interlink
- URFD protocol behavior
- reflector configuration format

The feature is dashboard-only and self-updating.

Validated:

- PHP syntax check passed
- Deployed dashboard update
- Linked Systems reflector dashboard hyperlinks confirmed working

