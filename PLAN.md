# Dotfiles Improvement Plan

Goal: one command on a fresh Arch install that recreates the entire environment —
packages, dotfiles, system config, services — with no manual steps in between.

Current state: the pieces already exist but are fragmented across four tools that
don't call each other:

| Piece                                   | What it covers                                   | Status                                                         |
| --------------------------------------- | ------------------------------------------------ | -------------------------------------------------------------- |
| `manager/` (Python/uv/Textual)          | stow linking, package export                     | Works, but only links — doesn't install                        |
| `install.sh`                            | core desktop packages, services                  | **Dead code** — `install_deps` is defined but never called     |
| `packages/explicit.txt` + `foreign.txt` | pacman/AUR package lists                         | Current (2026-07-18), but redundant with two other lists       |
| `stowables/aconfmgr/`                   | system state (`/etc`, `/boot`, package manifest) | Deleted from working tree, still tracked; **contains secrets** |

---

## Phase 0 — URGENT: purge secrets from git history

`stowables/aconfmgr/.config/aconfmgr/files/` is committed in git (HEAD and full
history) and contains real credentials:

- **~35 plaintext WiFi passwords** — `etc/NetworkManager/system-connections/*.nmconnection` (`psk=` lines)
- **`/etc/shadow` and `shadow-`** — root and user password hashes (offline-crackable)
- **SSH host private keys** — `etc/ssh/ssh_host_{ecdsa,ed25519,rsa}_key`
- **pacman GPG private keys** — `etc/pacman.d/gnupg/private-keys-v1.d/*.key` + revocation certs
- `machine-id`, `passwd`, `gshadow`, `sudoers.d/`, `fstab` — not secret but machine-specific noise

Steps:

1. Commit the pending deletions (files are already `D` in the working tree).
2. Rewrite history with `git-filter-repo` to remove
   `stowables/aconfmgr/.config/aconfmgr/files/` from all commits; force-push if a
   remote exists.
3. **If the repo was ever pushed anywhere, treat credentials as burned**: change
   WiFi passwords, regenerate SSH host keys (`ssh-keygen -A` after deleting),
   change root/user passwords, `pacman-key --init` fresh keyring.
4. Fix the aconfmgr ignore list: `10-ignores.sh` already names most of these
   paths but the capture predates it — re-run `aconfmgr save` and verify nothing
   sensitive lands in `files/` again. Add `IgnorePath` for
   `/etc/NetworkManager/system-connections/*`.
5. Add a pre-commit guard (e.g. `gitleaks` or a simple grep hook for `psk=`,
   `PRIVATE KEY`) so this can't recur.

## Phase 1 — Single source of truth for packages

Three package lists exist today: `packages/{explicit,foreign}.txt`,
`utils/packages.txt`, and aconfmgr's `99-unsorted.sh`. They will drift.

1. Keep `packages/explicit.txt` + `packages/foreign.txt` as the only canonical
   lists (already maintained by `manager export`).
2. Delete `utils/packages.txt` + `utils/setup.sh` and `utils/export-packages.sh`
   (superseded by `manager export`).
3. Either drop aconfmgr's package manifest role (use it only for `/etc` file
   diffs) or generate `99-unsorted.sh`'s package section from `explicit.txt` —
   don't hand-maintain both.
4. Optional: split `explicit.txt` into roles (`base.txt`, `desktop.txt`,
   `laptop.txt`) so a server/VM install can skip the Hyprland stack.

## Phase 2 — Make `manager` the single program

Extend `manager/` (it already has the CLI framework, stow wrapper, and pacman
export) with the missing install-side subcommands:

- `manager bootstrap` — the one command. Runs, in order:

1. sanity checks (Arch, network, sudo)
2. `pacman -S --needed - < packages/explicit.txt` (native packages)
3. bootstrap an AUR helper if absent (clone + makepkg `paru`), then install
   `packages/foreign.txt`
4. `manager link --all` (stow everything in `stowables/`)
5. enable services (see Phase 3)
6. `aconfmgr apply` for `/etc` state (optional flag, since it needs review)

- `manager doctor` — verify: every stow package linked, package lists in sync
  with `pacman -Qqe`, services enabled. Gives a diffable "drift report".
- Reuse existing code: `src/linker.py` batch generators for linking,
  `src/pacman.py` for the export side; add `src/installer.py` for the pacman/AUR
  side with the same `Step`/dry-run pattern.
- Port the service-enable and package logic out of `install.sh`, then delete
  `install.sh` (or reduce it to the Phase 2b shim below).

### Phase 2b — solve the chicken-and-egg

`manager` needs `git`, `stow`, `uv`/Python before it can run. Keep a tiny
`bootstrap.sh` (curl-able, <30 lines) whose only job is:

```sh
pacman -S --needed git stow uv
git clone <repo> ~/dotfiles
cd ~/dotfiles/manager && uv run manager bootstrap
```

Everything else lives in Python where it's testable.

## Phase 3 — Capture the parts not yet captured

Things a fresh machine needs that the repo doesn't declare today:

1. **Services**: `NetworkManager`, `bluetooth`, `powertop`, `syncthing@`,
   zram — declare as a list in `manager` config (or keep in aconfmgr) instead of
   ad-hoc `systemctl enable` lines in dead script code.
2. **User services/timers** if any (check `systemctl --user list-unit-files --state=enabled`).
3. **Shell plugin managers / runtimes**: `utils/zsh-plug.sh`, tmux plugin setup
   (`utils/tmuxscripts/install`), nvim is self-bootstrapping via lazy.nvim +
   `lazy-lock.json` (good — keep pinning).
4. **Secrets, done right**: things like WiFi go in a separate private encrypted
   store — `pass`, or an `age`-encrypted tarball the bootstrap can optionally
   decrypt. Never back in this repo.
5. **Hardware-specific config**: `/boot` loader entries, `fstab`, initramfs are
   per-machine — explicitly _exclude_ from reproduction (regenerated by the
   installer) rather than restoring stale copies.

## Phase 4 — Repo hygiene

- Commit the pending `stowables/aconfmgr` deletions (part of Phase 0).
- Remove committed `manager/**/__pycache__/*.pyc`; add `__pycache__/` to `.gitignore`.
- Remove `.tm1`/`.tm2` marker files (or gitignore them if the manager needs them at runtime).
- Expand `README.md`: the one-liner becomes "clone, run `./bootstrap.sh`, done" plus
  a table of stow packages.
- Decide `kitty` vs `ghostty` (both stow packages exist; ghostty is current) —
  keep both or prune kitty.

## Suggested order of work

1. Phase 0 (secrets) — do this before anything else touches the repo history.
2. Phase 4 hygiene commits (cheap, makes later diffs clean).
3. Phase 1 (package list consolidation).
4. Phase 2 + 2b (`manager bootstrap` — the actual goal).
5. Phase 3 (services, secrets store, zsh/tmux plugins).

## Verification

- Test in a VM or container: `archlinux:latest` Docker image (or a libvirt VM
  for the full Hyprland stack) → run `bootstrap.sh` → `manager doctor` reports
  zero drift.
- `manager bootstrap --dry-run` prints the full step list without executing
  (dry-run plumbing already exists in `manager`).
- Re-run `bootstrap` on the _current_ machine: must be idempotent (no-op).
