# Shipping waves

Four slices, all shipped. Each wave is still a production slice; later waves did not rewrite earlier ones.

## Wave 1 — FDA-stable rclone

Homebrew rclone lives in the Cellar. Full Disk Access is granted to that path and **breaks after `brew upgrade rclone`**.

- Install a copy at `~/.local/bin/rclone`. Do not skip the download merely because some other `rclone` is on PATH.
- Every cloudsync process prefers that binary (`~/.local/bin` is prepended to PATH). Put `~/.local/bin` **first** on PATH so Terminal `rclone` is the same file.
- `cloudsync setup --upgrade` (or `make upgrade`) re-fetches it.
- After install, smoke-test with `rclone version`.
- `cloudsync doctor` warns if the rclone in use is not that copy.

Grant Full Disk Access to **`~/.local/bin/rclone`**, not a Homebrew shim. Zip checksums wait until we publish.

## Wave 2 — Install by copy

`~/.local/bin/cloudsync` used to be a symlink into the git clone. Moving or deleting the repo broke launchd.

`cloudsync setup` copies the script to `~/.local/bin/cloudsync` (replacing a leftover symlink). Run setup **from the clone** (or `make setup`) to refresh that copy. The installed command does not depend on the repo. Config stays in `~/.config/cloudsync/`.

## Wave 3 — Doctor walks the job map

`cloudsync doctor` walks every active row in `jobs.tsv`: unknown mode, placeholder `Remote:`, dest/source remote missing from `rclone listremotes`, bisync job with no listing files in the rclone workdir (`~/Library/Caches/rclone/bisync` on macOS). Fix: `rclone config` or `cloudsync resync <job>`.

## Wave 4 — Validate the job map

TAB-vs-spaces is the remaining config footgun. `cloudsync edit`, `dry`, and `run` reject an active line that has no tab, an unknown mode, or the placeholder remote `Remote:`. A bisync `run` / `dry` without listing files aborts until `cloudsync resync <job>`. Stay TSV; no YAML.

## Not in scope

GUI, compiled binary, custom `rclone config` wizard, required fzf, Linux, auto-pruning remote backups, automating Full Disk Access.
