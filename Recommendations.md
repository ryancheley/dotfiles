# Recommendations: adopting ideas from Jeff Triplett's dotfiles

Source: https://jefftriplett.github.io/dotfiles/overview/

This compares Jeff's setup to what you already have in this repo and lists only
the gaps worth closing, highest value first. Skip anything that doesn't fit how
you actually work — most of Jeff's complexity exists because he syncs one repo
across three Macs, which you may not need.

## What you already have (no action)

- **Starship prompt** — done (`config/starship/starship.toml`).
- **atuin** shell history — done (Jeff doesn't even mention this; you're ahead).
- **uv** for Python — done (`config/uv/`). Matches Jeff's "uv replaces pyenv".
- **Karabiner, git, nvim** configs — done.
- **Symlink installer** — your `setup.sh` is the lazy equivalent of Jeff's
  homesick. It works. Don't switch to homesick just to match him.

## Worth adding (ranked)

### 1. Brewfile — highest value, lowest effort
Jeff manages all Homebrew installs declaratively with a `Brewfile`. You
currently install git (and whatever else) by hand. One file makes a new Mac
reproducible.

```bash
# generate from what's already installed
brew bundle dump --file=Brewfile --describe
```
Then `brew bundle --file=Brewfile` on a fresh machine. Add a line to `setup.sh`
to run it. This is the single biggest reproducibility win.

### 2. direnv — per-directory environments
Jeff uses `direnv` with a custom `layout uv` so each project auto-activates its
venv on `cd`. Given you're already all-in on uv, this is a natural fit.

```bash
brew install direnv   # add to Brewfile
```
Add to fish: `direnv hook fish | source` in `config/fish/conf.d/direnv.fish`.
Minimal `.envrc` per project: `layout_uv` (define the layout once in
`~/.config/direnv/direnvrc`, copy Jeff's).

### 3. mise — only if you use non-Python runtimes
Jeff uses `mise` for Go/Node/Ruby/Rust/Bun/Deno. You have nvm + bun completions
already. If you juggle multiple Node versions and other runtimes, `mise`
replaces nvm and is faster. **If you only occasionally touch Node, skip it** —
nvm already works for you. Don't add a runtime manager you won't use.

### 4. Fold loose fish files into conf.d/
Jeff orders his bash startup via numbered files in `~/.bashrc.d/`. Fish gives
you this for free: anything in `config/fish/conf.d/*.fish` is auto-sourced at
startup. You have a `config.fish.backup` and ad-hoc edits — move exports,
aliases, and tool hooks (starship, atuin, direnv) into separate `conf.d/` files
instead of one growing `config.fish`. Delete `config.fish.backup` once migrated.

### 5. A README that documents the install
Jeff's docs are the overview you're reading. Your README is 14 lines. After
adding the Brewfile, update `setup.sh` + README so a fresh Mac is: clone →
`./setup.sh`. That's the whole point of versioned dotfiles.

## Skip these (deliberately)

- **homesick** — your `setup.sh` symlinking already does this job. YAGNI.
- **just / .justfiles** — Jeff runs tasks via `just`. You have a `just-expert`
  skill available but no justfile here, and dotfiles have few recurring tasks.
  Add one only if `setup.sh` grows multiple subcommands.
- **herdr / projects / ssh-clipboard / workon** — these are Jeff's multi-Mac
  session/remote tooling. Only relevant if you run several Macs and mosh between
  them. Not worth it for a single machine.
- **Hammerspoon / Alfred / Stream Deck** — app-level automation, orthogonal to
  dotfiles. Adopt independently if you want them, not as part of this.

## Suggested order

1. `Brewfile` + wire into `setup.sh`.
2. `direnv` with a `layout_uv`.
3. Clean up fish into `conf.d/`, delete the `.backup`.
4. Update README.
5. Revisit `mise` / `just` later only if a real need shows up.
