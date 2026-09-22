# Yazi that leaves the shell in its last directory: quit with q to follow it,
# with Q to stay. The directory is listed either way.
function y --description "Open Yazi and follow its last directory"
    set -l cwd_file (mktemp -t yazi-cwd.XXXXXX)

    command yazi $argv --cwd-file="$cwd_file"

    set -l cwd (command cat -- "$cwd_file")
    command rm -f -- "$cwd_file"

    if test -n "$cwd" -a "$cwd" != "$PWD" -a -d "$cwd"
        cd -- "$cwd"
    else
        __workstation_list_directory
    end
end
