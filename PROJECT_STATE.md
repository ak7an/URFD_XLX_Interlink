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

