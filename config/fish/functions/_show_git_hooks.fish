function _show_git_hooks --on-variable PWD
    set -l git_dir (git rev-parse --git-dir 2>/dev/null)
    if ! test -d "$git_dir/hooks"
        # clear the shown hooks dir, since we have left a repo
        set -e _git_shown_hooks_dir
        return
    end

    set -l hooks_dir_rel "$git_dir/hooks"
    set -l hooks_dir (realpath -- "$hooks_dir_rel")

    # only announce once per repo, since this function is called on every prompt
    if set -q _git_shown_hooks_dir
        if test "$_git_shown_hooks_dir" = "$hooks_dir"
            return
        end
    end

    set -g _git_shown_hooks_dir "$hooks_dir"

    set -l hooks
    for hook in (find "$hooks_dir" -type f | sort)
        if test -x "$hook"; and not string match -q '*.sample' -- "$hook"; and not string match -q '*.disabled' -- "$hook"; and not string match -q '*.txt' -- "$hook"
            set -a hooks "$hook"
        end
    end
    if test (count $hooks) -gt 0
        echo "Git hooks found in $hooks_dir_rel:"
        for hook in $hooks
            echo "  - "(basename $hook)
        end
    end
end
