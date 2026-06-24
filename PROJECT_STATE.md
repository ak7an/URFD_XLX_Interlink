# PROJECT_STATE.md

## Current State Summary

URFD_XLX_Interlink is currently a stable, deployable multi-protocol amateur
radio reflector platform based on URFD. The current project direction is a full
reflector appliance installer, not just dashboard/support tooling.

Current supported stack:

- URFD reflector services
- D-Star, DMR, YSF, NXDN, P25, M17, G3
- XLX reflector interlinking through Brandmeister-style transport handling
- Optional TCD transcoding with DVSI ThumbDV hardware and FTDI D2XX
- Custom public dashboard
- Custom Sysop Dashboard
- RadioID SQLite lookup subsystem
- Optional XLX Calling Home directory publishing
- Native Sysop Dashboard service controls
- Automated installer and validation tooling

Current production direction:

- Custom dashboard development happens in `dashboard/index.php` and
  `dashboard/sysop/index.php`.
- Legacy XLXD/URFD dashboard files remain for compatibility and reference, but
  are not the primary development target.
- Native Sysop Dashboard service controls are the supported production service
  control workflow.
- Monit was evaluated and validated historically, but is no longer required for
  the supported service-control workflow.
- FTDI D2XX and TCD are optional. URFD can operate as a reflector without
  hardware transcoding.
- Missing FTDI/TCD components should be WARN, not FAIL, for non-transcoding
  installs.
- XLX Calling Home is optional, disabled by default, and sysop controlled.

Current validated platforms:

- Debian 13 x86_64
- Debian 13 arm64
- Raspberry Pi 3 Debian 13 arm64

Current full-stack Raspberry Pi validation:

- Raspberry Pi 3
- Debian 13 trixie arm64
- Kernel 6.12.x+rpt-rpi-v8
- URFD build/install validated
- IMBE vocoder build/install validated
- FTDI D2XX install validated with `libftd2xx-linux-arm-v8-1.4.35.tgz`
- TCD build/install validated
- `urfd-tcd.service` install/start validated
- Dual ThumbDV detection validated
- URFD/TCD combined service startup validated

Current known good operational state:

- P25 stable
- XLX188 linked
- XLX578 linked
- TCD operational when FTDI/DVSI hardware is present
- Dual ThumbDV configuration operational
- `urfd-tcd.service` operational when transcoding stack is installed
- HTTPS infrastructure available

## Current Runtime Paths and Services

Core runtime paths:

- `/usr/local/bin/urfd`
- `/usr/local/bin/tcd`
- `/usr/local/bin/start-urfd-tcd.sh`
- `/usr/local/etc/urfd.ini`
- `/usr/local/etc/urfd.interlink`
- `/usr/local/etc/urfd.whitelist`
- `/usr/local/etc/urfd.blacklist`
- `/usr/local/etc/urfd.terminal`
- `/usr/local/etc/tcd.ini`
- `/var/log/xlxd.xml`

Dashboard runtime paths:

- `/var/www/html/urf/urfd`
- `/etc/urfd-dashboard/dashboard.conf`
- `/etc/urfd-dashboard/radioid.conf`
- `/etc/urfd-dashboard/service-controls.conf`
- `/var/lib/urfd-dashboard/radioid.sqlite`
- `/var/lib/urfd-dashboard/xlx-reflector-list.xml`

Calling Home runtime paths:

- `/usr/local/bin/urfd-callinghome`
- `/var/lib/urfd/callinghome.hash`
- `/var/lib/urfd/lastcallhome`
- `/var/lib/urfd/callinghome.response`

Service-control runtime paths:

- `/usr/local/bin/urfd-service-control`
- `/usr/local/bin/urfd-service-config`
- `/usr/local/bin/urfd-sysop-user`
- `/etc/sudoers.d/urfd-dashboard-service-control`
- `/var/log/urfd-dashboard-actions.log`
- `/etc/apache2/.htpasswd-urfd-sysop`

