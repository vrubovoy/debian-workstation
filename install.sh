#!/usr/bin/env bash

# =============================================================================
# Debian Workstation installer
# =============================================================================
#
# Idempotent orchestration for the repository-managed Debian 13 workstation.
#
# Normal installation:
#
#   ./install.sh
#
# Graphical post-login configuration after the first i3 login:
#
#   ./install.sh --post-login
#
# The normal installer can be run from a TTY. If it is already running inside
# an X11 session, the graphical post-login phase is offered immediately.
# =============================================================================

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER="$(id -un)"
MODE="install"


# =============================================================================
# Output helpers
# =============================================================================

section()
{
    printf '\n\n==============================================================================\n'
    printf '%s\n' "$1"
    printf '==============================================================================\n\n'
}

info()
{
    printf '[INFO] %s\n' "$*"
}

warn()
{
    printf '[WARN] %s\n' "$*" >&2
}

fatal()
{
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}

ask_yes_no()
{
    local prompt="$1"
    local default="${2:-yes}"
    local suffix
    local answer

    if [[ "$default" == "yes" ]]; then
        suffix='[Y/n]'
    else
        suffix='[y/N]'
    fi

    read -r -p "$prompt $suffix " answer </dev/tty

    case "${answer,,}" in
        y|yes)
            return 0
            ;;
        n|no)
            return 1
            ;;
        "")
            [[ "$default" == "yes" ]]
            return
            ;;
        *)
            printf 'Please answer yes or no.\n' >&2
            ask_yes_no "$prompt" "$default"
            ;;
    esac
}


# =============================================================================
# Arguments
# =============================================================================

usage()
{
    cat <<'USAGE'
Usage:
  ./install.sh               Install/configure the workstation.
  ./install.sh --post-login  Run graphical user-session configuration only.
  ./install.sh --help        Show this help.
USAGE
}

case "${1:-}" in
    "")
        ;;
    --post-login)
        MODE="post-login"
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

if (( $# > 1 )); then
    usage >&2
    exit 2
fi


# =============================================================================
# Graphical post-login phase
# =============================================================================

run_post_login()
{
    section 'Graphical post-login configuration'

    if [[ -z "${DISPLAY:-}" ]]; then
        fatal 'The post-login phase must run from an X11 graphical session.'
    fi

    for command in gsettings copyq firefox-esr; do
        command -v "$command" >/dev/null 2>&1 || \
            fatal "Required post-login command is missing: $command"
    done

    info 'Applying GTK/GSettings appearance.'
    "$ROOT_DIR/scripts/configure/appearance.sh"

    info 'Configuring CopyQ clipboard history.'
    "$ROOT_DIR/scripts/configure/copyq.sh"

    if ask_yes_no 'Review optional Firefox extensions?' yes; then
        "$ROOT_DIR/scripts/configure/firefox-extensions.sh"
    fi

    printf '\nPost-login configuration complete.\n'
}

if [[ "$MODE" == "post-login" ]]; then
    run_post_login
    exit 0
fi


# =============================================================================
# Preflight
# =============================================================================

section 'Preflight'

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    fatal 'Run install.sh as the normal workstation user, not as root.'
fi

if [[ ! -r /etc/os-release ]]; then
    fatal 'Cannot identify the operating system.'
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "debian" || "${VERSION_ID:-}" != "13" ]]; then
    fatal "This installer targets Debian 13. Detected: ${PRETTY_NAME:-unknown}."
fi

for command in sudo apt-get dpkg curl stow; do
    command -v "$command" >/dev/null 2>&1 || \
        fatal "Required bootstrap command is missing: $command"
done

info "Repository: $ROOT_DIR"
info "System: ${PRETTY_NAME:-Debian 13}"
info "User: $CURRENT_USER"

sudo -v


# =============================================================================
# External APT repositories
# =============================================================================

section 'APT repositories'

