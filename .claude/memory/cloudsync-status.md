---
name: cloudsync-status
description: "cloudsync deployment state — current jobs, schedule mode, pending baseline runs"
metadata: 
  node_type: memory
  type: project
  originSessionId: a662a17b-90a3-4eef-833e-fa4fcc83935b
---

Operational state of cloudsync (see [[cloudsync-tool]]). Verify live state with `cloudsync status` / `cloudsync list backups` before acting — this reflects the 2026-06-21 session.

**Current jobs** (`~/.config/cloudsync/jobs.tsv`, both one-way `sync`):
- `icloud-to-nx`: `iCloudAll` + `--filter-from ~/.config/cloudsync/icloud.filter` → `RalfsNx:Ralf-Backup/iCloud`. Backs up the full Finder "iCloud Drive" view (CloudDocs + every app's Documents).
- `nx-to-filen`: `RalfsNx:` (root) → `Filen:` (root). Ralf deliberately chose root-to-root full-account mirror (warned it deletes anything on Filen not on NextCloud).

**Schedule:** launchd agent `com.user.cloudsync` is installed in **manual** mode (`RunAtLoad` false, no interval) — runs `cloudsync run all` only via `cloudsync schedule kick`. To automate later: `cloudsync schedule install daily 03:00`.

**Pending before automating:** the first real baselines. `nx-to-filen` needs one `cloudsync run nx-to-filen --force` (large first-run deletions on Filen). `icloud-to-nx` switched source to `iCloudAll`, which reorganizes the existing backup (old CloudDocs files move under `com~apple~CloudDocs/`) — `cloudsync dry icloud-to-nx` first, then `--force` once if the delete-gate trips. After both baselines pass cleanly, flip the schedule to daily. Whether Ralf has run these yet is unconfirmed — check `cloudsync status`.