Systemd units and timers:

- `urfd-tcd.service`
- `urfd-radioid-update.service`
- `urfd-radioid-update.timer`
- `urfd-callinghome.service`
- `urfd-callinghome.timer`

Dashboard URL note:

- The installed dashboard filesystem path is `/var/www/html/urf/urfd`.
- The public URL depends on Apache `DocumentRoot` or alias configuration.
- Fresh install validation checks `/urf/urfd/` and `/urf/urfd/sysop/`.
- Production notes also record deployments where `/var/www/html/urf/urfd` is the
  Apache `DocumentRoot`, making the public dashboard `/` and sysop dashboard
  `/sysop/`.

## Current Core Reflector Architecture

URFD builds from the local `reflector/` source tree and installs as
`/usr/local/bin/urfd`. The reflector publishes XLXD-compatible runtime XML to
`/var/log/xlxd.xml`, which is the primary dashboard data source.

Supported protocols:

- D-Star
- DMR
- YSF
- NXDN
- P25
- M17
- G3
- XLX Interlink

XLX Interlink support:

- `BMProtocol.cpp` was modified so XLX peers defined in `urfd.interlink` can be
  treated as Brandmeister-transport peers for reconnect handling.
- The project supports reflector-to-reflector XLX interlinking.
- The project does not support operating as a BrandMeister DMR master.

P25 stability fix:

- `P25Protocol.cpp` includes packet validation safeguards for invalid offsets,
  unknown packet types, buffer overruns, and stream termination handling.

TCD and ThumbDV support:

- TCD is optional and requires IMBE vocoder support plus FTDI D2XX.
- TCD source is cloned from `https://github.com/nostar/tcd.git` beside the URFD
  source tree.
- TCD expects the URFD source tree to be available as sibling path `../urfd`.
- The combined service starts URFD, then starts TCD so TCD can connect to URFD
  on `127.0.0.1:10100`.

Hardware details preserved from validation:

- ThumbDV serial `D30G37AJ`
- ThumbDV serial `D30G37BA`
- Validation recorded one device assigned for D-Star and one for DMR/YSF/NXDN.
- ThumbDV serial assignments varied during testing and should not be treated as
  fixed for every deployment.

## Current Installer Architecture

Master installer:

- `install-all.sh`

Current installer flow:

1. `scripts/install-deps.sh`
2. `scripts/install-urfd.sh`
3. `scripts/install-imbe-vocoder.sh`
4. `scripts/install-ftdi-d2xx.sh`
5. If FTDI D2XX succeeds:
   - `scripts/install-tcd.sh`
   - `scripts/install-urfd-tcd-service.sh`
6. If FTDI D2XX is unavailable, skip TCD and continue.
7. `scripts/install-dashboard-config.sh`
8. `scripts/install-dashboard.sh`
9. `scripts/setup-radioid-db.sh`
10. `scripts/install-radioid-tools.sh`
11. `scripts/install-radioid-timer.sh`
12. `scripts/install-service-controls.sh`
13. `scripts/install-callinghome-timer.sh`
14. `scripts/configure-reflector.sh`
15. `scripts/check-install.sh`

Installer policy:

- FTDI D2XX is proprietary and is not downloaded or redistributed by this
  project.
- Sysops who need ThumbDV/TCD support must manually place the correct FTDI D2XX
  archive beside the repository or in `/tmp` before running the installer.
- If the archive is absent or invalid, TCD and `urfd-tcd.service` are skipped.
- The rest of the reflector, dashboard, RadioID, service controls, Calling Home,
  configurator, and validation flow continues.

Validation policy:

- `scripts/check-install.sh` validates installed components.
- Missing optional FTDI/TCD items are warnings for non-transcoding installs.
- Missing `/var/log/xlxd.xml` is a warning when the reflector has not started
  yet.
- HTTPS detection may be a warning on fresh non-public deployments.

## Current Dashboard Architecture

