# Tool shell integrations and PATH setup.

# Prompt + history
starship init fish | source
status is-interactive && atuin init fish | source

# direnv (spelled "dirnev" in the old config.fish — fixed)
direnv hook fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# Docker Desktop
fish_add_path /Users/ryan/.docker/bin

# Google Cloud SDK
if test -f '/Users/ryan/Downloads/google-cloud-sdk/path.fish.inc'
    source '/Users/ryan/Downloads/google-cloud-sdk/path.fish.inc'
end
