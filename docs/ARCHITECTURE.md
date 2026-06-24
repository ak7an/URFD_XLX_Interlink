# URFD_XLX_Interlink Architecture

This document summarizes the current repository architecture using the project
status and design notes from `README.md` and `PROJECT_STATE.md`.

## URFD Architecture

URFD_XLX_Interlink is a deployable multi-protocol amateur radio reflector
platform based on URFD. The core reflector is implemented in the `reflector/`
source tree and is built into the `urfd` binary.

The reflector supports:

- D-Star
- DMR
- YSF
- NXDN
- P25
- M17
- G3
- XLX Interlink

The reflector configuration is installed under `/usr/local/etc/`, with the
primary runtime files:

- `/usr/local/etc/urfd.ini`
- `/usr/local/etc/urfd.interlink`
- `/usr/local/etc/urfd.whitelist`
- `/usr/local/etc/urfd.blacklist`
- `/usr/local/etc/urfd.terminal`

URFD publishes runtime status through the XLXD-compatible XML status file:

- `/var/log/xlxd.xml`

That XML feed is the primary dashboard data source for reflector status, linked
systems, nodes, Last Heard entries, and activity display.

XLX interlink support is implemented by treating XLX peers defined in
`urfd.interlink` as Brandmeister-transport-style peers for reconnect handling.
The project direction explicitly supports reflector-to-reflector XLX
interlinking, but does not position URFD_XLX_Interlink as a BrandMeister DMR
master.

Transcoding is optional. When DVSI ThumbDV hardware and FTDI D2XX support are
available, TCD is built and installed alongside URFD. The combined service
starts URFD first, waits briefly, and then starts TCD so TCD can connect to
URFD on the local transcoder TCP port.

## Dashboard Architecture

The project uses a custom PHP dashboard rather than heavily modifying the stock
URFD or legacy XLXD dashboard. The custom dashboard lives under `dashboard/` and
is installed to:

- `/var/www/html/urf/urfd`

The main custom dashboard entry points are:

- `dashboard/index.php`
- `dashboard/sysop/index.php`

The legacy dashboard files under `dashboard/pgs/` and `dashboard/json/` remain
in the repository for compatibility and reference, but current development is
focused on the custom dashboard files.

The public dashboard is unauthenticated and displays:

- Reflector online, stale, or offline state
- Protocol status
- Linked systems
- Last Heard activity
- RadioID operator name lookup
- QRZ callsign links
- Linked repeaters and nodes
- Recent node activity
- Optional dashboard logo
- Automatic refresh

The public dashboard reads `/var/log/xlxd.xml` directly and uses
`/var/lib/urfd-dashboard/radioid.sqlite` for operator name enrichment.

The Sysop Dashboard is intended for administrative visibility without requiring
SSH access. It is protected by Apache Basic Authentication and displays:

- URFD/TCD service state
- URFD and TCD process state
- Protocol listener state
- DVSI ThumbDV detection
- Transcoder readiness
- Server uptime, load, memory, disk, and CPU temperature
- XLX Calling Home state
- Core and custom service controls

Dashboard configuration is stored in:

- `/etc/urfd-dashboard/dashboard.conf`

Dashboard runtime data is stored under:

- `/var/lib/urfd-dashboard/`

## RadioID Subsystem

The RadioID subsystem provides local operator lookup data for the dashboard. It
uses SQLite and is installed under:

- `/var/lib/urfd-dashboard/radioid.sqlite`

The schema is defined in:

- `dashboard/sql/radioid_schema.sql`

The database stores radio ID, callsign, optional name and location fields,
protocol, source file, and update timestamp.

RadioID tools are installed from:

- `dashboard/bin/urfd-radioid-import`
- `dashboard/bin/urfd-radioid-update`

The installer copies them to:

- `/usr/local/bin/urfd-radioid-import`
- `/usr/local/bin/urfd-radioid-update`

Download configuration is stored in:

- `/etc/urfd-dashboard/radioid.conf`

The updater supports separate DMR, NXDN, and P25 URL settings. Blank URLs are
skipped. The importer supports multiple source formats, including CSV,
semicolon-delimited files, and whitespace-delimited `DMRIds.dat` style files.

A systemd timer performs periodic updates:

- `urfd-radioid-update.service`
- `urfd-radioid-update.timer`

The public dashboard uses the RadioID database to enrich Last Heard entries with
operator names after normalizing callsigns.

## Calling Home Subsystem

XLX Calling Home is optional, disabled by default, and sysop controlled. It
publishes XLXD-compatible directory information for the reflector when enabled.

Calling Home behavior is configured in:

- `/etc/urfd-dashboard/dashboard.conf`

Calling Home state is reflector-owned and stored under:

- `/var/lib/urfd/`

Important files include:

