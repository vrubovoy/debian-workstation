# =============================================================================
# Fish — shell
# =============================================================================
#
# Environment, colors, abbreviations and integrations live in conf.d/, commands
# in functions/. Starship draws the prompt.
#
# Path:  ~/.config/fish/config.fish
# Apply: exec fish

if status is-interactive; and type -q starship
    starship init fish | source
end
