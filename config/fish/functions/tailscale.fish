# macOS app bundle; elsewhere fall through to the real binary
function tailscale
    set -l app /Applications/Tailscale.app/Contents/MacOS/Tailscale
    if test -x $app
        $app $argv
    else
        command tailscale $argv
    end
end
