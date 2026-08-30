# Shipping waves

cloudsync ships as a stock-macOS script. Each wave is a slice that can run in production; later waves do not rewrite earlier ones.

**Now shipping: Wave 1.**

## Wave 1 — FDA-stable rclone

Homebrew rclone lives in the Cellar. Full Disk Access is granted to that path and **breaks after `brew upgrade rclone`**.

- Install a copy at `~/.local/bin/rclone`. Do not skip the download merely because some other `rclone` is on PATH.
- Every cloudsync process prefers that binary (`~/.local/bin` is prepended to PATH). Put `~/.local/bin` **first** on PATH so Terminal `rclone` is the same file.
- `cloudsync setup --upgrade` (or `make upgrade`) re-fetches it.
- After install, smoke-test with `rclone version`.
- `cloudsync doctor` warns if the rclone in use is not that copy.

Grant Full Disk Access to **`~/.local/bin/rclone`**, not a Homebrew shim. Zip checksums wait until we publish.

## Wave 2 — Install by copy

`~/.local/bin/cloudsync` is a symlink into the git clone. Moving or deleting the repo breaks launchd.

Copy the script on setup; a later `setup` refreshes the copy. The clone is no longer load-bearing.

## Wave 3 — Doctor walks the job map

`doctor` today checks iCloud in *this* process and lists every rclone remote.

Walk `jobs.tsv`: unknown mode, dest remote missing from `rclone listremotes`, bisync job with no baseline.

## Wave 4 — Validate the job map

TAB-vs-spaces is the remaining config footgun. On `edit` / `dry`, reject a line that has no tab, warn on placeholder remotes like `Remote:`, and require `resync` before the first bisync `run`. Stay TSV; no YAML.

## Not in scope

GUI, compiled binary, custom `rclone config` wizard, required fzf, Linux, auto-pruning remote backups, automating Full Disk Access.
