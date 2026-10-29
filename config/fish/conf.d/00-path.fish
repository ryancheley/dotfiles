# PATH for tools installed outside the package manager (uv, atuin, starship,
# cargo, bun, Docker Desktop, Homebrew). Dirs that don't exist on this machine
# are skipped, so the same list works on macOS and Linux.
# Named 00-* so it runs before the other conf.d files that call these tools.
fish_add_path --global (path filter -d \
    ~/.local/bin ~/.atuin/bin ~/.docker/bin ~/.bun/bin \
    /Applications/Obsidian.app/Contents/MacOS ~/.cargo/bin /opt/homebrew/bin)
