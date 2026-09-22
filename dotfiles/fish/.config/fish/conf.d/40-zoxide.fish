# `z` jumps to directories from history; Yazi uses the same database.

if status is-interactive; and type -q zoxide
    zoxide init fish | source
end
