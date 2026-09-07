# 使用 netrun 選擇應用程式出口

`netrun` 決定某個命令是否使用路由器自己的 Nikki 認證代理，不修改 UCI、不重啟服務，
也不切換全機 router interception。參考 Pi 維持 router_proxy=0，路由／DNS 服務沿用原策略。
proxy 模式交給 Mihomo 既有規則選路，其中的規則仍可能選 DIRECT；它不是強制指定某個節點。

```sh
netrun status
netrun direct -- curl -q -I https://api.github.com
netrun proxy -- curl -q -I https://raw.githubusercontent.com
netrun proxy -- git clone https://github.com/daviddwlee84/dotfiles-OpenWrt.git
netrun proxy -- sh bootstrap.sh --package-network direct --with starship
netrun shell proxy          # 新的 ash login shell
netrun shell proxy bash     # 已安裝時使用 Bash／Starship
exit                       # 回到原本的環境
```

Direct 只在子程序清除 proxy 環境變數並設定 NO_PROXY=*。
Proxy 在記憶體中讀取已啟用 Nikki 的 mixed-port 與唯一有效認證，
再只對指定子程序設定標準 HTTP(S)／ALL_PROXY 變數。
憑證不印出、不放在命令參數，也不寫入 shell config；`status` 只顯示脫敏狀態。
Proxy 子程序的原始 `env`／debug dump 會含 proxy 憑證，請勿公開。
應用自身的 proxy 設定／參數可能優先於環境；curl 範例使用 -q 避免既有 .curlrc 介入。

只有接受 proxy 變數的應用（curl、Git HTTPS 等下載工具）受影響。
ping、SSH、任意 UDP 與 DNS 不會因此透明改道。若另行啟用全機 router interception，
direct 也不會覆蓋 kernel 規則。ash 顯示 auto／direct／proxy 標記，Bash session 也可用 status 檢查。
選擇不會持續到其他獨立登入。

## raw.githubusercontent.com 逾時時的首次 bootstrap

Ping github.com 只證明該主機的 ICMP 可達，不代表 raw.githubusercontent.com 的 TCP／TLS 可用。
這台 Pi 實測 raw 直連逾時、GitHub API 直連可用、raw 經 Nikki 回傳 200。
現有規則已能處理，因此沒有改 policy。

尚未安裝 netrun 時，可從 GitHub API 取得已審閱的 helper，再用本機 Nikki 下載 bootstrap：

```sh
api=https://api.github.com/repos/daviddwlee84/dotfiles-OpenWrt/contents
curl -q -fL -H 'Accept: application/vnd.github.raw+json' -o netrun.sh "$api/home/dot_local/bin/executable_netrun?ref=main"
sh netrun.sh proxy -- curl -q -fL -o bootstrap.sh https://raw.githubusercontent.com/daviddwlee84/dotfiles-OpenWrt/main/bootstrap.sh
sh netrun.sh proxy -- sh bootstrap.sh --package-network direct --with starship
```

Helper 需要已有啟用且帶認證的 Nikki，並拒絕在 managed-router transaction pending 時運行。
它不替 factory-safe 裝置建立 proxy。Bootstrap 現在會安裝原生 coreutils-timeout：
這個 OpenWrt BusyBox build 沒有 timeout，而 binary 相容性檢查仍須有時間上限。

這台 apk 使用外部 wget fetcher，放進認證 proxy 環境後回報 `wget: exited with error 8`
及 `unexpected end of file`；區域套件 mirror 直連可用。範例因此明確選擇套件直連、
GitHub assets 走代理。直接操作 apk 可用 `netrun direct -- apk update`。
原生 BusyBox tar 也沒有 --strip-components，bootstrap 已改用可攜的單一 root 解壓方式。
