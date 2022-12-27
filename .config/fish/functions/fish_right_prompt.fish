function fish_right_prompt --description 'Write out the right prompt'
    set -l exit_code $status
    set -l is_git_repository (git rev-parse --is-inside-work-tree 2> /dev/null)
    set -l max_shlvl 1; and test "$TERM" = screen; and set -l max_shlvl 2

    # Print a fork symbol when in a subshell
    if test $SHLVL -gt $max_shlvl
        set_color yellow
        echo -n "⑂ "
        set_color normal
    end

    # Print a red dot for failed commands.
    if test $exit_code -ne 0
        set_color red
        echo -n "• "
        set_color normal
    end

    # Print coloured arrows when git push (up) and git pull (down) should be run.
    #
    # Red means the local branch and the upstream branch have diverted.
    # Yellow means there it's time to push or pull.
    if test -n "$is_git_repository"
        if __has_upstream
            set -l commit_counts (git rev-list --left-right --count 'HEAD...@{upstream}' 2> /dev/null)
            set -l commits_to_push (echo $commit_counts | cut -f 1 2> /dev/null)
            set -l commits_to_pull (echo $commit_counts | cut -f 2 2> /dev/null)

            if test $commits_to_push -gt 0
                if test $commits_to_pull -gt 0
                    set_color red
                else
                    set_color yellow
                end

                echo -n "⇡ "
            end

            if test $commits_to_pull -gt 0
                if test $commits_to_push -gt 0
                    set_color red
                else
                    set_color yellow
                end

                echo -n "⇣ "
            end

            set_color normal
        end
    end

    if __has_stashed_files
        echo -n "☰ "
    end

    # Print the username when the user has been changed.
    if test $USER != $LOGNAME
        set_color black
        echo -n "$USER@"
        set_color normal
    end

    # Print the current directory.
    echo -n (pwd | sed -e "s|^$HOME|~|")

    # Print the current git branch name or shortened commit hash in colour.
    #
    # Green means the working directory is clean.
    # Blue means the working directory is clean, save for untracked files.
    # Yellow means all changed files have been staged
    # Red means there are changed files that are not yet staged.
    if test -n "$is_git_repository"
        echo -n ":"

        if __has_unstaged_files
            set_color red
        else if __has_staged_files
            set_color yellow
        else if __has_untracked_files
            set_color blue
        else
            set_color green
        end

        echo -n (__branch_name)

        set_color normal
    end
end
