# Fish. Environment, colors, abbreviations and integrations live in conf.d/,
# commands in functions/.

if status is-interactive; and type -q starship
    starship init fish | source
end
