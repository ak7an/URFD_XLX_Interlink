# PROJECT_STATE.md Reorganization Plan

This plan describes how to clean up `PROJECT_STATE.md` without losing useful
history. The goal is to make the file reliable as a session handoff document
while preserving implementation history in clearly labeled archive sections.

## Sections to Keep

Keep these as current-state or high-value historical sections, with light edits
for accuracy and placement.

- `Project`
- `Current Stable Release`
- `Custom Modifications`
  - `XLX Interlink Support`
  - `P25 Stability Fix`
  - `TCD Rebuild`
- `Service Layout`
- `Session Handoff Notes`
- `Dashboard Architecture Decision`
- `Dashboard Direction Clarification`
- `RadioID Importer Enhancement`
- `XLX Calling Home Integration Completed`
- `Native Sysop Service Controls and Monit Replacement`
- `Dashboard Enhancement: Linked Systems Dashboard URLs`
- `FTDI D2XX Installation Policy`
- `Installer Optional FTDI/TCD Handling`
- `Pi 3 Full-Stack Validation - FTDI/TCD/DVSI`
- `Roadmap: Documentation and Backup / Restore Framework`

Keep the backup/restore roadmap, but remove completed validation priorities from
its priority list.

## Sections to Archive

Move these into a clearly labeled historical archive, or delete if the project
does not need detailed chronology.

- `Dashboard Roadmap`
- `Known Issues`
- `Next Development Priorities`
- `Dashboard Technology Stack`
- `Dashboard Data Sources`
- `Dashboard Security Plan`
- `Version Roadmap`
- `Project Status Assessment`
- `Dashboard Development Checkpoint`
- `Deployment and Installation Philosophy`
- `New Checkpoint Title`
- `Dashboard and Deployment Framework Milestone`
- `Checkpoint: Deployment Framework and Custom Dashboard Enhancements`
- `Checkpoint: Monit Remote Maintenance Integration`
- `Checkpoint: Monit Integration and Remote Sysop Maintenance`
- `Clarification: XLX Calling Home Integration Approach`
- `XLX Calling Home Integration Framework`
- `Checkpoint: Full Reflector Installer Direction`
- `Raspberry Pi 3B+ Full Installer Validation`
- `Checkpoint: Raspberry Pi Deployment Validation Complete`
- `Raspberry Pi 3 Clean Install Validation Follow-up`
- `Installer Validation Update - 2026-06-20`
- `Dashboard Service Control Improvements - 2026-06-21`

These sections are useful as development history, but many contain stale
planning language, resolved blockers, or intermediate validation results.

## Sections to Merge

Merge repeated or overlapping material into single authoritative current-state
sections.

### Dashboard

Merge:

- `Dashboard Roadmap`
- `Dashboard Technology Stack`
- `Dashboard Data Sources`
- `Dashboard Security Plan`
- `Dashboard Development Checkpoint`
- `Dashboard and Deployment Framework Milestone`
- `Checkpoint: Deployment Framework and Custom Dashboard Enhancements`
- both `Checkpoint: Public Dashboard Enhancements` sections
- `Dashboard Enhancement: Linked Systems Dashboard URLs`

Into:

- `Current Dashboard Architecture`
- `Public Dashboard Features`
- `Sysop Dashboard Features`
- `Dashboard Data Sources and Runtime Paths`

### Installer

Merge:

- `Deployment and Installation Philosophy`
- `Checkpoint: Full Reflector Installer Direction`
- `Raspberry Pi 3B+ Full Installer Validation`
- `Checkpoint: Raspberry Pi Deployment Validation Complete`
- `Raspberry Pi 3 Clean Install Validation Follow-up`
- `Installer Optional FTDI/TCD Handling`
- `FTDI D2XX Installation Policy`
- `Installer Validation Update - 2026-06-20`
- `Pi 3 Full-Stack Validation - FTDI/TCD/DVSI`

Into:

- `Current Installer Architecture`
- `Optional FTDI/TCD Policy`
- `Validated Platforms`
- `Resolved Installer Defects`

### Monit and Service Controls

Merge:

- `Checkpoint: Monit Remote Maintenance Integration`
- `Checkpoint: Monit Integration and Remote Sysop Maintenance`
- `Native Sysop Service Controls and Monit Replacement`
- `Dashboard Service Control Improvements - 2026-06-21`

Into:

- `Current Service Control Architecture`
- `Historical Monit Evaluation`

The current section should state that native sysop service controls are the
supported production workflow and Monit is not required.

### Calling Home

Merge:

- `Clarification: XLX Calling Home Integration Approach`
- `XLX Calling Home Integration Framework`
- `XLX Calling Home Integration Completed`

Into:

- `Current XLX Calling Home Architecture`
- `Legacy XLXD Hash Migration`

### RadioID

Merge:

- RadioID notes from `Dashboard and Deployment Framework Milestone`
- `RadioID Integration Status`
- `RadioID Importer Enhancement`

Into:

- `Current RadioID Subsystem`
- `RadioID Importer History`

## Proposed New Structure

```markdown
# PROJECT_STATE.md

## Current State Summary

## Current Stable Release

## Validated Platforms

## Repository Architecture

## Core Reflector Architecture

### Supported Protocols

### XLX Interlink Support

### P25 Stability Fix

### TCD and Dual ThumbDV Support

## Runtime Service Layout

## Current Installer Architecture

### Installer Flow

### Optional FTDI/TCD Policy

### Validation Script

### Resolved Installer Defects

## Current Dashboard Architecture

### Public Dashboard

### Sysop Dashboard

### Dashboard Runtime Paths

## Current RadioID Subsystem

## Current XLX Calling Home Architecture

### Legacy XLXD Hash Migration

## Current Service Control Architecture

### Native Sysop Controls

### Custom Service Controls

### Sysop User Management

### Historical Monit Evaluation

## Current Known Issues

## Current Next Priorities

## Backup / Restore Roadmap

## Historical Archive

### Dashboard Development History

### Installer Validation History

### Calling Home Development History

### RadioID Development History

### Monit Development History
```

## Current-State Corrections to Make

- Replace dashboard `0%` and "not yet started" language with current custom
  dashboard status.
- State that native Sysop Dashboard service controls replaced Monit as the
  required production workflow.
- Remove `install-monit.sh` from the required `install-all.sh` flow.
- Keep Monit only as historical or optional tooling.
- Mark FTDI D2XX and TCD as optional. Missing FTDI/TCD should be warnings for
  non-transcoding installs.
- Clarify dashboard filesystem path versus served URL:
  `/var/www/html/urf/urfd` is the install path, while the public URL depends on
  Apache `DocumentRoot` or alias configuration.
- Replace old blocker lists with the latest Pi full-stack validation result.
- Keep Calling Home as implemented and optional, not as an open design question.
- Keep backup/restore as future roadmap work; do not mix it with already
  completed installer-validation tasks.

## Suggested Cleanup Order

1. Add the new top-level current-state sections.
2. Move obsolete planning sections into `Historical Archive`.
3. Merge duplicated dashboard sections.
4. Merge Calling Home framework/completed notes.
5. Merge Monit history with native service-control replacement.
6. Merge installer validation history and resolved defects.
7. Normalize URL/path language.
8. Rewrite `Current Known Issues` and `Current Next Priorities`.
9. Do a final pass for contradictions involving dashboard status, Monit,
   installer flow, FTDI/TCD optionality, and Calling Home status.
