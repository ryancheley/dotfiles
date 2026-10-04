# Dotfiles

These are my versioned dotfiles based on the ideas from the book [Boost Your Git DX](https://adamchainz.gumroad.com/l/byddx).

## Install

On a fresh Mac:

```sh
git clone <this-repo> ~/code/dotfiles
cd ~/code/dotfiles
./setup.sh
```

`setup.sh` symlinks each config into `~/.config` and, if Homebrew is present,
installs everything in the `Brewfile`.

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
