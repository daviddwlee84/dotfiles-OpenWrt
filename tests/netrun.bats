#!/usr/bin/env bats

setup() {
    export REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd -P)"
    export DOTFILES_TEST_ROOT="$BATS_TEST_TMPDIR/router"
    export DOTFILES_TEST_MODE=fixture-only-v1
    export HOME="$DOTFILES_TEST_ROOT/home"
    export TEST_AUTH=1
    mkdir -p "$HOME" "$DOTFILES_TEST_ROOT/etc" "$DOTFILES_TEST_ROOT/bin"
    touch "$DOTFILES_TEST_ROOT/.fixture" "$DOTFILES_TEST_ROOT/etc/openwrt_release"
    export PATH="$DOTFILES_TEST_ROOT/bin:$PATH"
    cat >"$DOTFILES_TEST_ROOT/bin/uci" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >>"$DOTFILES_TEST_ROOT/uci-calls"
case "$*" in
 '-q show nikki') printf "nikki.auth='authentication'\n" ;;
 '-q get nikki.config.enabled'|'-q get nikki.auth.enabled') echo 1 ;;
 '-q get nikki.proxy.router_proxy') echo 0 ;;
 '-q get nikki.mixin.authentication') echo "$TEST_AUTH" ;;
 '-q get nikki.mixin.mixed_port') echo 7890 ;;
 '-q get nikki.auth.username') echo fixture-user ;;
 '-q get nikki.auth.password') echo fixture-password ;;
 *) exit 1 ;;
esac
EOF
    chmod +x "$DOTFILES_TEST_ROOT/bin/uci"
    export NETRUN="$REPO/home/dot_local/bin/executable_netrun"
}

@test "direct clears app proxies only in its child and preserves argument boundaries" {
    export http_proxy=http://parent.invalid:1234
    export HTTPS_PROXY=http://parent.invalid:1234
    run sh "$NETRUN" direct -- sh -c 'test -z "${http_proxy:-}${HTTPS_PROXY:-}"; test "$NO_PROXY" = "*"; printf "%s:%s\n" "$DOTFILES_NET_MODE" "$1"' _ 'a b'
    [ "$status" = 0 ]
    [ "$output" = 'direct:a b' ]
    [ "$http_proxy" = http://parent.invalid:1234 ]
}

@test "proxy derives local auth and exposes no credential in status" {
    run sh "$NETRUN" proxy -- sh -c 'test "$http_proxy" = "http://fixture-user:fixture-password@127.0.0.1:7890"; test "$https_proxy" = "$http_proxy"; test "$HTTPS_PROXY" = "$http_proxy"; sh "$NETRUN" status'
    [ "$status" = 0 ]
    [[ "$output" == *'shell mode: proxy'* ]]
    [[ "$output" == *'router_proxy: 0'* ]]
    [[ "$output" != *fixture-user* ]]
    [[ "$output" != *fixture-password* ]]
    ! grep -Eq 'set|commit|delete' "$DOTFILES_TEST_ROOT/uci-calls"
}

@test "proxy refuses disabled auth and pending transactions before starting a command" {
    export TEST_AUTH=0
    run sh "$NETRUN" proxy -- touch "$HOME/ran"
    [ "$status" != 0 ]
    [ ! -e "$HOME/ran" ]
    export TEST_AUTH=1
    mkdir -p "$DOTFILES_TEST_ROOT/etc/rpi-immortalwrt"
    touch "$DOTFILES_TEST_ROOT/etc/rpi-immortalwrt/pending.tsv"
    run sh "$NETRUN" proxy -- touch "$HOME/ran"
    [ "$status" != 0 ]
    [ ! -e "$HOME/ran" ]
}

@test "shell opens a child login shell with the chosen mode" {
    cat >"$DOTFILES_TEST_ROOT/bin/ash" <<'EOF'
#!/bin/sh
test "$1" = -l
printf 'child:%s\n' "$DOTFILES_NET_MODE"
EOF
    chmod +x "$DOTFILES_TEST_ROOT/bin/ash"
    run sh "$NETRUN" shell proxy
    [ "$status" = 0 ]
    [ "$output" = child:proxy ]
    [ -z "${DOTFILES_NET_MODE:-}" ]
}

@test "netrun returns the child's exit code" {
    run sh "$NETRUN" direct -- sh -c 'exit 7'
    [ "$status" = 7 ]
}
