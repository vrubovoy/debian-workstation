#!/usr/bin/env bash
# Ed25519 SSH key for this machine; the managed ~/.ssh/config uses it for GitHub.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

KEY="$HOME/.ssh/id_ed25519"

if [[ -e "$KEY" || -e "$KEY.pub" ]]; then
    info "SSH key: $KEY"
    exit 0
fi

ask 'Generate an Ed25519 SSH key?' || exit 0

default_comment="$(id -un)@$(hostname)"
read -r -p "Key comment [$default_comment]: " comment </dev/tty

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keygen -t ed25519 -a 100 -C "${comment:-$default_comment}" -f "$KEY"

printf '\nPublic key:\n\n'
cat "$KEY.pub"
