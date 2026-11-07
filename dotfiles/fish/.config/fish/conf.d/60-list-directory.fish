# ******************************************************************************
# @file    60-list-directory.fish
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Lists the new directory after every change of it, however it changed.
# @path    ~/.config/fish/conf.d/60-list-directory.fish
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

if status is-interactive
    function __workstation_list_directory --on-variable PWD
        status is-command-substitution; and return

        if type -q eza
            eza -1 --icons=auto
        else
            ls -1
        end
    end
end
