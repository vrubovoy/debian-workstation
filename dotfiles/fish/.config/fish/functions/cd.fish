# =============================================================================
# Change directory
# =============================================================================
#
# Preserve the workstation's long-standing behaviour:
#
#   cd <directory>
#       ↓
#   change directory
#       ↓
#   automatically show its contents
#
# The actual directory change is still delegated to Fish's builtin `cd`.
#
# =============================================================================

function cd --description "Change directory and list its contents"

    if not builtin cd $argv
        return $status
    end

    # Do not produce unexpected listing output when Fish is used
    # non-interactively from scripts.
    if not status is-interactive
        return 0
    end

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