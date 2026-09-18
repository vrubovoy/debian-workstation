# =============================================================================
# Yazi shell wrapper
# =============================================================================
#
# Start Yazi, synchronize its final directory back to Fish and automatically
# list the resulting directory.
#
#   q
#       quit Yazi, change Fish CWD and show directory contents;
#
#   Q
#       quit without changing Fish CWD, but still show the current directory.
#
# =============================================================================

function y --description "Open Yazi and follow its final directory"

    set -l cwd_file (
        mktemp -t "yazi-cwd.XXXXXX"
    )

    command yazi \
        $argv \
        --cwd-file="$cwd_file"

    if test -f "$cwd_file"

        set -l cwd (
            command cat -- "$cwd_file"
        )

        if test -n "$cwd"
            and test "$cwd" != "$PWD"
            and test -d "$cwd"

            builtin cd -- "$cwd"

        end

    end

    command rm -f -- "$cwd_file"


    # Preserve the old workflow: after leaving Yazi immediately show where
    # we ended up and what is in the directory.

    if type -q eza

        command eza \
            -lah \
            --git \
            --group-directories-first \
            --icons=auto

    else

        command ls -lah

    end

end