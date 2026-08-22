---
name: cloudsync-icloud-fulldiskaccess
description: cloudsync needs Full Disk Access to read iCloud; launchd does not inherit it
metadata: 
  node_type: memory
  type: project
  originSessionId: a662a17b-90a3-4eef-833e-fa4fcc83935b
---

Because cloudsync reads iCloud via local paths under `~/Library/Mobile Documents` (the active `icloud-to-nx` job uses `iCloudAll` = the whole tree), the **process that runs it must have macOS Full Disk Access** — otherwise iCloud reads fail with "Operation not permitted" and the folder appears empty.

**Why it matters:** an empty-looking source + `sync` mode = "delete the whole destination." Ralf's Terminal already has this access (manual runs work). **launchd agents do NOT inherit Full Disk Access by default**, so a scheduled run without it will (safely) hit the empty-source guard and ABORT rather than sync — visible in `~/Library/Logs/cloudsync/launchd.err.log`.

**How to apply:** grant Full Disk Access (System Settings → Privacy & Security → Full Disk Access) to the binary that reads iCloud — i.e. **rclone**.

**DONE (2026-06-20):** `/usr/local/bin/rclone` was granted FDA and verified working *in the launchd context* via a temporary probe agent running `cloudsync doctor` (iCloud read OK). Granting rclone alone was sufficient — `/bin/bash` was NOT needed. Use `cloudsync doctor` to re-check access; for a faithful launchd-context check run it through a probe LaunchAgent, not Terminal (Terminal always has access). See [[cloudsync-tool]].
