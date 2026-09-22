#!/usr/bin/env bash
# Git identity and optional GPG signing for this machine. Both live in
# ~/.gitconfig.local, which the managed ~/.config/git/config includes.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

CONFIG="$HOME/.gitconfig.local"

umask 077

local_config() {
    git config --file "$CONFIG" "$@"
}

secret_keys() {
    gpg --batch --with-colons --list-secret-keys 2>/dev/null |
        awk -F: '$1 == "sec" { want = 1 } want && $1 == "fpr" { print $10; want = 0 }'
}

if local_config user.name >/dev/null; then
    info "Git identity: $(local_config user.name) <$(local_config user.email)>"
elif ask 'Set the Git name and email for this machine?'; then
    read -r -p 'Name: ' name </dev/tty
    read -r -p 'Email: ' email </dev/tty

    [[ -n "$name" && -n "$email" ]] || die 'Name and email must not be empty.'

    local_config user.name "$name"
    local_config user.email "$email"
else
    exit 0
fi

if local_config user.signingkey >/dev/null; then
    info "Git signing key: $(local_config user.signingkey)"
    exit 0
fi

ask 'Sign Git commits and tags with GPG?' no || exit 0

# Lets pinentry ask for the passphrase on this terminal outside X.
if tty_path="$(tty 2>/dev/null)"; then
    export GPG_TTY="$tty_path"
fi

mapfile -t keys < <(secret_keys)

if (( ${#keys[@]} == 0 )); then
    ask 'No GPG secret key found. Generate one now?' || exit 0
    gpg --full-generate-key
    mapfile -t keys < <(secret_keys)
    (( ${#keys[@]} > 0 )) || die 'No GPG secret key is available.'
fi

if (( ${#keys[@]} == 1 )); then
    key="${keys[0]}"
else
    gpg --list-secret-keys --keyid-format=long
    read -r -p 'Fingerprint of the signing key: ' key </dev/tty

    [[ " ${keys[*]} " == *" $key "* ]] || die "$key is not a local secret key."
fi

local_config user.signingkey "$key"
local_config commit.gpgSign true
local_config tag.gpgSign true

info "Git signs with $key"
