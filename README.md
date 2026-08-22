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
- download rclone into `~/.local/bin` if it is not already on PATH
- seed `~/.config/cloudsync/` from `examples/` without overwriting files you already have

`make setup` does the same thing.

If `~/.local/bin` is not on your PATH, add this to `~/.zprofile` and open a new terminal:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### After setup

1. **Remotes:** `rclone config` — add NextCloud / Filen / OneDrive. Skip this if every job is local or iCloud-only.
2. **Full Disk Access:** grant it to the rclone binary printed by `cloudsync doctor`.  
   System Settings → Privacy & Security → Full Disk Access.  
   Without this, iCloud looks empty and a `sync` job would try to wipe the destination; cloudsync aborts instead.
3. **Jobs:** `cloudsync edit` — columns are **TAB**-separated. Uncomment an example and fix remote names and paths.
4. **Preview:** `cloudsync dry <job|all>`
5. **Run:** `cloudsync run <job|all>`

`cloudsync help` lists every command.
