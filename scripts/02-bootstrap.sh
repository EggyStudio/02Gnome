#!/usr/bin/env bash
# 02Gnome's bootstrap of gum, Flatpak and the system update. install.sh installs
# git and clones the repository itself, before this file can be sourced.
# install.sh sources this file, which is not run on its own.

install_gum() {
    if command -v gum &>/dev/null; then
        return
    fi

    info "Installing gum"

    if command -v apt-get &>/dev/null; then
        local CHARM_KEY_FINGERPRINT="F3B551E9AB7AD7FE"
        local tmp_key
        tmp_key=$(mktemp)
        curl -fsSL https://repo.charm.sh/apt/gpg.key -o "$tmp_key"
        if ! gpg --no-default-keyring --keyring "gnupg-ring:${tmp_key}" \
                --fingerprint 2>/dev/null | grep -qi "$CHARM_KEY_FINGERPRINT"; then
            warning "The GPG key's fingerprint does not match, so gum is installed from the key fetched over HTTPS alone."
        fi
        sudo mkdir -p /etc/apt/keyrings
        gpg --dearmor "$tmp_key" | sudo tee /etc/apt/keyrings/charm.gpg > /dev/null
        rm -f "$tmp_key"
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
            | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
        sudo apt-get update -y && sudo apt-get install -y gum

    elif [ "$IS_ATOMIC" = true ]; then
        local gum_ver="2.0.2"
        local gum_url="https://github.com/charmbracelet/gum/releases/download/v${gum_ver}/gum_${gum_ver}_Linux_x86_64.tar.gz"
        local tmp_gum
        tmp_gum=$(mktemp -d)
        local gum_bin=""
        if curl -fsSL "$gum_url" -o "$tmp_gum/gum.tar.gz" \
                && tar -xzf "$tmp_gum/gum.tar.gz" -C "$tmp_gum"; then
            gum_bin=$(find "$tmp_gum" -type f -name gum -print -quit)
        fi
        if [ -n "$gum_bin" ]; then
            mkdir -p "$HOME/.local/bin"
            install -m 755 "$gum_bin" "$HOME/.local/bin/gum"
            export PATH="$HOME/.local/bin:$PATH"
            info "gum is installed in ~/.local/bin."
        else
            warning "Could not download gum, so the questions are asked in plain text."
            GUM_AVAILABLE=false
        fi
        rm -rf "$tmp_gum"
        return

    elif command -v dnf &>/dev/null; then
        echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo > /dev/null
        sudo dnf install -y gum

    elif command -v pacman &>/dev/null; then
        if sudo pacman -S --noconfirm gum 2>/dev/null; then
            : # installed from official repos
        elif command -v yay &>/dev/null; then
            yay -S --noconfirm gum
        elif command -v paru &>/dev/null; then
            paru -S --noconfirm gum
        else
            warning "Could not install gum, so the questions are asked in plain text."
            GUM_AVAILABLE=false
            return
        fi

    else
        warning "Could not install gum, so the questions are asked in plain text."
        GUM_AVAILABLE=false
        return
    fi
}

install_flatpak() {
    if ! command -v flatpak &>/dev/null; then
        info "Installing flatpak"
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y flatpak
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y flatpak
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm flatpak
        else
            error "Unsupported package manager. Please install flatpak manually."
            exit 1
        fi
    else
        info "flatpak is already installed."
    fi

    info "Adding Flathub remote (if not already present)"
    flatpak remote-add --if-not-exists --user flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo || true
}

system_update() {
    info "Updating system packages"
    if [ "$IS_ATOMIC" = true ]; then
        info "Upgrading base image via rpm-ostree"
        sudo rpm-ostree upgrade || warning "rpm-ostree upgrade ended with an error."
    elif command -v dnf &>/dev/null; then
        sudo dnf update -y || warning "dnf update encountered an error."
    elif command -v apt-get &>/dev/null; then
        { sudo apt-get update -y && sudo apt-get upgrade -y; } || warning "apt upgrade encountered an error."
    elif command -v pacman &>/dev/null; then
        sudo pacman -Syu --noconfirm || warning "pacman update encountered an error."
    fi

    if command -v flatpak &>/dev/null; then
        info "Updating Flatpak applications"
        LANG=C flatpak update -y --noninteractive 2>&1 | cat
        [ "${PIPESTATUS[0]}" -eq 0 ] || warning "flatpak update encountered an error."
    fi
}

install_gnome_menus() {
    if [ "$IS_ATOMIC" = true ]; then
        return
    elif command -v dnf &>/dev/null; then
        if ! rpm -q gnome-menus &>/dev/null; then
            info "Installing gnome-menus"
            sudo dnf install -y gnome-menus || warning "Could not install gnome-menus."
        fi
    elif command -v pacman &>/dev/null; then
        if ! pacman -Qi gnome-menus &>/dev/null; then
            info "Installing gnome-menus"
            sudo pacman -S --noconfirm gnome-menus || warning "Could not install gnome-menus."
        fi
    fi
}

install_fastfetch() {
    if command -v fastfetch &>/dev/null; then
        info "fastfetch is already installed."
        return
    fi

    info "Installing fastfetch"
    if [ "$IS_ATOMIC" = true ]; then
        pkg_install fastfetch
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y fastfetch || warning "Could not install fastfetch."
    elif command -v apt-get &>/dev/null; then
        sudo apt-get install -y fastfetch || warning "Could not install fastfetch."
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm fastfetch || warning "Could not install fastfetch."
    else
        warning "Unsupported package manager, so fastfetch install is skipped."
    fi
}

