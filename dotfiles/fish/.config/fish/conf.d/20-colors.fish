# =============================================================================
# Fish — Graphite Blue
# =============================================================================
#
# Syntax colors shared conceptually with Kitty and Neovim.
#
# =============================================================================

# Normal commands/text.
set -g fish_color_normal E6E9EF

# Valid command.
set -g fish_color_command 7AA2F7 --bold

# Keywords such as if/for/function.
set -g fish_color_keyword C678DD --bold

# Quoted strings.
set -g fish_color_quote 98C379

# Redirect operators.
set -g fish_color_redirection 56B6C2

# Command substitution / operators.
set -g fish_color_end 56B6C2

# Errors / invalid commands.
set -g fish_color_error E06C75 --bold

# Parameters.
set -g fish_color_param E6E9EF

# Comments.
set -g fish_color_comment 5C6370 --italics

# Selections.
set -g fish_color_selection --background=303744 E6E9EF

# Search matches.
set -g fish_color_search_match --background=303744 E6E9EF

# Autosuggestion.
set -g fish_color_autosuggestion 5C6370

# Paths / working directory.
set -g fish_color_cwd 7AA2F7 --bold
set -g fish_color_cwd_root E06C75 --bold

# User/host.
set -g fish_color_user 98C379
set -g fish_color_host 7AA2F7
set -g fish_color_host_remote E5C07B

# Cancelled command.
set -g fish_color_cancel E06C75

# Completion pager.
set -g fish_pager_color_progress 8E98A8
set -g fish_pager_color_prefix 7AA2F7 --bold
set -g fish_pager_color_completion E6E9EF
set -g fish_pager_color_description 8E98A8
set -g fish_pager_color_selected_background --background=303744