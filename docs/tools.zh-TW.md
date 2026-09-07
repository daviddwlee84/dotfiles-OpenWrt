# 工具與支援

預設套件為 `git git-http openssh-client tmux nano curl ca-bundle jq less coreutils-timeout btop`；保留 BusyBox vi。
`--with dev` 加裝 `vim htop ripgrep rsync python3-light`。Adapter 使用裝置既有的
apk 或 opkg feeds，不把 Alpine 套件混入 OpenWrt。可用套件依版本與架構而異。

```sh
sh bootstrap.sh --with dev
sh bootstrap.sh --with dev,herdr,specstory
sh bootstrap.sh --with codex
```

| 工具 | 第一版支援 |
|---|---|
| Herdr | 鎖定 musl ARM64／x86_64 release；精簡 seed config、預設 Ctrl+b keymap；不帶 Unix plugins、pickers 或大型 helpers，runtime 設定由使用者管理。 |
| SpecStory | 鎖定停用 CGO 的 ARM64／x86_64 build；手動執行 `specstory run codex` 或其他已安裝 agent。安裝不啟動 agent 或開啟 cloud sync。 |
| Codex | 實驗性 ARM64／x86_64 musl binary，附 Bash／ripgrep 依賴；版本檢查不等於 agent session 成功，使用原有登入與正常隔離。 |
| Claude Code | 1 GB Pi 採遠端使用；官方最低要求 4 GB RAM，第一版無本機 installer。 |
| 其他架構 | 僅基本工具與 distro dev 套件；無對應 release 時明確回報。 |

首個硬體基線：Pi 3B+、ImmortalWrt 25.12.1、aarch64_cortex-a53、1 GB RAM。
選裝 agent 前先執行 `sh bootstrap.sh --doctor` 並檢查 RAM／空間。
安裝不建立 swap、不加入 Node runtime 或 compiler toolchain、不啟動服務，
也不修改網路策略、root password 或 firmware。OpenSSH client 安裝不變更 Dropbear server 設定。
請在裝置已能正常連線後執行；bootstrap 不替你 provision 網路。

RPi-ImmortalWrt 負責韌體、網路與 proxy 操作。fzf、lazygit、gh、Neovim、Node/npm
與編譯工具列於 TODO；大型 build 與 agent 工作優先交給遠端 Unix 開發主機。

2026-09-07 查證來源：[Herdr build](https://github.com/herdrdev/herdr/blob/v0.8.2/.github/workflows/release.yml)、
[SpecStory build](https://github.com/specstoryai/getspecstory/blob/v2.10.0/.goreleaser.yml)、
[Codex releases](https://github.com/openai/codex/releases/tag/rust-v0.153.4)、
[Claude 需求](https://code.claude.com/docs/en/setup)、
[OpenWrt apk](https://openwrt.org/docs/guide-user/additional-software/apk)。

內建 ash prompt 與 `--with starship` 見 [Shell 與 Starship](shell.md)。
[netrun](network.md) 可按命令或暫時子 shell 選擇直連／代理出口。

`btop` 使用原生 feed 套件及其相依項，按需執行；安裝不啟動常駐監控。
Locale 設定見 [Shell 與 Starship](shell.md)。
