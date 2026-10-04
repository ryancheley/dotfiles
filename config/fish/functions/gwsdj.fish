function gwsdj --description 'gws using the rcheley@djangoproject.com account'
    set -lx GOOGLE_WORKSPACE_CLI_CONFIG_DIR "$HOME/.config/gws-djangoproject"
    command gws $argv
end
