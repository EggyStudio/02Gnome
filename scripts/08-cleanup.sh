#!/usr/bin/env bash
# 02Gnome's cleanup, the removal of GNOME applications, NVIDIA drivers, wallpapers and the reboot.
# install.sh sources this file, which is not run on its own.

WALLPAPER_REPO="https://github.com/dharmx/walls"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

WANT_WALLPAPERS=false

ask_download_wallpapers() {
    if ask_yes_no yes "Download the wallpaper collection to ~/Pictures/Wallpapers?"; then
        WANT_WALLPAPERS=true
    fi
}

download_wallpapers() {
    if [ "$WANT_WALLPAPERS" = false ]; then
        info "The wallpaper collection is skipped."
        return
    fi

    if [ -d "$WALLPAPER_DIR/.git" ]; then
        local pull_output=""
        pull_output=$(git -C "$WALLPAPER_DIR" pull --ff-only 2>&1) || {
            warning "Could not update wallpapers."
            return
        }

        if printf '%s' "$pull_output" | grep -qi "Already up[ -]to[ -]date"; then
            info "The wallpaper collection is up to date."
        else
            info "The wallpaper collection is updated."
        fi
    else
        info "Downloading the wallpaper collection"
        mkdir -p "$(dirname "$WALLPAPER_DIR")"
        git clone --depth 1 "$WALLPAPER_REPO" "$WALLPAPER_DIR" \
            || warning "Failed to clone wallpaper repo."
    fi

    if [ -d "$WALLPAPER_DIR" ]; then
        info "Wallpapers available at $WALLPAPER_DIR"

        local slideshow_dir="$WALLPAPER_DIR/m-26.jp"
        if [ -d "$slideshow_dir" ]; then
            dconf write /org/gnome/shell/extensions/azwallpaper/slideshow-directory "'$slideshow_dir'" 2>/dev/null || true

            local ext_schema_dir="$HOME/.local/share/gnome-shell/extensions/azwallpaper@azwallpaper.gitlab.com/schemas"
            if [ -d "$ext_schema_dir" ]; then
                GSETTINGS_SCHEMA_DIR="$ext_schema_dir" gsettings set org.gnome.shell.extensions.azwallpaper slideshow-directory "$slideshow_dir" 2>/dev/null || true
            fi
            info "Wallpaper Slideshow set to $slideshow_dir"
        fi
    fi
}

WANT_BLOAT_REMOVAL=false

ask_uninstall_bloat() {
    if ask_yes_no yes "Uninstall the GNOME applications listed in config.sh (Boxes, Characters, Connections, Contacts and others)?"; then
        WANT_BLOAT_REMOVAL=true
    fi
}

uninstall_bloat() {
    if [ "$WANT_BLOAT_REMOVAL" = false ]; then
        info "The GNOME applications stay installed."
        return
    fi

    info "Uninstalling the GNOME applications listed in config.sh"

    for entry in "${GNOME_BLOAT_APPS[@]}"; do
        local flatpak_id="${entry%%|*}"
        local rest="${entry#*|}"
        local dnf_pkg="${rest%%|*}"
        rest="${rest#*|}"
        local pacman_pkg="${rest%%|*}"
        local label="${rest#*|}"

        if [ "$flatpak_id" != "-" ]; then
            if flatpak list --app --columns=application 2>/dev/null | grep -qx "$flatpak_id"; then
                info "Removing the Flatpak $label"
                if ! flatpak uninstall -y --noninteractive "$flatpak_id" >/dev/null 2>&1; then
                    warning "Failed to remove Flatpak $label."
                fi
            fi
        fi

        if [ "$dnf_pkg" != "-" ]; then
            if [ "$IS_ATOMIC" = true ]; then
                pkg_remove "$dnf_pkg" "$label"
            elif command -v dnf &>/dev/null; then
                safe_dnf_remove "$dnf_pkg" "$label"
            fi
        fi
        if [ "$pacman_pkg" != "-" ] && command -v pacman &>/dev/null; then
            safe_pacman_remove "$pacman_pkg" "$label"
        fi
    done

    info "The GNOME applications are uninstalled."
}

WANT_NVIDIA=false

# Asked only on a machine with an NVIDIA GPU and no NVIDIA kernel module.
ask_nvidia_drivers() {
    lspci 2>/dev/null | grep -qi 'nvidia' || return 0
    if modinfo nvidia &>/dev/null; then
        info "The NVIDIA driver $(modinfo -F version nvidia 2>/dev/null || echo "") is installed."
        return 0
    fi
    if ask_yes_no yes "Install the NVIDIA proprietary drivers for $(lspci | grep -i 'nvidia' | head -1 | sed 's/.*: //')?"; then
        WANT_NVIDIA=true
    fi
}

