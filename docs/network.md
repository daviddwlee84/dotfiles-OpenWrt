# Choose application egress with netrun

`netrun` chooses whether a command uses the router's authenticated Nikki proxy.
It does not rewrite UCI, restart services or toggle global router interception.
On the reference Pi, router_proxy remains 0, so routing/DNS services retain their
existing policy. Proxy mode sends traffic to Mihomo's existing rules: a rule may
still choose DIRECT. This is not a forced node selection.

```sh
netrun status
netrun direct -- curl -q -I https://api.github.com
netrun proxy -- curl -q -I https://raw.githubusercontent.com
netrun proxy -- git clone https://github.com/daviddwlee84/dotfiles-OpenWrt.git
netrun proxy -- sh bootstrap.sh --source-network proxy --package-network direct --with starship
netrun shell proxy          # new ash login shell
netrun shell proxy bash     # Bash / Starship when installed
exit                       # return to the original environment
```

Direct clears proxy environment variables and sets NO_PROXY=* in the child.
Proxy derives the enabled Nikki mixed-port and single active credential in memory,
then sets standard HTTP(S)/ALL_PROXY variables only for the selected child.
Credentials are not printed, put in command arguments or saved in shell config.
`status` is sanitized. Raw `env`/debug dumps from a proxy child would contain its
proxy credentials; do not publish them. App-specific proxy configuration/flags
can override environment behavior; use curl -q to avoid an unrelated .curlrc.

Only applications that honor proxy variables participate (curl, Git HTTPS and
similar download tools). ping, SSH, arbitrary UDP and DNS are not transparently
rerouted. If you independently enable global router interception, direct does
not override those kernel rules. ash shows an auto/direct/proxy label; status
also works inside Bash sessions. No mode persists across unrelated logins.

## First bootstrap when raw.githubusercontent.com times out

Reaching github.com by ping only establishes that host's ICMP reachability. It
says nothing about TCP/TLS to raw.githubusercontent.com. On the tested Pi,
raw direct timed out, GitHub API direct worked, and raw via Nikki returned 200.
Existing rules worked; no policy change was necessary.

If netrun is not yet installed, fetch the reviewed helper through GitHub's API,
then use the local Nikki listener for bootstrap downloads:

```sh
api=https://api.github.com/repos/daviddwlee84/dotfiles-OpenWrt/contents
curl -q -fL -H 'Accept: application/vnd.github.raw+json' -o netrun.sh "$api/home/dot_local/bin/executable_netrun?ref=main"
sh netrun.sh proxy -- curl -q -fL -o bootstrap.sh https://raw.githubusercontent.com/daviddwlee84/dotfiles-OpenWrt/main/bootstrap.sh
sh netrun.sh proxy -- sh bootstrap.sh --source-network proxy --package-network direct --with starship
```

The helper requires already-enabled, authenticated Nikki and rejects a pending
managed-router transaction. It cannot provision a proxy for a factory-safe device.
Bootstrap now installs the native coreutils-timeout package: this OpenWrt BusyBox
build does not contain timeout, and version checks must remain bounded.

The reference apk uses an external wget fetcher; authenticated proxy mode returned
`wget: exited with error 8` / `unexpected end of file`. Its regional feeds work
directly. The bootstrap example therefore selects direct package downloads and
proxied GitHub assets explicitly. Use `netrun direct -- apk update` for apk itself.
The stock BusyBox tar also lacks --strip-components; bootstrap now extracts the
single archive root using portable tar options.

## Plain chezmoi updates

On a router with this same connectivity, configure once from the source:

```sh
sh ~/.local/share/dotfiles-OpenWrt/bootstrap.sh --source-network proxy --package-network direct
chezmoi update
```

Source Git/tool downloads then use Nikki, while missing native packages use direct
feeds. Only the words proxy/direct are stored in local state; credentials are read
from UCI for each child process. This preference belongs to dotfiles updates and
does not make other shells or router traffic use a proxy. For a temporary override:
`DOTFILES_SOURCE_NETWORK=direct chezmoi update`. Direct Git HTTPS timed out on the
reference Pi; the same ls-remote through Nikki succeeded.
