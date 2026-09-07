# Tools and support

The default packages are `git git-http openssh-client tmux nano curl ca-bundle jq less`.
Stock BusyBox vi remains available. `--with dev` adds `vim htop ripgrep rsync python3-light`.
The adapter uses the target's existing apk or opkg feeds; it never mixes Alpine
packages into OpenWrt. Package availability varies by release and architecture.

```sh
sh bootstrap.sh --with dev
sh bootstrap.sh --with dev,herdr,specstory
sh bootstrap.sh --with codex
```

| Tool | First-version support |
|---|---|
| Herdr | Locked musl ARM64/x86_64 releases; small seed config and default Ctrl+b keymap. No Unix plugins, pickers or heavy helpers. Runtime edits remain user-owned. |
| SpecStory | Locked CGO-disabled ARM64/x86_64 builds; manually run `specstory run codex` or another installed agent. Installation does not launch an agent or enable cloud sync. |
| Codex | Experimental ARM64/x86_64 musl binary, with Bash/ripgrep dependencies. A successful version probe is not a working agent session. Use existing agent authentication and normal isolation. |
| Claude Code | Remote use on the 1 GB Pi; official minimum is 4 GB RAM. No first-version local installer. |
| Other architectures | Baseline and distro dev packages only; unavailable release assets fail explicitly. |

First hardware baseline: Pi 3B+, ImmortalWrt 25.12.1, aarch64_cortex-a53, 1 GB RAM.
Before choosing agents, inspect `sh bootstrap.sh --doctor` and free RAM/storage.
No swap, Node runtime, compiler toolchain, service startup, network policy, root
password or firmware changes are automated. SSH client installation leaves Dropbear
server configuration untouched. Run bootstrap after the device already has working
network access; it will not provision connectivity for you.

The RPi-ImmortalWrt project owns firmware, networking and proxy operations.
fzf, lazygit, gh, Neovim, Node/npm and native build tools remain candidates in TODO;
prefer a remote Unix development host for large builds and agent workloads.

Sources checked 2026-09-07: [Herdr release build](https://github.com/herdrdev/herdr/blob/v0.8.2/.github/workflows/release.yml),
[SpecStory build](https://github.com/specstoryai/getspecstory/blob/v2.10.0/.goreleaser.yml),
[Codex releases](https://github.com/openai/codex/releases/tag/rust-v0.153.4),
[Claude requirements](https://code.claude.com/docs/en/setup),
[OpenWrt apk](https://openwrt.org/docs/guide-user/additional-software/apk).
