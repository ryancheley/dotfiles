# Tool shell integrations. Each is skipped when the tool isn't installed, so a
# fresh server doesn't print errors on every shell start. PATH is in 00-path.fish,
# atuin in atuin.fish.

type -q starship; and starship init fish | source
type -q direnv; and direnv hook fish | source

set --export BUN_INSTALL "$HOME/.bun"

# Google Cloud SDK
test -f ~/Downloads/google-cloud-sdk/path.fish.inc; and source ~/Downloads/google-cloud-sdk/path.fish.inc