"$ROOT_DIR/scripts/install/setup-debian-repositories.sh"
"$ROOT_DIR/scripts/install/setup-yazi-repository.sh"


# =============================================================================
# Debian packages
# =============================================================================

section 'Debian packages'

manifests=(
    "$ROOT_DIR/packages/base.txt"
    "$ROOT_DIR/packages/desktop.txt"
    "$ROOT_DIR/packages/applications.txt"
    "$ROOT_DIR/packages/development.txt"
)

packages=()

for manifest in "${manifests[@]}"; do
    [[ -f "$manifest" ]] || fatal "Package manifest is missing: $manifest"

    while IFS= read -r package; do
        packages+=("$package")
    done < <(
        awk '
            /^[[:space:]]*#/ { next }
            /^[[:space:]]*$/ { next }
            { print $1 }
        ' "$manifest"
    )
done

# Yazi lives in its explicitly configured upstream APT repository and therefore
# is deliberately not duplicated in the Debian package manifests.
packages+=(yazi)

sudo apt-get install -y "${packages[@]}"


# =============================================================================
# Pinned upstream packages
# =============================================================================

section 'Pinned upstream packages'

"$ROOT_DIR/scripts/install/install-onefetch.sh"
"$ROOT_DIR/scripts/install/install-vscodium.sh"


# =============================================================================
# System configuration
# =============================================================================

section 'System configuration'

"$ROOT_DIR/scripts/install/deploy-system-config.sh"


# =============================================================================
# User configuration
# =============================================================================

section 'User configuration'

"$ROOT_DIR/scripts/install/stow-dotfiles.sh"
"$ROOT_DIR/scripts/install/deploy-user-tools.sh"
"$ROOT_DIR/scripts/configure/defaults.sh"


# =============================================================================
# Appearance
# =============================================================================

section 'Desktop appearance'

if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    "$ROOT_DIR/scripts/configure/appearance.sh"
elif command -v dbus-run-session >/dev/null 2>&1; then
    dbus-run-session -- "$ROOT_DIR/scripts/configure/appearance.sh"
else
    warn 'Could not apply GSettings outside a graphical D-Bus session.'
    warn 'Run scripts/configure/appearance.sh after logging into i3.'
fi


# =============================================================================
# Personal identity / credentials
# =============================================================================

section 'Personal configuration'

if ask_yes_no 'Configure machine-local Git name and email?' yes; then
    "$ROOT_DIR/scripts/configure/git-local.sh"
fi

if ask_yes_no 'Generate an Ed25519 SSH key if one does not exist?' yes; then
    "$ROOT_DIR/scripts/configure/ssh-key.sh"
fi

if ask_yes_no 'Configure GPG signing for Git commits and tags?' no; then
    "$ROOT_DIR/scripts/configure/gpg-signing.sh"
fi


# =============================================================================
# VSCodium extensions
# =============================================================================

section 'VSCodium extensions'

if ask_yes_no 'Review optional VSCodium extensions?' yes; then
    "$ROOT_DIR/scripts/configure/vscodium-extensions.sh"
fi


# =============================================================================
# Graphical user-session configuration
# =============================================================================

if [[ -n "${DISPLAY:-}" ]]; then
    if ask_yes_no 'Run graphical post-login configuration now?' yes; then
        run_post_login
    fi
else
    section 'Post-login step required'

    cat <<'POSTLOGIN'
The base workstation installation is complete.

CopyQ and Firefox extension setup require a running X11 session. After logging
into i3, run:

    ./install.sh --post-login
POSTLOGIN
fi


# =============================================================================
# Finished
# =============================================================================

section 'Installation complete'

cat <<'DONE'
The repository-managed workstation configuration has been deployed.

A logout/reboot is required before all changes are active, including:

  - LightDM configuration;
  - X11 input configuration;
  - keyboard configuration;
  - default Fish login shell;
  - enabled desktop services.

The installer is idempotent and can be run again after repository updates.
DONE
