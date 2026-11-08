#!/usr/bin/env bash
# 02Gnome, an installer that configures a GNOME desktop in one run.
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Usage (one-liner):
#   curl -fsSL https://raw.githubusercontent.com/EggyStudio/02Gnome/main/install.sh | bash

set -euo pipefail

REPO_URL="https://github.com/EggyStudio/02Gnome"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
GUM_AVAILABLE=true
USE_OLED=false
PROFILE=desktop
INSTALLED_DOCKER_SERVICES=()
IS_ATOMIC=false

_source_modules() {
    local script_dir="$DOTFILES_DIR/scripts"
    if [ ! -d "$script_dir" ]; then
        error "Scripts directory not found at $script_dir"
        exit 1
    fi

    # shellcheck source=scripts/01-common.sh
    source "$script_dir/01-common.sh"
    # shellcheck source=scripts/02-bootstrap.sh
    source "$script_dir/02-bootstrap.sh"
    # shellcheck source=scripts/03-docker.sh
    source "$script_dir/03-docker.sh"
    # shellcheck source=scripts/04-extensions.sh
    source "$script_dir/04-extensions.sh"
    # shellcheck source=scripts/05-apps.sh
    source "$script_dir/05-apps.sh"
    # shellcheck source=scripts/06-gnome.sh
    source "$script_dir/06-gnome.sh"
    # shellcheck source=scripts/07-themes.sh
    source "$script_dir/07-themes.sh"
    # shellcheck source=scripts/08-cleanup.sh
    source "$script_dir/08-cleanup.sh"
}

# These stand in for the modules' helpers until the modules are sourced.
_CYAN='\033[0;36m'
_BOLD='\033[1m'
_NC='\033[0m'
_YELLOW='\033[1;33m'
_RED='\033[0;31m'

info()    { echo -e "${_CYAN}[INFO]${_NC}  $*"; }
warning() { echo -e "${_YELLOW}[WARN]${_NC}  $*"; }
error()   { echo -e "${_RED}[ERROR]${_NC} $*" >&2; }

_early_detect_atomic() {
    if [ -f /run/ostree-booted ] || command -v rpm-ostree &>/dev/null; then
        IS_ATOMIC=true
        info "Detected atomic/immutable Fedora (rpm-ostree)."
        info "Adapting installation accordingly."
    fi
}

_early_install_git() {
    if command -v git &>/dev/null; then return; fi
    info "Installing git"
    if [ "$IS_ATOMIC" = true ]; then
        # Every rpm-ostree call runs through sudo, as root, which polkit does not
        # question. Run as the user, rpm-ostree asks polkit, whose dialog would
        # stop the run at that step.
        sudo rpm-ostree install --idempotent --allow-inactive -y git 2>/dev/null || true
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y git
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update -y && sudo apt-get install -y git
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm git
    else
        error "Cannot install git. Please install it manually and re-run."
        exit 1
    fi
}