The current dashboard is a custom PHP dashboard, separate from legacy XLXD/URFD
dashboard code.

Primary files:

- `dashboard/index.php`
- `dashboard/sysop/index.php`

Public Dashboard features:

- Reflector online/stale/offline state
- Protocol status
- Linked systems
- Clickable XLX reflector dashboard URLs when available
- Last Heard table
- RadioID operator name lookup
- QRZ callsign links
- Linked repeaters / nodes
- Masked node IP display
- Recent node activity
- Optional dashboard logo from `DASHBOARD_LOGO`
- Automatic browser refresh every 30 seconds

Important dashboard limitation:

- The XML feed does not expose true stream lifecycle information.
- The dashboard's active stream area is therefore recent node activity, not true
  stream start/duration reporting.

Sysop Dashboard features:

- URFD/TCD service state
- URFD and TCD process state
- Protocol UDP listener state
- DVSI ThumbDV detection
- Transcoder readiness
- Server uptime, load, memory, disk, and CPU temperature
- XLX Calling Home state
- Native Start/Stop/Restart controls
- Custom service controls
- Ham radio service discovery workflow

Design rationale:

- Do not heavily modify the stock URFD or legacy XLXD dashboard.
- Preserve compatibility with future URFD updates.
- Avoid maintaining large modifications against upstream dashboard code.
- Allow dashboard development without changing reflector packet paths.
- Keep legacy dashboard files as reference and compatibility material.

## Current RadioID Subsystem

RadioID provides local operator lookup data for dashboard enrichment.

Runtime database:

- `/var/lib/urfd-dashboard/radioid.sqlite`

Schema:

- `dashboard/sql/radioid_schema.sql`

Installed tools:

- `/usr/local/bin/urfd-radioid-import`
- `/usr/local/bin/urfd-radioid-update`

Configuration:

- `/etc/urfd-dashboard/radioid.conf`

Timer:

- `urfd-radioid-update.service`
- `urfd-radioid-update.timer`

Supported import formats:

- CSV
- Semicolon-delimited records
- Whitespace-delimited `DMRIds.dat` style records

Historical validation details:

- DMR import validated with 322,450 records.
- NXDN import validated with 16,441 records.
- Total lookup database validation recorded 338,891 records.
- AK7AN lookup was validated.
- K4MMG troubleshooting validated whitespace `DMRIds.dat` operator-name import.

## Current XLX Calling Home Architecture

XLX Calling Home is optional, disabled by default, and sysop controlled.

Publisher:

- `dashboard/bin/urfd-callinghome`
- Installed as `/usr/local/bin/urfd-callinghome`

Configuration:

- `/etc/urfd-dashboard/dashboard.conf`

State:

- `/var/lib/urfd/callinghome.hash`
- `/var/lib/urfd/lastcallhome`
- `/var/lib/urfd/callinghome.response`

Timer:

- `urfd-callinghome.service`
- `urfd-callinghome.timer`
- `OnBootSec=2min`
- `OnUnitActiveSec=10min`

Publisher behavior:

- Reads reflector identity from `urfd.ini`.
- Reads behavior from `dashboard.conf`.
- Reads interlink data from `/usr/local/etc/urfd.interlink` by default.
- Generates XLXD-compatible XML containing:
  - `<query>CallingHome</query>`
  - `<reflector>...</reflector>`
  - `<interlinks>...</interlinks>`
- Submits to `http://xlxapi.rlx.lu/api.php` by default.

Legacy XLXD migration:

- Installer detects `/xlxd-ch/callinghome.php` when present.
- Sysop may reuse an existing XLXD Calling Home hash.
- Reuse preserves XLX directory identity and helps avoid stale listing issues.
- Hash file permissions are `root:root` and `0600`.

Historical validation:

- Publisher returned `[PASS] XLX Calling Home published: URF277`.
- Legacy hash migration was validated.
- Dashboard visibility was validated.

## Current Service Control Architecture

