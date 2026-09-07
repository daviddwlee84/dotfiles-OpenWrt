# Validate Pi workflows and additional development tools

Status: pending device acceptance

## Context and evidence

Initial target: Raspberry Pi 3B+, ImmortalWrt 25.12.1, aarch64_cortex-a53, 1 GB RAM.
RPi-ImmortalWrt owns networking, firmware and recovery. This repository deploys
home configuration and explicitly chosen CLI packages only. OpenWrt 25.12 uses
apk; older installations use opkg. Use existing feeds, never Alpine feeds.

Herdr v0.8.2 Linux release targets musl. SpecStory v2.10.0 disables CGO. Codex
rust-v0.153.4 has musl assets. Exact source URLs/digests are in config/assets.lock.
These build facts motivate opt-in installation; they are not hardware evidence.
Claude Code's documented 4 GB minimum excludes this 1 GB Pi from the first-version
local installer. Prefer remote Unix agents for resource-intensive work.

## Resume / acceptance

Run docs/verification.md after normal network provisioning, measure available
RAM/storage, session latency and background router health. Test Herdr create/
detach/resume, SpecStory recording with an explicitly named agent, and a small
Codex project using normal authentication/isolation. No automatic service startup,
swap, unsafe sandbox fallback or networking changes are part of acceptance.

## Later candidates

Evaluate fzf, lazygit, gh, Neovim, Node/npm and build tools one at a time. Prefer
native feed packages; otherwise require a matching architecture/ABI and verified
release. Record installed/storage/runtime cost before deciding what joins dev.
No full second backlog document is needed in Unix or Windows; shared platform
policy is in dotfiles-all/docs/platform-support.md.

## 2026-09-07 device progress

Baseline, chezmoi, Bash/Starship and command/child-shell netrun are verified on the
Pi. Native apk/wget fails with the authenticated proxy, so package-network direct
is an explicit bootstrap option; GitHub assets use netrun proxy. Stock BusyBox
also lacks timeout and tar --strip-components; both setup gaps are fixed.
Herdr/SpecStory/Codex interactive workloads and resource measurements remain pending.
