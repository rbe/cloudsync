# cloudsync

macOS orchestrator for [rclone](https://rclone.org) jobs between iCloud, NextCloud, Filen, and OneDrive.

iCloud is read from local paths under `~/Library/Mobile Documents`, not rclone's `iclouddrive` backend. Stock `/bin/bash` 3.2 is enough — Homebrew is not required.

## Quick start

From this directory:

```bash
./cloudsync setup
```

That will:

- symlink `~/.local/bin/cloudsync` to this script
- install rclone at `~/.local/bin/rclone` (even if Homebrew already has one — that copy is the Full Disk Access target; `cloudsync setup --upgrade` refreshes it)
- seed `~/.config/cloudsync/` from `examples/` without overwriting files you already have

`make setup` does the same thing. Shipping plan: [docs/waves.md](docs/waves.md) (Wave 1 now).

If `~/.local/bin` is not **first** on your PATH, add this to `~/.zprofile` and open a new terminal:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### After setup

1. **Remotes:** `rclone config` — add NextCloud / Filen / OneDrive. Skip this if every job is local or iCloud-only.
2. **Full Disk Access:** grant it to **`~/.local/bin/rclone`** (confirm with `cloudsync doctor`).  
   System Settings → Privacy & Security → Full Disk Access.  
   Without this, iCloud looks empty and a `sync` job would try to wipe the destination; cloudsync aborts instead. Homebrew rclone is the wrong target — FDA on that path breaks after `brew upgrade rclone`.
3. **Jobs:** `cloudsync edit` — columns are **TAB**-separated. Uncomment an example and fix remote names and paths.
4. **Preview:** `cloudsync dry <job|all>`
5. **Run:** `cloudsync run <job|all>`

`cloudsync help` lists every command.

## Commands

| Command | Purpose |
| --- | --- |
| `setup [--upgrade]` | rclone at `~/.local/bin/rclone` (FDA target) + seed config |
| `dry <job\|all>` | preview, no writes |
| `run <job\|all> [--force]` | real run (`--force` skips the safety gate) |
| `resync <job>` | first-time bisync baseline |
| `status` / `verify` / `logs` / `doctor` | inspect last run, destination, logs, FDA |
| `edit` | job map in `$EDITOR` |
| `list [jobs\|backups\|icloud-apps]` | job map, destination snapshots, iCloud containers |
| `schedule install …` | launchd (`hourly`, `daily HH:MM`, or interval seconds) |
| `clean logs` / `clean backups` | prune local logs or destination backup snapshots |

Bare `cloudsync` opens an interactive menu if [fzf](https://github.com/junegunn/fzf) is installed; otherwise it prints the job list. fzf is optional.

## Job map

`~/.config/cloudsync/jobs.tsv` — **one TAB between columns**, not spaces:

```
name<TAB>mode<TAB>source<TAB>dest<TAB>[extra rclone flags]
```

| mode | Behaviour |
| --- | --- |
| `copy` | add/update only; never deletes on dest |
| `sync` | dest mirrors source; deleted/overwritten files go to `.cloudsync-backups/` |
| `bisync` | two-way; run `cloudsync resync <name>` once before the first `run` |

Paths:

- `iCloudDocs/…` — iCloud Drive files (`com~apple~CloudDocs` only)
- `iCloudAll/…` — whole `Mobile Documents` tree (Finder's merged iCloud Drive)
- `Remote:path` — rclone remote
- `~/…` or `/abs` — local

In extra flags, `@prefetch` runs `brctl download` so dataless iCloud files become real bytes. A leading `~/` on a flag argument is expanded (rclone will not). See `examples/jobs.tsv` and `examples/icloud.filter`.

## Safety

On real `sync` / `bisync` runs, cloudsync aborts if a side lists 0 files (empty or unreadable — the usual Full Disk Access miss), or if a `sync` would delete more than `MAX_DELETE` files (default 50). Override with `cloudsync run <job> --force`.

Sync backups on the destination are **not** auto-pruned (`cloudsync clean backups`). Per-run logs are pruned after each run unless `AUTO_CLEAN=0` in the config file.

## Files

| What | Where |
| --- | --- |
| Job map | `~/.config/cloudsync/jobs.tsv` |
| Optional overrides | `~/.config/cloudsync/config` (sourced as bash) |
| Logs | `~/Library/Logs/cloudsync/` |
| State / locks | `~/.local/state/cloudsync/` |
| Sync backups | `<dest>/.cloudsync-backups/<job>/<timestamp>/` |

Scheduled runs use a LaunchAgent whose PATH includes `~/.local/bin`, so they find the rclone that `setup` installed. Terminal often already has Full Disk Access; launchd does not inherit it — grant FDA to **`~/.local/bin/rclone`**, then `cloudsync schedule kick` and `cloudsync status` to confirm.

## License

MIT. See [LICENSE](LICENSE).