install_nvidia_drivers() {
    local do_nvidia="$WANT_NVIDIA"
    if [ "$do_nvidia" = true ]; then
        if ! command -v dnf &>/dev/null && [ "$IS_ATOMIC" != true ]; then
            warning "The NVIDIA drivers come from RPM Fusion, which serves Fedora and its atomic variants alone."
            return
        fi
        ensure_rpmfusion || { warning "RPM Fusion could not be enabled, so the NVIDIA drivers are skipped."; return; }
        if [ "$IS_ATOMIC" = true ]; then
            info "Layering the NVIDIA drivers, akmod-nvidia with CUDA and VA-API"
            sudo rpm-ostree install --idempotent --allow-inactive -y \
                akmod-nvidia xorg-x11-drv-nvidia-cuda nvidia-vaapi-driver libva-utils \
                || warning "NVIDIA driver layering failed."
            info "The NVIDIA drivers are layered, and the kernel module builds at the reboot."
        else
            info "Installing the NVIDIA drivers, akmod-nvidia with CUDA and VA-API"
            sudo dnf install -y akmod-nvidia || warning "Failed to install akmod-nvidia."
            sudo dnf install -y xorg-x11-drv-nvidia-cuda || warning "Failed to install nvidia-cuda."
            sudo dnf install -y nvidia-vaapi-driver libva-utils || warning "Failed to install VA-API drivers."
            info "The NVIDIA drivers are installed, and the kernel module builds at the reboot."
        fi
    fi
}

final_cleanup() {
    info "Running final system cleanup & update"

    if [ "$IS_ATOMIC" = true ]; then
        info "Upgrading base image (rpm-ostree)"
        sudo rpm-ostree upgrade || warning "rpm-ostree upgrade ended with an error."
        info "Cleaning up rpm-ostree"
        sudo rpm-ostree cleanup -m 2>/dev/null || true

    elif command -v dnf &>/dev/null; then
        info "Upgrading packages (with refreshed metadata)"
        sudo dnf upgrade --refresh -y || warning "dnf upgrade encountered an error."
        info "Removing unused dependencies"
        sudo dnf autoremove -y || warning "dnf autoremove encountered an error."

        local old_kernels=()
        mapfile -t old_kernels < <(dnf repoquery --installonly --latest-limit=-2 -q 2>/dev/null || true)
        if [ ${#old_kernels[@]} -gt 0 ]; then
            info "Removing old kernels"
            sudo dnf remove -y "${old_kernels[@]}" || warning "Could not remove old kernels."
        fi

        info "Cleaning DNF cache"
        sudo dnf clean all || warning "dnf clean encountered an error."

    elif command -v apt-get &>/dev/null; then
        info "Upgrading packages"
        { sudo apt-get update -y && sudo apt-get upgrade -y; } || warning "apt upgrade encountered an error."
        info "Removing unused dependencies"
        sudo apt-get autoremove -y || warning "apt autoremove encountered an error."
        sudo apt-get clean || true

    elif command -v pacman &>/dev/null; then
        info "Upgrading packages"
        sudo pacman -Syu --noconfirm || warning "pacman update encountered an error."

        local orphans=()
        mapfile -t orphans < <(pacman -Qdtq 2>/dev/null || true)
        if [ ${#orphans[@]} -gt 0 ]; then
            info "Removing orphaned packages"
            sudo pacman -Rns --noconfirm "${orphans[@]}" || warning "Could not remove orphans."
        fi

        if command -v paccache &>/dev/null; then
            info "Cleaning pacman cache"
            sudo paccache -rk2 2>/dev/null || true
        fi
    fi

    if command -v flatpak &>/dev/null; then
        info "Updating Flatpak applications"
        LANG=C flatpak update -y --noninteractive 2>&1 | cat
        [ "${PIPESTATUS[0]}" -eq 0 ] || warning "flatpak update encountered an error."
        info "Removing unused Flatpak runtimes"
        flatpak uninstall --unused -y --noninteractive >/dev/null 2>&1 || true
        info "Repairing Flatpak installation"
        flatpak repair 2>/dev/null || true
    fi

    info "Trimming systemd journal to 200 MB"
    sudo journalctl --vacuum-size=200M 2>/dev/null || true
    info "Clearing thumbnail cache"
    rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
    info "Reloading systemd daemon"
    sudo systemctl daemon-reload 2>/dev/null || true

    info "System cleanup complete."
}

WANT_REBOOT=false

ask_reboot() {
    if ask_yes_no no "Reboot when the installation ends?"; then
        WANT_REBOOT=true
    fi
}

reboot_if_chosen() {
    echo ""
    if [ "$WANT_REBOOT" = true ]; then
        info "Rebooting"
        sudo reboot
    else
        info "Reboot for every change to take effect."
        echo ""
    fi
}