Native Sysop Dashboard service controls are the supported production service
control workflow.

Monit status:

- Monit was historically installed and validated.
- Monit was later replaced by native Sysop Dashboard controls.
- Monit is no longer required for supported production service control.
- `monit.service` was disabled on production after it restarted URFD/TCD during
  intentional maintenance stops.

Native control security model:

- Dashboard actions are POST-only.
- CSRF protection is enforced.
- Actions are restricted to `start`, `stop`, and `restart`.
- Services are allowlisted.
- Dashboard PHP does not run arbitrary shell commands.
- Privileged work goes through restricted root-owned helpers.
- Actions are logged to `/var/log/urfd-dashboard-actions.log`.

Core control target:

- Dashboard service value: `urfd-tcd`
- Systemd unit: `urfd-tcd.service`

Custom controls:

- Config file: `/etc/urfd-dashboard/service-controls.conf`
- Format:

```ini
[Display Name]
service=systemd-unit.service
```

Service discovery:

- `dashboard/sysop/service-discovery.php`
- `dashboard/sysop/service-config.php`
- `/usr/local/bin/urfd-service-config`

User management:

- `/usr/local/bin/urfd-sysop-user`
- `sudo urfd-sysop-user add USERNAME`
- `sudo urfd-sysop-user remove USERNAME`
- `sudo urfd-sysop-user list`
- Authentication storage: `/etc/apache2/.htpasswd-urfd-sysop`

## Current Troubleshooting Reference

Installer and build issues:

- Missing `nlohmann-json3-dev` caused `nlohmann/json.hpp not found`.
- Missing `libcurl4-openssl-dev` caused `curl/curl.h not found`.
- OpenDHT dependency failure occurred when `DHT = true`; DHT is disabled by
  default for installer deployments.
- ARM IMBE builds may produce `/usr/local/lib/libimbe_vocoder.a` instead of a
  shared library. Validation accepts `.a` or `.so`.
- Bad FTDI downloads may be HTML/403 responses. Installer validates archives
  with `tar -tzf` before extraction.
- FTDI D2XX 1.4.35 ARMv8 archive layout required selecting versioned
  `libftd2xx.so.*` and top-level `ftd2xx.h` / `WinTypes.h`.
- Fresh default installs rewrite malformed `URF???` and `/home/user` paths in
  `urfd.ini` to deployment-safe defaults.

Runtime and dashboard issues:

- `/var/log/xlxd.xml` may be missing before reflector startup.
- RadioID database may exist but have no records if download URLs are blank.
- Calling Home may be disabled by design.
- Dashboard URL paths depend on Apache `DocumentRoot` or alias configuration.
- Native dashboard Stop/Start/Restart is preferred over automatic Monit restart
  behavior during maintenance.

Resolved defect references:

- DEFECT-011: FTDI D2XX download/redistribution policy.
- DEFECT-012: FTDI/TCD optional installer handling.
- DEFECT-015: `install-urfd.sh` used wrong `reflector/urfd.ini` source path.
- DEFECT-016: `install-urfd.sh` used wrong `reflector/urfd.interlink` source
  path.
- DEFECT-017: IMBE validation accepted only `.so`, not `.a`.
- DEFECT-018: unsafe hash generation pipeline under `set -euo pipefail`.
- DEFECT-019: FTDI downloads may return HTML/403 instead of an archive.
- DEFECT-020: obsolete FTDI 1.4.27 archive naming in installer text.
- DEFECT-021: FTDI D2XX 1.4.35 ARMv8 archive layout handling.
- DEFECT-022: fresh install left `URF???` and `/home/user` paths in `urfd.ini`.

## Current Known Issues

Current known issues should be kept short and limited to still-relevant items.

- DPlus disconnect/reconnect behavior should continue to be observed.
- XLX peer reconnect behavior should continue to be monitored.
- True active stream lifecycle reporting is not currently exposed by the XML
  feed; dashboard activity display is based on recent node activity.
