# ******************************************************************************
# @file    y.fish
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   y: Yazi that moves the shell to its last directory (Q stays).
# @path    ~/.config/fish/functions/y.fish
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

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
