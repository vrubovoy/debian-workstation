# List the new directory after every change: cd, z, y, ffcd, prevd, ...
# A PWD handler instead of a cd wrapper keeps Fish's own cd, so cd -, prevd,
# nextd and Alt+Left/Right history keep working.

if status is-interactive
    function __workstation_list_directory --on-variable PWD
        status is-command-substitution; and return

        if type -q eza
            eza -lah --git --group-directories-first --icons=auto
        else
            ls -lah
        end
    end
end
