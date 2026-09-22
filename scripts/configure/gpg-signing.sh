#!/usr/bin/env bash

# =============================================================================
# Git / GnuPG signing
# =============================================================================
#
# Optionally connects a local GnuPG secret key to the machine-local Git config.
# GPG keys themselves remain private user state and are never written into the
# workstation repository.
# =============================================================================

set -Eeuo pipefail

CONFIG="$HOME/.gitconfig.local"

if [[ ! -f "$CONFIG" ]]; then
    printf 'Git local configuration does not exist:\n\n' >&2
    printf '  %s\n\n' "$CONFIG" >&2
    printf 'Run scripts/configure/git-local.sh first.\n' >&2
    exit 1
fi

for command in gpg git; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Required command is missing: %s\n' "$command" >&2
        exit 1
    fi
done

if tty_path="$(tty 2>/dev/null)"; then
    export GPG_TTY="$tty_path"
fi


secret_fingerprints()
{
    gpg \
        --batch \
        --with-colons \
        --list-secret-keys 2>/dev/null |
        awk -F: '
            $1 == "sec" { want_fingerprint = 1; next }
            want_fingerprint && $1 == "fpr" {
                print $10
                want_fingerprint = 0
            }
        '
}


mapfile -t fingerprints < <(secret_fingerprints)

if (( ${#fingerprints[@]} == 0 )); then
    read -r -p 'No GPG secret keys found. Generate one now? [Y/n] ' answer

    case "${answer,,}" in
        ""|y|yes)
            gpg --full-generate-key
            mapfile -t fingerprints < <(secret_fingerprints)
            ;;
        *)
            printf 'GPG signing configuration skipped.\n'
            exit 0
            ;;
    esac
fi

if (( ${#fingerprints[@]} == 0 )); then
    printf 'No GPG secret key is available after key generation.\n' >&2
    exit 1
fi

printf '\nAvailable secret keys:\n\n'
gpg --list-secret-keys --keyid-format=long
printf '\n'

if (( ${#fingerprints[@]} == 1 )); then
    fingerprint="${fingerprints[0]}"
    read -r -p "Use ${fingerprint} for Git signing? [Y/n] " answer

    case "${answer,,}" in
        ""|y|yes)
            ;;
        *)
            printf 'GPG signing configuration skipped.\n'
            exit 0
            ;;
    esac
else
    read -r -p 'GPG signing key fingerprint: ' fingerprint

    if [[ -z "$fingerprint" ]]; then
        printf 'Fingerprint must not be empty.\n' >&2
        exit 1
    fi

    found=false
    for candidate in "${fingerprints[@]}"; do
        if [[ "$candidate" == "$fingerprint" ]]; then
            found=true
            break
        fi
    done

    if [[ "$found" != true ]]; then
        printf 'The selected fingerprint is not a local secret key.\n' >&2
        exit 1
    fi
fi

git config --file "$CONFIG" user.signingkey "$fingerprint"
git config --file "$CONFIG" commit.gpgSign true
git config --file "$CONFIG" tag.gpgSign true

printf '\nGit signing enabled with key:\n\n  %s\n' "$fingerprint"
