#!/usr/bin/env bash

# =============================================================================
# SSH identity
# =============================================================================
#
# Generate the workstation's Ed25519 SSH identity.
#
# The private key is user data and never enters the workstation repository.
#
# =============================================================================

set -Eeuo pipefail


KEY="$HOME/.ssh/id_ed25519"


mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"


if [[ -e "$KEY" || -e "${KEY}.pub" ]]; then

    printf 'SSH identity already exists:\n\n'
    printf '  %s\n' "$KEY"
    printf '  %s.pub\n' "$KEY"

    exit 0
fi


read -r -p "SSH key comment/email: " comment

if [[ -z "$comment" ]]; then
    comment="$USER@$(hostname)"
fi


ssh-keygen \
    -t ed25519 \
    -a 100 \
    -C "$comment" \
    -f "$KEY"


printf '\nPublic key:\n\n'

cat "${KEY}.pub"

printf '\n'