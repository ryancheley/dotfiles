# Dotfiles

These are my versioned dotfiles based on the ideas from the book [Boost Your Git DX](https://adamchainz.gumroad.com/l/byddx).

## Install

On a new Mac, server or Pi (macOS, or apt-based Linux on x86_64/aarch64):

```sh
git clone https://github.com/ryancheley/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh --dry-run   # show what would change
~/dotfiles/setup.sh
```

`setup.sh` is safe to re-run. It:

- installs packages (`brew bundle` on macOS; fish, git, direnv, delta via apt on Linux)
  and starship, atuin and uv from their official installers into `~/.local/bin` / `~/.atuin/bin`
- symlinks each config into `~/.config`, moving anything already there to
  `~/.dotfiles-backup/<timestamp>/`
- makes fish the login shell. Root on Linux keeps bash as its login shell (so ssh,
  scp and Ansible get a POSIX shell) and interactive logins `exec fish` from `~/.bashrc`
- prints a summary and exits non-zero if any step failed

It needs root or passwordless sudo when run non-interactively over ssh. On the
servers it's run by the `dotfiles.yml` playbook in `server-maintenance`.

After the first run, `atuin login` once to sync history.

### Secrets

Secrets are **not** version controlled. Copy the example and fill in real
values:

```sh
cp config/fish/conf.d/secrets.fish.example config/fish/conf.d/secrets.fish
```

`config/fish/conf.d/secrets.fish` is gitignored.

## Homebrew

Packages, casks, VS Code extensions, and CLI tools are declared in `Brewfile`.
Regenerate it from the current machine with:

```sh
HOMEBREW_NO_AUTO_UPDATE=1 brew bundle dump --file=Brewfile --force
```

### git

Homebrew is also how I get the HTML docs for git — I find these easier to read
than `man` pages.

## Fish

Fish auto-sources everything in `config/fish/conf.d/`:

- `abbreviations.fish` — interactive git/ls abbreviations
- `init.fish` — starship, atuin, direnv, bun, docker, gcloud
- `secrets.fish` — local secrets (gitignored)

`config.fish` is intentionally near-empty.

## direnv

`config/direnv/direnvrc` defines a `layout uv` layout. Drop a `.envrc`
containing `layout uv` in any project to auto-create and activate a `uv` venv
on `cd`.
