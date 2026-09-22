# Maintenance

This document describes how to keep the workstation configuration maintainable
without turning the repository into a snapshot of mutable machine state.

## Debian updates

Normal operating-system maintenance stays with APT:

    sudo apt update
    sudo apt full-upgrade

Package manifests describe what belongs on the workstation; they do not pin
Debian revision numbers.

## Package manifests

When a package becomes part of the base workstation, add its package name to the
most appropriate file under `packages/`:

- `base.txt` — bootstrap/shell fundamentals;
- `desktop.txt` — graphical session and desktop infrastructure;
- `applications.txt` — user-facing applications and CLI utilities;
- `development.txt` — version-control/authentication/development tooling;
- `external.txt` — software intentionally sourced outside Debian Stable.

Avoid listing the same package in multiple manifests unless a future installer
has an explicit reason to treat it specially.

## Dotfiles

Edit managed configuration in the repository and keep GNU Stow deployment
consistent with:

    stow --no-folding -t "$HOME" <package>

Do not turn entire mutable directories such as `~/.ssh` or `~/.gnupg` into
links to the repository.

When adding a new Stow package, update the package list in
`scripts/install/stow-dotfiles.sh` and the managed-user table in
`CONFIGURATION.md`.

## System configuration

Files under `system/` represent privileged configuration. Changes should be
copied explicitly with appropriate ownership/mode rather than linked from the
repository.

Before replacing a real system file, keep a backup until the new configuration
has been verified on the running machine.

## Session helpers

Scripts under `scripts/session/` are invoked through stable
`~/.local/bin/workstation-*` links. If a helper is renamed or added, update
`scripts/install/deploy-user-tools.sh`, the i3 binding/autostart that consumes
it, and the documentation together.

## External software

External repositories or release packages require extra scrutiny because they
are outside Debian Stable. Their origin belongs in `packages/external.txt`, and
installation logic belongs in a dedicated script rather than an ad-hoc shell
command in documentation.

## Secrets and local identity

Never commit:

- `~/.gitconfig.local`;
- SSH private keys;
- GPG private keys/trust databases;
- `known_hosts`;
- browser profiles;
- tokens or passwords.

The repository may provide scripts which create this state locally, but the
result itself stays outside version control.

## Release validation

Before declaring a release stable:

1. validate configuration syntax where tooling allows it;
2. run the configuration on the real workstation;
3. verify login, lock/suspend, networking, audio, Bluetooth and hardware keys;
4. verify browser, file managers, shell and editor workflows;
5. perform a clean Debian 13 VM installation from the documented process;
6. only then tune cosmetic details and cut the release.

## Repository validation

The repository is statically validated by GitHub Actions.

The lint workflow checks:

- text normalization and trailing whitespace;
- executable permissions on shell scripts;
- Bash syntax and ShellCheck diagnostics;
- Fish syntax;
- JSON and JSONC syntax;
- TOML syntax;
- YAML syntax;
- GitHub Actions workflow syntax;
- Rofi theme syntax;
- i3 configuration syntax;
- duplicate Debian package entries.

Repository text files are normalized to LF through `.gitattributes`.

Editor defaults are described by `.editorconfig`.

Before committing substantial configuration changes, run:

    git diff --check

and use the relevant application-specific validator where available.
