#!/usr/bin/env bash

# =============================================================================
# Local Git identity
# =============================================================================
#
# Creates workstation-local Git identity configuration.
#
# Personal identity is intentionally excluded from the public workstation
# repository.
#
# =============================================================================

set -Eeuo pipefail


CONFIG="$HOME/.gitconfig.local"


# =============================================================================
# Existing configuration
# =============================================================================

if [[ -e "$CONFIG" ]]; then
    printf 'Git local configuration already exists:\n\n'
    printf '  %s\n\n' "$CONFIG"
    exit 0
fi


# =============================================================================
# Identity
# =============================================================================

read -r -p "Git user name: " git_name
read -r -p "Git email: " git_email

if [[ -z "$git_name" || -z "$git_email" ]]; then
    printf 'Name and email must not be empty.\n' >&2
    exit 1
fi


# =============================================================================
# Write
# =============================================================================

umask 077

cat > "$CONFIG" <<EOF
# =============================================================================
# Machine-local Git configuration
# =============================================================================
#
# This file is intentionally not tracked by debian-workstation.
#

[user]
    name = $git_name
    email = $git_email
EOF


printf '\nCreated:\n\n  %s\n' "$CONFIG"