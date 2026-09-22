# Shared helpers for install.sh, scripts/install and scripts/configure.
# Sourced, never executed; the variables below are used by those scripts.
# shellcheck shell=bash disable=SC2034

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKUP_SUFFIX=".debian-workstation.bak"
FIREFOX_SELECTION="/etc/debian-workstation/firefox-extensions"

step() {
    printf '\n==> %s\n' "$*"
}

info() {
    printf '  -> %s\n' "$*"
}

warn() {
    printf 'warning: %s\n' "$*" >&2
}

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

# ask QUESTION [yes|no]: the second argument is the answer on plain Enter.
# Reads from the terminal, so it also works inside loops over files.
ask() {
    local question="$1" default="${2:-yes}" hint="[Y/n]" answer

    [[ "$default" == yes ]] || hint="[y/N]"

    while true; do
        read -r -p "$question $hint " answer </dev/tty

        case "${answer,,}" in
            y|yes) return 0 ;;
            n|no)  return 1 ;;
            "")    [[ "$default" == yes ]]; return ;;
        esac
    done
}

# Manifest entries without comments and blank lines.
manifest() {
    sed -e 's/[[:space:]]*#.*//' -e '/^[[:space:]]*$/d' "$@"
}

# The repository policies.json plus ExtensionSettings for the extensions
# selected on this machine (see scripts/configure/firefox-extensions.sh).
render_firefox_policies() {
    local settings='{}' id slug

    while read -r id slug _; do
        grep -qxF -- "$id" "$FIREFOX_SELECTION" 2>/dev/null || continue

        settings="$(
            jq -c \
                --arg id "$id" \
                --arg url "https://addons.mozilla.org/firefox/downloads/latest/$slug/latest.xpi" \
                '.[$id] = { installation_mode: "normal_installed", install_url: $url }' \
                <<< "$settings"
        )"
    done < <(manifest "$ROOT_DIR/packages/firefox-extensions.txt")

    jq --argjson settings "$settings" \
        'if $settings == {} then . else .policies.ExtensionSettings = $settings end' \
        "$ROOT_DIR/system/etc/firefox-esr/policies/policies.json"
}