- RadioID auto-population policy remains a deployment decision when URLs are
  blank.
- HTTPS and Sysop auth validation may need different behavior depending on
  Apache URL mapping and whether the deployment is public.

## Current Next Priorities

1. Keep current architecture and installation documentation synchronized.
2. Add or refine sysop-facing troubleshooting documentation.
3. Decide RadioID auto-population behavior for fresh installs.
4. Clarify HTTPS and Sysop auth validation policy for fresh non-public installs.
5. Implement backup/restore tooling.
6. Consider native URFD XML reporting for true active stream lifecycle data.

## Backup / Restore Roadmap

Backup / restore is planned but not implemented.

Proposed tools:

- `/usr/local/bin/urfd-backup`
- `/usr/local/bin/urfd-restore`

Backup should preserve:

- `/etc/urfd-dashboard/`
- `/usr/local/etc/urfd.ini`
- `/usr/local/etc/urfd.interlink`
- `/usr/local/etc/urfd.blacklist`
- `/usr/local/etc/urfd.whitelist`
- `/var/lib/urfd-dashboard/`
- `/var/lib/urfd/`
- Dashboard assets and custom branding
- Sysop authentication file
- Service control configuration
- Calling Home hash and state files
- Relevant systemd unit overrides if present

Backup should exclude:

- Compiled binaries
- Git repositories
- Build directories
- Logs
- Temporary cache files

Backup archive format:

- `urfd-backup-YYYY-MM-DD-HHMMSS.tar.gz`

Design principle:

- Backups should preserve identity and customization, not replace the installer
  or package management.

## Historical Archive

The original chronological project notes are preserved below for history and
troubleshooting context. Some archived sections contain obsolete planning notes
or intermediate validation states. The current-state sections above are the
authoritative handoff summary.

Archive sections include historical release labels such as
`v0.1-xlx-interlink`; current documentation reflects the latest validated
release state.

The empty placeholder section `New Checkpoint Title` was intentionally removed.

---

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
scripts/install-service-controls.sh
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

    dashboard/pgs/config.inc.php

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

Historical checkpoint recorded the `install-all.sh` flow here. The
authoritative current installer flow is maintained in `Current Installer
Architecture` above to avoid duplicated stale entries.

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


---

## Roadmap: Documentation and Backup / Restore Framework

Installer Documentation Direction:

After clean installer validation is complete, create sysop-facing documentation so the project is not a GitHub "wild goose chase" to install.

Planned documentation:

- Pre-Installation Checklist
- Installation Guide
- Sysop Operations Guide
- Troubleshooting Guide
- Quick Start guide

Pre-Installation Checklist should tell the sysop what information is needed before starting:

- Reflector number
- Reflector callsign
- Public IP address or FQDN
- Public dashboard URL
- Country code
- Directory comment
- Timezone
- Sysop dashboard username/password
- Whether XLX Calling Home should be enabled
- Whether DVSI ThumbDV / FTDI D2XX support will be installed
- Any desired interlink peers
- Any custom dashboard logo/branding

Goal:

A competent sysop should be able to go from fresh Debian install to working URFD reflector without searching the internet for missing setup details.

Backup / Restore Roadmap:

Add system customization backup and restore utilities.

Proposed tools:

    /usr/local/bin/urfd-backup
    /usr/local/bin/urfd-restore

Backup goal:

Preserve all sysop customization needed to recover from:

- Server crash
- Disk failure
- OS corruption
- Accidental reinstall
- Hardware replacement

Backup should include:

- /etc/urfd-dashboard/
- /usr/local/etc/urfd.ini
- /usr/local/etc/urfd.interlink
- /usr/local/etc/urfd.blacklist
- /usr/local/etc/urfd.whitelist
- /var/lib/urfd-dashboard/
- /var/lib/urfd/
- Dashboard assets and custom branding
- Sysop authentication file
- Service control configuration
- Calling Home hash and state files
- Relevant systemd unit overrides if present

