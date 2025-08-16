if status is-interactive
    # Commands to run in interactive sessions can go here
    atuin init fish | source
    abbr --add gcmsg git commit -m
    abbr --add ga git add
    abbr --add act source .venv/bin/activate.fish
    abbr --add deact deactivate
    abbr --add g git
    abbr --add gsw git switch
    abbr --add gl git pull
    abbr --add gp git push
    abbr --add la ls -lAh
    abbr --add l ls -lah
    abbr --add gst git status
    abbr --add lsa ls -lah
    abbr bl 'brew list -1'
end

starship init fish | source
set -x PIPX_HOME /Users/ryan/.config/pipx/
