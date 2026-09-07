# Verification and maintenance

Run `just check` on a maintainer machine: ShellCheck, Bats and strict bilingual
MkDocs. Target setup does not require these tools. Tests isolate HOME, XDG dirs,
chezmoi config and fake package commands; real-device paths are never redirected
without the explicit fixture sentinel and matching temporary HOME.

The suite covers manager equivalence with actual chezmoi, repeated apply, existing
SSH/tmux/Git/profile content, legacy iSH helpers, target detection, apk/opkg,
branch parsing, offline setup, dry-run, checksum rejection and failed installers.
CI additionally probes locked Linux assets in disposable musl containers on
x86_64/ARM64. A version probe verifies executable startup, not agent authentication,
process isolation, emulator compatibility, low-memory stability or a real session.

## Device acceptance

Record date, device, OS/build, architecture, package manager, selected manager,
free RAM/storage and exact tool versions. Then check:

1. Fresh bootstrap; restart a login shell; `git --version`, `ssh -V`, `tmux -V`.
2. Reapply twice; preserve existing configs and your local overrides.
3. Connect to a known SSH host with normal host-key verification; create, detach
   and resume a tmux session. iSH must also test suspension and a cancelled Files picker.
4. If chosen, test chezmoi diff/apply; iSH needs repeated real emulator runs.
5. OpenWrt: verify routing, Wi-Fi and existing services remain operational, and
   measure resource use while a selected Herdr/SpecStory/Codex session runs.
6. Test agents manually with your own credentials. No authentication material or
   private prompts belong in logs or the public repository. Do not disable
   agent isolation to turn an unsupported runtime into a claimed success.

**Current status (2026-09-07):** installed and exercised on the referenced Pi
3B+ / ImmortalWrt 25.12.1: baseline packages, chezmoi 2.72.1, Starship 1.26.0 and
Bash 5.3.15. chezmoi diff was empty, Bash displayed Starship, and a proxy child
shell fetched raw.githubusercontent.com with HTTP 200 / valid TLS before returning
to an unchanged parent environment. Network, firewall, Nikki and active-marker
file hashes were unchanged; all five existing proxy-health endpoints passed.
No reboot, iSH emulator, coding-agent login or long-running workload claim is made.

The shared shell core/tests/assets lock are copied in the two lightweight repos;
changes to their shared behavior must be mirrored. Package feeds and user configs
are platform-specific. Maintainer commands and release assets never auto-upgrade.

chezmoi x86_64 uses the explicitly named `linux-musl_amd64` asset; upstream
`linux_amd64` aliases the glibc build and cannot be used as the router default.

Git integration fixtures additionally cover snapshot backups, tracking main, a real
upstream commit followed by plain chezmoi update/apply, offline failure, and
preserving existing/custom chezmoi configuration.

## Chezmoi-first migration acceptance (2026-09-07)

On the same Pi, published source `5724e56` migrated the old snapshot to a clean
Git checkout tracking `origin/main`. The old source and chezmoi config were backed
up. Saved source=proxy/package=direct preferences let a plain `chezmoi update`
complete in a shell with no proxy variables. Its package/apply hooks succeeded,
chezmoi diff was empty, and the existing .profile hash was identical. Network,
firewall, Nikki and active-marker hashes also remained identical. iSH emulator
acceptance remains separate and pending.