Backup should exclude:

- Compiled binaries
- Git repositories
- Build directories
- Logs
- Temporary cache files

Backup archive format:

    urfd-backup-YYYY-MM-DD-HHMMSS.tar.gz

Archive should include a human-readable manifest:

    manifest.txt

Manifest should record:

- Backup date/time
- Hostname
- URFD version or git commit
- OS information
- Backup tool version
- Files included

Backup modes:

Manual backup:

    sudo urfd-backup

Backup to selected destination:

    sudo urfd-backup /path/to/backup/location

USB / removable media helper:

    sudo urfd-backup --usb

USB helper should search common mount locations:

    /media/*
    /mnt/*

and allow the sysop to select a mounted flash drive, USB SSD, or other removable storage.

Automatic backup:

Nightly backup is probably unnecessary because most important URFD data changes only when the sysop intentionally changes configuration.

Preferred automatic schedule:

- Optional monthly backup timer
- Installer prompt to enable or skip
- Store backups in:

    /var/backups/urfd/

- Keep approximately 12 monthly backups

Potential systemd timer:

    urfd-backup.timer
    urfd-backup.service

Dashboard integration:

Future Sysop Dashboard Maintenance section could include:

- Create Backup
- Download Latest Backup
- View Backup List
- Restore Backup

Dashboard actions should use the same restricted sudo helper model already used for service controls.

Restore goal:

Fresh Debian install plus repository clone should allow:

    sudo ./install-all.sh
    sudo urfd-restore urfd-backup-YYYY-MM-DD-HHMMSS.tar.gz

Expected result:

- Reflector configuration restored
- Interlinks restored
- Dashboard configuration restored
- Sysop users restored
- Calling Home identity restored
- Dashboard branding restored
- Service control customizations restored

Design principle:

Backups should preserve identity and customization, not replace the installer or package management.

Roadmap priority:

1. Finish Raspberry Pi clean installer validation
2. Fix installer defects
3. Build sysop installation documentation
4. Add urfd-backup / urfd-restore framework
5. Add optional monthly backup timer
6. Add Sysop Dashboard backup integration


Sysop Dashboard backup integration should include a simple clickable backup action.

Planned Sysop Dashboard backup link:

    Create Backup

Behavior:

- Visible in a Maintenance / Backup section
- Uses restricted sudo helper model
- Creates a timestamped URFD backup archive
- Stores archive in /var/backups/urfd/
- Shows success/failure status in dashboard
- Provides a download link to the latest backup when safe to expose
- Does not allow arbitrary file download paths

Security requirement:

The dashboard must not directly run tar, shell commands, or accept arbitrary backup destinations from the browser.

All backup actions should go through a root-owned helper such as:

    /usr/local/bin/urfd-backup

or a restricted dashboard wrapper.


-------------------------------------------------------------------------------
Raspberry Pi 3 Clean Install Validation Follow-up
Date: 2026-06-20
Platform: Raspberry Pi 3
OS: Debian 13 trixie arm64
-------------------------------------------------------------------------------

Clean repository fixes applied after Pi validation:

- Fixed configure-reflector.sh path assumptions.
- Guided Configurator now reads the default template from:

    config/urfd.ini

- Guided Configurator now generates:

    config/urfd.ini.generated

- Installer instructions now tell the sysop to install the generated file to:

    /usr/local/etc/urfd.ini

- Updated check-install.sh so optional FTDI D2XX / TCD stack items are reported
  as WARN instead of FAIL when that stack was intentionally skipped.

- Updated fresh-install XML validation so missing /var/log/xlxd.xml is WARN
  instead of FAIL when the reflector has not yet started.

Validation reference:

Clean Raspberry Pi installer validation reached:

    PASS: 44
    WARN: 18
    FAIL: 0

after optional-component validation logic was corrected.

Remaining policy decisions:

- Whether RadioID should auto-populate during install.
- Whether HTTPS should remain WARN on fresh non-public Pi installs.
- Whether Sysop auth validation should test HTTP, HTTPS, or both depending
  on Apache deployment state.

Status:

Pi installer validation is functionally successful.


-------------------------------------------------------------------------------
Installer Optional FTDI/TCD Handling
Date: 2026-06-20
-------------------------------------------------------------------------------

Resolved:

DEFECT-012

install-all.sh no longer treats FTDI D2XX, TCD, and the combined URFD/TCD
service as mandatory for the entire installer flow.

Behavior now:

- Attempt FTDI D2XX installation.
- If FTDI D2XX installs successfully:
  - Install TCD.
  - Install the combined URFD/TCD service.
- If FTDI D2XX is unavailable:
  - Warn the sysop.
  - Skip TCD.
  - Skip the combined URFD/TCD service.
  - Continue installing:
    - Dashboard configuration
    - Public dashboard
    - Sysop dashboard
    - RadioID database/tools/timer
    - Sysop service controls
    - XLX Calling Home timer
    - Guided Configurator
    - check-install.sh

Reason:

URFD can operate as a reflector without hardware DVSI/TCD support.

TCD remains dependent on FTDI D2XX, but the whole installer should not fail
when optional DVSI hardware support is unavailable.

Status:

Implemented.


-------------------------------------------------------------------------------
FTDI D2XX Installation Policy
Date: 2026-06-20
-------------------------------------------------------------------------------

Resolved by policy:

DEFECT-011

The FTDI D2XX driver is a proprietary third-party dependency.

Project decision:

URFD_XLX_Interlink will not automatically download or redistribute the FTDI
D2XX driver archive.

Supported behavior:

- Sysops who need hardware DVSI / ThumbDV / TCD support must manually download
  the correct Linux FTDI D2XX driver archive from FTDI.

- The archive may be placed beside the repository or in /tmp before running
  the installer.

- If the archive is not present:
  - install-ftdi-d2xx.sh reports that the archive was not found.
  - install-all.sh continues.
  - TCD and the combined URFD/TCD service are skipped.
  - check-install.sh reports FTDI/TCD items as WARN, not FAIL.

Reason:

URFD can operate as a reflector without hardware transcoding.

The installer should support non-transcoding deployments while still guiding
sysops who choose to add DVSI/TCD support.

Documentation requirement:

The installation manual must include a FTDI / ThumbDV / TCD section explaining:

- When FTDI D2XX is needed.
- Where to obtain the FTDI D2XX archive.
- Where to place the archive before installation.
- That TCD will be skipped if FTDI D2XX is unavailable.
- That WARN results for FTDI/TCD are acceptable on non-transcoding installs.

Status:

Policy accepted.


-------------------------------------------------------------------------------
Installer Validation Update - 2026-06-20
-------------------------------------------------------------------------------

Fresh Raspberry Pi clean install validation discovered and fixed additional
installer defects.

Validation platform:

    Raspberry Pi 3
    Debian 13 trixie arm64
    Fresh clone into ~/urfd

New defects fixed:

DEFECT-015
    scripts/install-urfd.sh attempted to install:

        reflector/urfd.ini

    Corrected to:

        config/urfd.ini

DEFECT-016
    scripts/install-urfd.sh attempted to install:

        reflector/urfd.interlink

    Corrected to:

        config/urfd.interlink

DEFECT-017
    scripts/install-imbe-vocoder.sh only validated:

        libimbe_vocoder.so

    Corrected to also accept:

        /usr/local/lib/libimbe_vocoder.a

DEFECT-018
    scripts/install-dashboard-config.sh used unsafe:

        tr | head -c

    under set -euo pipefail.

    Replaced with safe hash generation.

Clean install result after fixes:

    PASS: 41
    WARN: 18
    FAIL: 0

Conclusion:

    Installer completed end-to-end on a clean Raspberry Pi after these fixes.
    These fixes must be committed before final v1.0.1 validation.


-------------------------------------------------------------------------------
Dashboard Service Control Improvements - 2026-06-21
-------------------------------------------------------------------------------

Operational review after network-loop troubleshooting identified a problem
with Monit automatically restarting URFD/TCD when intentionally stopped by
the sysop.

Production server changes:

    monit.service disabled

Reason:

    Manual operational control is preferred over automatic restart during
    maintenance and troubleshooting.

Sysop Dashboard Improvements:

Added service control actions:

    Start
    Stop
    Restart

Previous behavior:

    Restart only

Updated components:

    dashboard/bin/urfd-service-control
    dashboard/sysop/service-control.php
    dashboard/sysop/index.php

Service helper now supports:

    start
    stop
    restart

for:

    urfd-tcd

and configured custom services.

Security model unchanged:

    CSRF protection retained
    sudoers restrictions retained
    service allow-list retained

URFD/TCD Service Improvements:

Updated installer-generated systemd service:

    scripts/install-urfd-tcd-service.sh

Added:

    SuccessExitStatus=143
    RestartPreventExitStatus=143

Result:

    Intentional service stop now reports:

        inactive (dead)

    instead of:

        failed

Validation:

    Dashboard Stop button validated
    Dashboard Start button validated
    Dashboard Restart button validated

Confirmed:

    URFD starts correctly
    TCD starts correctly
    Public dashboard reports OFFLINE when stopped
    Public dashboard returns ONLINE after restart


---

## Pi 3 Full-Stack Validation - FTDI/TCD/DVSI

Date: 2026-06-21

Platform:

- Raspberry Pi 3
- Debian 13 trixie arm64
- Kernel 6.12.x+rpt-rpi-v8

Validated:

- Fresh clone to ~/urfd
- URFD build/install
- IMBE vocoder build/install
- FTDI D2XX install using libftd2xx-linux-arm-v8-1.4.35.tgz
- TCD build/install
- urfd-tcd.service install
- Dual ThumbDV detection
- Hybrid Transcoder startup
- URFD/TCD combined service startup

ThumbDV devices detected:

- D30G37AJ
- D30G37BA

Runtime validation:

- D30G37AJ configured for D-Star
- D30G37BA configured for DMR/YSF
- TCD connected to URFD on 127.0.0.1:10100
- Hybrid Transcoder successfully started
- Reflector URF277 started and listening

Final successful status:

- urfd-tcd.service active running
- URFD running
- TCD running
- DVSI/FTDI USB devices detected

Installer defects found and patched:

DEFECT-019:

FTDI D2XX direct download cannot be assumed.
FTDI site may block command-line download attempts and return HTML/403 content.

Mitigation:

- Installer now validates archive with tar -tzf before extraction.
- Bad HTML downloads are rejected with a clear failure message.

DEFECT-020:

FTDI installer example referenced obsolete 1.4.27 archive naming.

Mitigation:

- Installer message now uses generic version placeholder:
  libftd2xx-linux-<arch>-<version>.tgz

DEFECT-021:

FTDI D2XX 1.4.35 ARMv8 archive layout required improved library/header selection.

Mitigation:

- Versioned libftd2xx.so.* is preferred.
- Plain libftd2xx.so is accepted as fallback.
- Top-level ftd2xx.h and WinTypes.h are selected instead of example copies.

DEFECT-022:

Fresh install left URF??? placeholder and /home/user file paths in urfd.ini.
URFD refused to start because URF??? is malformed.

Mitigation:

- Fresh default install now rewrites:
  - Callsign = URF277
  - WhitelistPath = /usr/local/etc/urfd.whitelist
  - BlacklistPath = /usr/local/etc/urfd.blacklist
  - InterlinkPath = /usr/local/etc/urfd.interlink
  - G3TerminalPath = /usr/local/etc/urfd.terminal
- Empty support files are created during install.

Current result:

Fresh Pi full-stack FTDI/TCD/DVSI validation passed after installer fixes.
