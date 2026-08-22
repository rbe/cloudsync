---
name: cloudsync-tool
description: "The cloudsync rclone orchestrator script — layout, modes, and safety design"
metadata: 
  node_type: memory
  type: project
  originSessionId: a662a17b-90a3-4eef-833e-fa4fcc83935b
---

Ralf's cloud-sync solution (project dir `/Users/rbe/project/ralfssync`, not a git repo).

- Real script lives in the project: `~/project/ralfssync/cloudsync` (bash 3.2-compatible), symlinked onto PATH at `~/.local/bin/cloudsync` (the active command; an older `~/bin/cloudsync` symlink no longer exists). Memory also lives in the project at `~/project/ralfssync/memory/`, with the Claude memory path `~/.claude/projects/-Users-rbe-project-ralfssync/memory` symlinked to it. The script self-locates `PROJECT_DIR` through the symlink (used for the launchd program path).
- Config/runtime use **standard OS locations** (not the project): job map `~/.config/cloudsync/jobs.tsv` (TAB-separated: name, mode, source, dest, extra), optional overrides file `~/.config/cloudsync/config` (sourced as bash; a commented template exists), logs `~/Library/Logs/cloudsync/`, state/locks `~/.local/state/cloudsync/`. All overridable via `XDG_CONFIG_HOME`/`XDG_STATE_HOME` or `CLOUDSYNC_*` env vars.
- Remotes already configured in rclone: `Filen:` (native filen, E2E), `RalfsNx:` (NextCloud WebDAV), `Ralfs OneDrive:` (onedrive). iCloud is reached via the **local path** under `~/Library/Mobile Documents` (NOT the iclouddrive backend). Important: `com~apple~CloudDocs` holds only the loose iCloud Drive files; each app keeps a SIBLING container (e.g. `iCloud~md~obsidian/Documents`, `com~apple~Preview/Documents`) and Finder merges them all into "iCloud Drive". Aliases: `iCloudDocs` = com~apple~CloudDocs only; `iCloudAll` = the whole Mobile Documents tree (all app containers). `cloudsync list icloud-apps` lists the containers. The `icloud-to-nx` job uses `iCloudAll` + `--filter-from ~/.config/cloudsync/icloud.filter` (keeps `com~apple~CloudDocs/**` and `*/Documents/**`, drops caches/.Trash) to mirror exactly Finder's view. Flag args beginning `~/` are expanded by the script.
- Modes per job: `copy` (add-only, never deletes), `sync` (mirror, deletes — kept in `<dest>/.cloudsync-backups/`), `bisync` (two-way). `@prefetch` token runs `brctl download` to materialize dataless iCloud files.
- bisync needs a one-time baseline: `cloudsync resync <job>` before the first `run` (and again only if bisync refuses because its baseline listings under `~/.cache/rclone/bisync/` are lost). Conflict resolution: during `resync` the **source column (path1) wins** conflicts (union otherwise); during normal `run` the **newer file wins** and the loser is kept renamed (`--conflict-resolve newer --conflict-loser pathname`). resync also passes the empty-source guard.
- Safety gate on real sync/bisync runs: aborts if source lists 0 files (empty/unreadable), and aborts if deletions would exceed `MAX_DELETE` (50). Bypass with `cloudsync run <job> --force`.

CLI is verb-first: `list jobs|backups|icloud-apps` (read), `clean logs|backups` (prune), plus `dry`/`run`/`resync`/`verify`/`status`/`edit`/`logs`/`doctor`/`schedule`. Bare `list`→jobs, bare `clean`→logs.

Reliability features: each real run records last-run state to `$STATE_DIR/status/<job>` (epoch, rc, duration, outcome, detail); `cloudsync status` shows it per job. On failure/abort, a macOS notification fires (`NOTIFY=auto` → only non-interactive/launchd runs; `always`/`never` configurable). `cloudsync verify <job|all> [--deep]` runs `rclone check --one-way` (default `--size-only` so it doesn't download dataless iCloud files; `--deep` compares hashes) applying the job's filters + backup-dir exclude. Non-interactive runs use `--stats=1m` (NOT `--stats-one-line`) so logs carry labeled Transferred:/Errors:/Deleted: lines that status/notify parse.

Housekeeping: `cloudsync clean logs` (auto-runs after each run) prunes local logs/state. `cloudsync list backups` and `cloudsync clean backups [--days N|--keep K] [--dry-run]` manage the sync backup-dir snapshots that live on the destination side at `<remote-or-$HOME>/.cloudsync-backups/<job>/<timestamp>/` — these are NOT auto-pruned (remote calls), default age cutoff `BACKUP_RETENTION_DAYS=90`.

Ralf wants ongoing **sync** (not copy) for iCloud → NextCloud. See [[cloudsync-icloud-fulldiskaccess]].
