#!/usr/bin/env bash
# 02Gnome's common helpers, colors and package management.
# install.sh sources this file, which is not run on its own.

YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
warning() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

GUM_CONFIRM_STYLE_FLAGS=(
    "--selected.foreground="
    "--selected.background=238"
    "--unselected.foreground="
    "--unselected.background="
    "--prompt.foreground="
    "--prompt.background="
)

GUM_CHOOSE_STYLE_FLAGS=(
    "--header.foreground="
    "--header.background="
    "--selected.foreground="
    "--selected.background="
    "--cursor.foreground="
    "--cursor.background="
    "--item.foreground="
    "--item.background="
)

gum_confirm_styled() {
    gum confirm "${GUM_CONFIRM_STYLE_FLAGS[@]}" "$@"
}

gum_choose_styled() {
    gum choose "${GUM_CHOOSE_STYLE_FLAGS[@]}" "$@"
}

# Answers are read from the terminal and prompts written to standard error,
# since under curl | bash standard input is the script itself and a choice is
# returned on standard output.
_use_gum() {
    [ "$GUM_AVAILABLE" = true ] && command -v gum &>/dev/null
}

# ask_yes_no <yes|no> <question> succeeds when the answer is yes.
ask_yes_no() {
    local default="$1" question="$2"

    if _use_gum; then
        gum_confirm_styled --default="$default" "  $question" < /dev/tty
        return
    fi

    local hint="[y/N]"
    [ "$default" = yes ] && hint="[Y/n]"
    echo -e "${CYAN}${BOLD}${question}${NC} ${hint}" >&2
    local answer=""
    read -rp "> " answer < /dev/tty || true
    case "$answer" in
        [yY]*) return 0 ;;
        [nN]*) return 1 ;;
        *) [ "$default" = yes ] ;;
    esac
}

