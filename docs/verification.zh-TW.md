# 驗證與維護

在維護主機執行 `just check`：ShellCheck、Bats、雙語 MkDocs strict build。
目標安裝不依賴這些工具。測試隔離 HOME、XDG、chezmoi config 與假套件指令；
只有明確 fixture sentinel 加上相符的暫存 HOME 才接受測試路徑。

測試包含真正 chezmoi 與 sh 的輸出一致性、重跑、保留 SSH／tmux／Git／profile、
舊 iSH helpers、目標判斷、apk／opkg、分支辨識、離線、dry-run、checksum 拒絕與安裝失敗。
CI 另在可拋棄的 x86_64／ARM64 musl container 啟動鎖定的 Linux binary。
版本檢查只證明啟動，不代表 agent 登入、程序隔離、模擬器相容、低記憶體穩定性或真實 session。

## 實機驗收

記錄日期、裝置、OS／build、架構、套件管理器、設定 manager、可用 RAM／空間與工具版本，然後檢查：

1. 首次 bootstrap，重開 login shell，執行 `git --version`、`ssh -V`、`tmux -V`。
2. 重跑兩次，確認既有設定與 local overrides 保留。
3. 正常核對 host key 後 SSH 到已知主機，建立、detach、resume tmux；iSH 另測 app suspend 與取消 Files picker。
4. 有選 chezmoi 時測 diff／apply；iSH 必須重複做真正模擬器測試。
5. OpenWrt 確認路由、Wi-Fi 與既有服務持續正常，量測 Herdr／SpecStory／Codex session 的資源用量。
6. Agent 由你使用個人憑證手動驗收；憑證與私人 prompt 不進 log 或 public repo。
   不藉停用 agent 隔離把不支援的 runtime 宣稱為成功。

**目前狀態（2026-09-07）：**已在參考 Pi 3B+／ImmortalWrt 25.12.1 安裝並測試
基本套件、chezmoi 2.72.1、Starship 1.26.0 與 Bash 5.3.15。
chezmoi diff 為空，Bash 正常顯示 Starship；proxy 子 shell 取得 raw.githubusercontent.com
的 HTTP 200／有效 TLS，離開後原 shell 環境保持原樣。
network、firewall、Nikki、active marker 的檔案 hash 未改變；五個既有 proxy-health endpoint 全通過。
未宣稱完成 reboot、iSH 模擬器、agent 登入或長時間工作負载驗證。

兩個輕量 repo 的共用 shell core、tests、assets lock 是相同副本，變更共同行為時同步修改。
套件來源與使用者設定維持平台原生；維護工具及 release assets 不自動升級。

chezmoi x86_64 使用明確的 `linux-musl_amd64` asset；upstream 的
`linux_amd64` 是 glibc build 別名，不能直接當成 router 預設 binary。

Git 整合 fixture 另涵蓋 snapshot backup、main tracking、真正 upstream 新 commit
後的普通 chezmoi update／apply、離線失敗，以及既有／自訂 chezmoi config 保留。

## Chezmoi 預設流程遷移驗收（2026-09-07）

同一台 Pi 使用已發布來源 `5724e56`，將舊 snapshot 遷移成追蹤 `origin/main` 的乾淨
Git checkout，並保留舊 source 和 chezmoi config backup。
儲存 source=proxy／package=direct 後，在沒有 proxy 變數的 shell 直接執行
`chezmoi update` 成功；套件／apply hooks 完成、chezmoi diff 為空，原 .profile hash 相同。
network、firewall、Nikki、active marker 的 hash 也全部維持一致。
iSH 模擬器驗收仍是獨立且待完成的項目。

啟動 probe 現在於 15 秒後送 SIGKILL，並區分下載／hash／解壓／版本／template 階段。
回歸測試驗證忽略 TERM 的程序仍會被終止；這不代表 iSH 模擬器相容性已驗收。