# An existing clone is updated only by a fast-forward. A clone whose history no
# longer leads to the repository's stops the run with the steps to replace it,
# since a reset would discard the user's edits to config.sh.
_early_clone_repo() {
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        git clone -q "$REPO_URL" "$DOTFILES_DIR"
        return
    fi

    if ! git -C "$DOTFILES_DIR" fetch -q origin; then
        warning "The repository could not be fetched, so the clone at $DOTFILES_DIR runs as it is."
        return
    fi

    local upstream
    upstream=$(git -C "$DOTFILES_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) \
        || upstream="origin/main"

    if git -C "$DOTFILES_DIR" merge-base --is-ancestor HEAD "$upstream"; then
        if git -C "$DOTFILES_DIR" merge --ff-only -q "$upstream" 2>/dev/null; then
            return
        fi
        error "The clone at $DOTFILES_DIR has edits that the update would overwrite."
        error "Commit or move aside the edited files, carrying edits to config.sh over by hand, then run the installer again."
        exit 1
    fi

    error "The clone at $DOTFILES_DIR no longer follows the repository's history."
    error "Move it aside, for example with mv $DOTFILES_DIR $DOTFILES_DIR.old, or remove it, then run the installer again."
    error "Edits to config.sh in the old clone are carried over to the new one by hand."
    exit 1
}

main() {
    echo ""
    echo -e "${_CYAN}${_BOLD}"
    cat << 'BANNER'
 ██████╗ ██████╗      ██████╗ ███╗   ██╗ ██████╗ ███╗   ███╗███████╗
██╔═████╗╚════██╗    ██╔════╝ ████╗  ██║██╔═══██╗████╗ ████║██╔════╝
██║██╔██║ █████╔╝    ██║  ███╗██╔██╗ ██║██║   ██║██╔████╔██║█████╗  
████╔╝██║██╔═══╝     ██║   ██║██║╚██╗██║██║   ██║██║╚██╔╝██║██╔══╝  
╚██████╔╝███████╗    ╚██████╔╝██║ ╚████║╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚═════╝ ╚══════╝     ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
BANNER
    echo -e "${_NC}"

    # 1. Atomic Fedora is detected, git installed and this repository cloned,
    # before the modules can be sourced.
    _early_detect_atomic
    _early_install_git
    _early_clone_repo

    # 2. The configuration and the modules.
    # shellcheck source=config.sh
    source "$DOTFILES_DIR/config.sh"
    _source_modules

    # 3. Sudo's password, then gum for the questions.
    start_sudo_keepalive
    install_gum

    # 4. Where the lists live, and whether to start.
    echo ""
    info "The repository is in ${BOLD}${DOTFILES_DIR}${NC}."
    info "The lists of applications, extensions and services are in ${BOLD}${DOTFILES_DIR}/config.sh${NC},"
    info "and each profile's GNOME settings in ${BOLD}${DOTFILES_DIR}/gnome/<profile>/${NC}."
    echo ""
    if ! ask_yes_no yes "Start the installation?"; then
        info "The installation is canceled. Edit config.sh and run the installer again."
        exit 0
    fi

    # 5. Every question, so the steps after them run without the user.
    echo ""
    ask_profile
    ask_install_tailscale
    ask_oled_preference
    ask_user_preferences
    ask_download_wallpapers
    ask_uninstall_bloat
    ask_optional_apps
    ask_docker_services
    ask_nvidia_drivers
    ask_reboot
    echo ""
    info "The answers are complete, and the installation runs without further questions."
    echo ""

    # 6. System update
    system_update

    # 7. Core tools
    install_flatpak
    install_gnome_menus
    install_docker
    install_tailscale
    install_fastfetch

    # 8. The profile's GNOME settings and setup script
    import_gnome_settings "$PROFILE"
    run_profile "$PROFILE"

    # 9. Essential Flatpaks and GNOME Shell extensions, then the profile's
    # settings again, since enabling an extension rewrites the enabled list.
    install_essential_flatpaks
    install_gnome_extensions
    wait_for_extension_settings
    import_gnome_settings "$PROFILE"

    # 10. Adwaita themes
    setup_themes

    # 11. Rewaita themes
    install_rewaita_themes

    # 12. Oled settings
    apply_oled_preference

    # 13. Add Water and Firefox
    configure_addwater
    configure_firefox

    # 14. User preferences
    apply_user_preferences

    # 15. Nautilus
    configure_nautilus

    # 16. Templates
    setup_templates

    # 17. Default applications
    configure_app_defaults

    # 18. Wallpapers
    download_wallpapers

    # 19. GNOME applications removed
    uninstall_bloat

    # 20. Optional applications
    install_optional_apps

    # 21. Docker Compose services
    install_docker_services

    # 22. Web app shortcuts
    create_docker_web_apps

    # 23. Dock favorites
    pin_optional_apps_to_favorites

    # 24. OpenCode shortcut
    register_opencode_shortcut

    # 25. App grid reset
    reset_app_grid

    # 26. NVIDIA drivers
    install_nvidia_drivers

    # 27. Final update and cleanup
    final_cleanup

    # 28. Reboot
    echo ""
    info "The installation is complete."
    if [ "$WANT_TAILSCALE" = true ]; then
        info "Sign in to Tailscale with sudo tailscale up."
    fi
    reboot_if_chosen
}

main "$@"