# ask_choose_one <header> <option>... prints the option chosen, or nothing.
ask_choose_one() {
    local header="$1"
    shift

    if _use_gum; then
        gum_choose_styled --header "  $header" "$@" < /dev/tty || true
        return
    fi

    echo -e "${CYAN}${BOLD}${header}${NC}" >&2
    local i
    for ((i = 1; i <= $#; i++)); do
        printf '  %2d) %s\n' "$i" "${!i}" >&2
    done
    local choice=""
    read -rp "> " choice < /dev/tty || true
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $# ]; then
        printf '%s\n' "${!choice}"
    fi
}

# ask_choose_many <header> <all|none> <option>... prints the options chosen, one
# per line. The second argument names the options selected before the user
# changes them.
ask_choose_many() {
    local header="$1" preselect="$2"
    shift 2

    if _use_gum; then
        local selected_flag=()
        if [ "$preselect" = all ]; then
            selected_flag=("--selected=$(IFS=,; echo "$*")")
        fi
        gum_choose_styled --no-limit --height="$#" "${selected_flag[@]}" \
            --header "  $header (↑/↓ move, Space select, Enter confirm):" \
            "$@" < /dev/tty || true
        return
    fi

    echo -e "${CYAN}${BOLD}${header}${NC}" >&2
    local i
    for ((i = 1; i <= $#; i++)); do
        printf '  %2d) %s\n' "$i" "${!i}" >&2
    done
    if [ "$preselect" = all ]; then
        echo "Enter the numbers to keep, separated by spaces, or press Enter for all of them." >&2
    else
        echo "Enter the numbers to choose, separated by spaces, or press Enter for none." >&2
    fi
    local choices=""
    read -rp "> " choices < /dev/tty || true
    if [ -z "$choices" ] && [ "$preselect" = all ]; then
        printf '%s\n' "$@"
        return
    fi
    local num
    for num in $choices; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le $# ]; then
            printf '%s\n' "${!num}"
        fi
    done
}

# The steps take longer than sudo keeps a password, so the credential is renewed
# in the background until the installer exits and no step stops for it.
start_sudo_keepalive() {
    if ! sudo -v; then
        error "The installer needs sudo."
        exit 1
    fi
    (
        while kill -0 "$$" 2>/dev/null; do
            sudo -n true 2>/dev/null || true
            sleep 60
        done
    ) &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
}

detect_atomic() {
    if [ -f /run/ostree-booted ] || command -v rpm-ostree &>/dev/null; then
        IS_ATOMIC=true
        info "Detected atomic/immutable Fedora (rpm-ostree)."
        info "Adapting installation accordingly."
    fi
}

pkg_install() {
    local pkg="$1"
    if [ "$IS_ATOMIC" = true ]; then
        info "Layering $pkg via rpm-ostree"
        sudo rpm-ostree install --idempotent --allow-inactive -y "$pkg" 2>/dev/null \
            || warning "Could not layer $pkg via rpm-ostree."
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$pkg" 2>/dev/null \
            || warning "Could not install $pkg via dnf."
    elif command -v apt-get &>/dev/null; then
        sudo apt-get install -y "$pkg" 2>/dev/null \
            || warning "Could not install $pkg via apt."
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "$pkg" 2>/dev/null \
            || warning "Could not install $pkg via pacman."
    else
        warning "No supported package manager found to install $pkg."
    fi
}

pkg_remove() {
    local pkg="$1" label="${2:-$1}"
    if [ "$IS_ATOMIC" = true ]; then
        if rpm-ostree status 2>/dev/null | grep -q "LayeredPackages:.*$pkg"; then
            info "Removing the layered package $pkg ($label)"
            sudo rpm-ostree uninstall -y "$pkg" 2>/dev/null \
                || warning "Could not remove $pkg via rpm-ostree."
        elif rpm -q "$pkg" &>/dev/null 2>&1; then
            info "Removing the base package $pkg ($label) by an override"
            sudo rpm-ostree override remove "$pkg" 2>/dev/null \
                || warning "Could not override-remove $pkg (may be required by base image)."
        fi
    elif command -v dnf &>/dev/null; then
        safe_dnf_remove "$pkg" "$label"
    elif command -v pacman &>/dev/null; then
        safe_pacman_remove "$pkg" "$label"
    fi
}

install_one_flatpak() {
    local app="$1"
    if flatpak list --app --columns=application 2>/dev/null | grep -qx "$app"; then
        info "$app is already installed."
    else
        info "Installing $app"
        LANG=C flatpak install --user -y flathub "$app" 2>&1 | cat
        [ "${PIPESTATUS[0]}" -eq 0 ] || warning "Failed to install $app, so it is skipped."
    fi
}

have_flatpak_app() {
    local app="$1"
    command -v flatpak &>/dev/null \
        && flatpak list --app --columns=application 2>/dev/null | grep -qx "$app"
}

have_snap_app() {
    local app="$1"
    command -v snap &>/dev/null && snap list "$app" &>/dev/null
}

have_firefox_install() {
    command -v firefox &>/dev/null \
        || command -v firefox-esr &>/dev/null \
        || have_flatpak_app org.mozilla.firefox \
        || have_snap_app firefox
}

ensure_rpmfusion() {
    if ! command -v dnf &>/dev/null && [ "$IS_ATOMIC" != true ]; then
        return 1
    fi
    if dnf repolist 2>/dev/null | grep -q rpmfusion; then
        return 0
    fi
    info "Enabling RPM Fusion repositories"
    local fedora_ver
    fedora_ver=$(rpm -E %fedora 2>/dev/null) || return 1
    if [ "$IS_ATOMIC" = true ]; then
        sudo rpm-ostree install --idempotent --allow-inactive -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_ver}.noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_ver}.noarch.rpm" \
            || { warning "Could not enable RPM Fusion via rpm-ostree."; return 1; }
    else
        sudo dnf install -y \
            "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_ver}.noarch.rpm" \
            "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_ver}.noarch.rpm" \
            || { warning "Could not enable RPM Fusion."; return 1; }
    fi
}

install_one_rpm() {
    local pkg="$1"
    if ! command -v dnf &>/dev/null && [ "$IS_ATOMIC" != true ]; then
        warning "$pkg is an RPM package and cannot be installed on this system, so it is skipped."
        return
    fi
    if rpm -q "$pkg" &>/dev/null; then
        info "$pkg is already installed."
        return
    fi
    if [ "$IS_ATOMIC" = true ]; then
        info "Installing $pkg via rpm-ostree"
        ensure_rpmfusion || { warning "Could not enable RPM Fusion, so $pkg is skipped."; return; }
        pkg_install "$pkg"
    else
        info "Installing $pkg via RPM"
        if ! sudo dnf install -y "$pkg" 2>/dev/null; then
            ensure_rpmfusion || { warning "Could not enable RPM Fusion, so $pkg is skipped."; return; }
            sudo dnf install -y "$pkg" || warning "Could not install $pkg via dnf."
        fi
    fi
}

# Removing one of these packages would break the desktop, so a removal that
# takes one of them along is skipped.
PROTECTED_RE="gnome-shell|gdm|mutter|gnome-session|gnome-settings-daemon"

safe_dnf_remove() {
    local pkg="$1" label="$2"
    command -v rpm &>/dev/null || return 0
    rpm -q "$pkg" &>/dev/null 2>&1 || return 0

    local sim
    sim=$(dnf remove --assumeno --setopt=clean_requirements_on_remove=True "$pkg" 2>&1 || true)
    if echo "$sim" | grep -qEi "$PROTECTED_RE"; then
        warning "$label ($pkg) stays, since removing it would also remove core desktop packages."
        return 0
    fi

    info "Removing the RPM $pkg ($label)"
    sudo dnf remove -y --noautoremove "$pkg" 2>/dev/null \
        || warning "Failed to remove $pkg."
}

safe_pacman_remove() {
    local pkg="$1" label="$2"
    pacman -Qi "$pkg" &>/dev/null 2>&1 || return 0

    local sim
    sim=$(pacman -Rcs --print "$pkg" 2>&1 || true)
    if echo "$sim" | grep -qEi "$PROTECTED_RE"; then
        warning "$label ($pkg) stays, since removing it would also remove core desktop packages."
        return 0
    fi

    info "Removing the package $pkg ($label)"
    sudo pacman -Rns --noconfirm "$pkg" 2>/dev/null \
        || warning "Failed to remove $pkg."
}