- `/var/lib/urfd/callinghome.hash`
- `/var/lib/urfd/lastcallhome`
- `/var/lib/urfd/callinghome.response`

The publisher is:

- `dashboard/bin/urfd-callinghome`

The installer deploys it to:

- `/usr/local/bin/urfd-callinghome`

The publisher reads reflector identity from `urfd.ini`, reads behavior and
directory settings from `dashboard.conf`, reads interlink information from
`/usr/local/etc/urfd.interlink`, and submits an XLXD-compatible XML payload to
the configured API endpoint.

The payload includes:

- `<query>CallingHome</query>`
- `<reflector>...</reflector>`
- `<interlinks>...</interlinks>`

The default API endpoint is:

- `http://xlxapi.rlx.lu/api.php`

New installations generate a new Calling Home hash. Legacy XLXD migrations may
reuse an existing `/xlxd-ch/callinghome.php` hash to preserve directory
identity.

Periodic publishing is handled by:

- `urfd-callinghome.service`
- `urfd-callinghome.timer`

The timer runs shortly after boot and then periodically while enabled.

## Installer Architecture

The installer is designed to turn a clean supported system into a working
reflector stack with minimal manual discovery by the sysop.

The master installer is:

- `install-all.sh`

It requires root and runs the install scripts in a fixed order:

1. Install package dependencies.
2. Build and install URFD.
3. Build and install the IMBE vocoder.
4. Attempt FTDI D2XX installation.
5. If FTDI D2XX is available, build and install TCD and the combined service.
6. Install dashboard configuration.
7. Install dashboard files.
8. Create the RadioID SQLite database.
9. Install RadioID tools.
10. Install the RadioID update timer.
11. Install dashboard service controls.
12. Install the XLX Calling Home timer.
13. Run the guided reflector configurator.
14. Run installation validation.

The key installer scripts are:

- `scripts/install-deps.sh`
- `scripts/install-urfd.sh`
- `scripts/install-imbe-vocoder.sh`
- `scripts/install-ftdi-d2xx.sh`
- `scripts/install-tcd.sh`
- `scripts/install-urfd-tcd-service.sh`
- `scripts/install-dashboard-config.sh`
- `scripts/install-dashboard.sh`
- `scripts/setup-radioid-db.sh`
- `scripts/install-radioid-tools.sh`
- `scripts/install-radioid-timer.sh`
- `scripts/install-service-controls.sh`
- `scripts/install-callinghome-timer.sh`
- `scripts/configure-reflector.sh`
- `scripts/check-install.sh`

FTDI D2XX is a proprietary third-party dependency and is not downloaded or
redistributed by the project. Sysops who need ThumbDV/TCD support must place the
correct FTDI D2XX archive beside the repository or in `/tmp` before running the
installer. If FTDI D2XX is unavailable, the installer skips TCD and continues
with the reflector, dashboard, RadioID, service controls, and Calling Home
pieces.

Validation is performed by:

- `scripts/check-install.sh`

The validation script reports required component failures as failures and
optional FTDI/TCD items as warnings when that stack was intentionally skipped.

## Service Control Architecture

The Sysop Dashboard includes native service controls for controlled
administrative actions. This replaced Monit as the required production service
control workflow.

The service control architecture is intentionally narrow:

- Dashboard PHP uses POST requests only.
- Requests include CSRF validation.
- Requested actions are restricted to `start`, `stop`, and `restart`.
- Services are allowlisted.
- Privileged actions go through a root-owned helper.
- Actions are logged.

The web endpoint is:

- `dashboard/sysop/service-control.php`

The privileged helper is:

- `dashboard/bin/urfd-service-control`

It is installed to:

- `/usr/local/bin/urfd-service-control`

The installer creates a sudoers policy allowing the Apache user to run only the
restricted helper:

- `/etc/sudoers.d/urfd-dashboard-service-control`

Actions are logged to:

- `/var/log/urfd-dashboard-actions.log`

The built-in core control target is:

- `urfd-tcd`

which maps to:

- `urfd-tcd.service`

Custom service controls are configured in:

- `/etc/urfd-dashboard/service-controls.conf`

The custom service format is:

```ini
[Display Name]
service=systemd-unit.service
```

The Sysop Dashboard also includes a ham radio service discovery workflow that
can add or remove known amateur radio service units from the custom controls
file while preserving manually configured non-discovered entries.

Sysop Dashboard user accounts are managed from the server console, not through
the web interface. The helper utility is:

- `/usr/local/bin/urfd-sysop-user`

Supported commands are:

- `sudo urfd-sysop-user add USERNAME`
- `sudo urfd-sysop-user remove USERNAME`
- `sudo urfd-sysop-user list`

Authentication data is stored in:

- `/etc/apache2/.htpasswd-urfd-sysop`
