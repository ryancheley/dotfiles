#!/bin/sh
# Bootstrap these dotfiles on macOS or apt-based Linux (Debian, Ubuntu,
# Raspberry Pi OS; x86_64 or aarch64). Safe to re-run: anything already in
# place is left alone.
#
#   ./setup.sh            apply
#   ./setup.sh --dry-run  print what would change, change nothing
#
# Runs non-interactively over ssh as root or as a user with passwordless sudo.
# Replaced files are moved to ~/.dotfiles-backup/<timestamp>/.
set -u

DOTFILES=$(cd "$(dirname "$0")" && pwd)
OS=$(uname -s)
ARCH=$(uname -m)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=
CHANGED=0
FAILED=0

case "${1:-}" in
    --dry-run) DRY_RUN=1 ;;
    "") ;;
    *) echo "usage: $0 [--dry-run]" >&2; exit 2 ;;
esac

# Installers below drop binaries here; make them visible to this script.
PATH="$HOME/.local/bin:$HOME/.atuin/bin:/opt/homebrew/bin:$PATH"
# The fish PATH lives in conf.d/00-path.fish, so stop installers editing shell rc files
# (with ~/.config/fish linked to this repo, they'd write into the repo).
export UV_NO_MODIFY_PATH=1 ATUIN_NO_MODIFY_PATH=1 INSTALLER_NO_MODIFY_PATH=1

log() { printf '%s\n' "$*"; }
step() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
fail() { printf '  FAILED: %s\n' "$*" >&2; FAILED=$((FAILED + 1)); }
have() { command -v "$1" >/dev/null 2>&1; }

# Run a command, or only print it under --dry-run. Counts as a change.
run() {
    CHANGED=$((CHANGED + 1))
    if [ -n "$DRY_RUN" ]; then log "  [dry-run] $*"; return 0; fi
    log "  + $*"
    "$@" || { fail "$*"; return 1; }
}

# sudo: none as root, `sudo -n` if passwordless, plain sudo only with a TTY to prompt on.
if [ "$(id -u)" = 0 ]; then
    SUDO=
elif sudo -n true 2>/dev/null; then
    SUDO="sudo -n"
elif [ -t 0 ]; then
    SUDO=sudo
else
    SUDO="need_sudo"
fi
need_sudo() { echo "  needs root or passwordless sudo" >&2; return 1; }

login_shell() {
    if [ "$OS" = Darwin ]; then dscl . -read "/Users/$1" UserShell | awk '{print $2}'
    else getent passwd "$1" | cut -d: -f7; fi
}

# Symlink $DOTFILES/$1 to $2, backing up whatever is there unless it's already our link.
link() {
    src="$DOTFILES/$1" dest="$2"
    [ "$(readlink "$dest" 2>/dev/null)" = "$src" ] && return 0
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        log "  backing up existing $dest"
        run mkdir -p "$BACKUP_DIR" && run mv "$dest" "$BACKUP_DIR/" || return 1
    fi
    run ln -s "$src" "$dest"
}

# Download an installer script and run it, unless $1 is already on PATH.
install_script() {
    name="$1" url="$2"; shift 2
    have "$name" && return 0
    tmp=$(mktemp)
    run curl -fsSL --proto '=https' "$url" -o "$tmp" && run sh "$tmp" "$@"
    rm -f "$tmp"
}

install_macos() {
    # The Homebrew installer asks for your password; run setup.sh from a terminal on a new Mac.
    have brew || run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
    brew bundle check --file="$DOTFILES/Brewfile" >/dev/null 2>&1 || run brew bundle --file="$DOTFILES/Brewfile"
}

install_linux() {
    have apt-get || die "unsupported Linux: only apt-based distros are handled (no apt-get found)"
    missing=
    for pkg in ca-certificates curl git fish direnv; do
        dpkg -s "$pkg" >/dev/null 2>&1 || missing="$missing $pkg"
    done
    if [ -n "$missing" ]; then run $SUDO apt-get update -qq || return 1; fi
    # git-delta isn't packaged on every release (e.g. Debian 12); git falls back to less.
    dpkg -s git-delta >/dev/null 2>&1 || ! apt-cache show git-delta >/dev/null 2>&1 || missing="$missing git-delta"
    # shellcheck disable=SC2086 # $missing is a word list
    [ -n "$missing" ] && run $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $missing
}

# fish as the login shell, except root on Linux: root keeps bash (so ssh, scp and
# Ansible always get a POSIX shell) and interactive logins exec into fish.
set_shell() {
    if ! fish=$(command -v fish); then
        [ -n "$DRY_RUN" ] && { log "  (fish not installed yet; would set it as the shell)"; return 0; }
        fail "fish is not installed"; return 1
    fi
    user=$(id -un)
    if [ "$OS" = Linux ] && [ "$user" = root ]; then
        [ "$(login_shell root)" = /bin/bash ] || run usermod -s /bin/bash root
        grep -q 'dotfiles: exec fish' ~/.bashrc 2>/dev/null ||
            run sh -c 'printf "%s\n" "# dotfiles: exec fish for interactive top-level shells (typing bash still gives bash)" "[ \"\${SHLVL:-}\" = 1 ] && case \$- in *i*) command -v fish >/dev/null && exec fish -l ;; esac" >> ~/.bashrc'
        return
    fi
    grep -qx "$fish" /etc/shells || run sh -c "echo '$fish' | $SUDO tee -a /etc/shells >/dev/null" || return 1
    [ "$(login_shell "$user")" = "$fish" ] && return 0
    if [ "$OS" = Darwin ]; then run $SUDO chsh -s "$fish" "$user"
    else run $SUDO usermod -s "$fish" "$user"; fi
}

log "dotfiles: $DOTFILES  os: $OS/$ARCH  user: $(id -un)${DRY_RUN:+  (dry run)}"
case "$OS" in Darwin|Linux) ;; *) die "unsupported OS: $OS" ;; esac
[ "$OS" = Linux ] && [ "$SUDO" = need_sudo ] && die "run as root or give $(id -un) passwordless sudo (needed for apt and usermod)"

step "Packages"
if [ "$OS" = Darwin ]; then install_macos; else install_linux; fi

# Links go before the tool installers, which otherwise create ~/.config/uv etc. first.
step "Config links"
[ -d ~/.config ] || run mkdir -p ~/.config
link config/git ~/.config/git
link config/fish ~/.config/fish
link config/starship/starship.toml ~/.config/starship.toml
link config/nvim ~/.config/nvim
link config/pip ~/.config/pip
link config/atuin ~/.config/atuin
link config/direnv ~/.config/direnv
[ "$OS" = Darwin ] && link config/karabiner ~/.config/karabiner

step "Tools"
[ -d ~/.local/bin ] || run mkdir -p ~/.local/bin
install_script starship https://starship.rs/install.sh -y -b "$HOME/.local/bin"
install_script atuin https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh
install_script uv https://astral.sh/uv/install.sh

step "Login shell"
set_shell

step "Summary"
[ -d "$BACKUP_DIR" ] && log "  backups:  $BACKUP_DIR"
log "  ${DRY_RUN:+would make }$CHANGED change(s), $FAILED failure(s)"
[ -f "$DOTFILES/config/fish/conf.d/secrets.fish" ] ||
    log "  note: no secrets.fish; copy config/fish/conf.d/secrets.fish.example if this machine needs secrets"
have atuin && [ ! -f ~/.local/share/atuin/key ] &&
    log "  note: atuin isn't logged in; run 'atuin login' to sync history"
[ "$FAILED" = 0 ]
