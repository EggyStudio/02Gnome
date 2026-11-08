#!/usr/bin/env bash
# 02Gnome's application installers, the essential Flatpaks, the optional applications, .NET and OpenCode.
# install.sh sources this file, which is not run on its own.

install_essential_flatpaks() {
    info "Installing essential Flatpak applications"
    for app in "${ESSENTIAL_APPS[@]}"; do
        install_one_flatpak "$app"
    done

    # Install Firefox if not already present
    if ! have_firefox_install; then
        info "Installing Firefox"
        if [ "$IS_ATOMIC" = true ]; then
            install_one_flatpak "org.mozilla.firefox"
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y firefox \
                || warning "Could not install Firefox via dnf."
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm firefox \
                || warning "Could not install Firefox via pacman."
        elif command -v apt-get &>/dev/null; then
            sudo apt-get install -y firefox \
                || warning "Could not install Firefox via apt."
        else
            warning "Could not determine package manager to install Firefox."
        fi
    fi

    # Install GNOME Tweaks
    info "Installing GNOME Tweaks"
    if [ "$IS_ATOMIC" = true ]; then
        rpm -q gnome-tweaks &>/dev/null 2>&1 \
            || pkg_install gnome-tweaks
    elif command -v dnf &>/dev/null; then
        rpm -q gnome-tweaks &>/dev/null 2>&1 \
            || sudo dnf install -y gnome-tweaks \
            || warning "Could not install gnome-tweaks."
    elif command -v pacman &>/dev/null; then
        pacman -Qi gnome-tweaks &>/dev/null 2>&1 \
            || sudo pacman -S --noconfirm gnome-tweaks \
            || warning "Could not install gnome-tweaks."
    elif command -v apt-get &>/dev/null; then
        dpkg -s gnome-tweaks &>/dev/null 2>&1 \
            || sudo apt-get install -y gnome-tweaks \
            || warning "Could not install gnome-tweaks."
    fi
}

install_dotnet() {
    info "Installing .NET SDK & Runtimes"
    local tmp_script
    tmp_script=$(mktemp)
    curl -fsSL https://dot.net/v1/dotnet-install.sh -o "$tmp_script" || {
        warning "Failed to download .NET install script, so it is skipped."
        rm -f "$tmp_script"; return
    }
    chmod +x "$tmp_script"

    for channel in LTS STS; do
        info "  Installing .NET $channel channel"
        bash "$tmp_script" --channel "$channel" \
            || warning "  .NET $channel install encountered an error."
    done
    rm -f "$tmp_script"

    if ! echo "$PATH" | grep -q "$HOME/.dotnet"; then
        warning "Add this to your shell profile to use dotnet:"
        warning "  export DOTNET_ROOT=\"\$HOME/.dotnet\""
        warning "  export PATH=\"\$HOME/.dotnet:\$PATH\""
    fi
}

install_claude() {
    if command -v claude &>/dev/null; then
        info "Claude is already installed."
        return
    fi

    info "Installing Claude"
    curl -fsSL https://claude.ai/install.sh | bash \
        || warning "Claude install encountered an error."

    if command -v claude &>/dev/null; then
        info "Claude installed successfully."
    else
        warning "Claude binary not found on PATH after install."
        warning "You may need to restart your shell or add ~/.local/bin to PATH."
    fi
}

install_opencode() {
    if command -v opencode &>/dev/null; then
        info "OpenCode is already installed."
        return
    fi

    info "Installing OpenCode"
    curl -fsSL https://opencode.ai/install | bash \
        || warning "OpenCode install encountered an error."

    if command -v opencode &>/dev/null; then
        info "OpenCode installed successfully."
    else
        warning "OpenCode binary not found on PATH after install."
        warning "You may need to restart your shell or add ~/.local/bin to PATH."
    fi
}

SELECTED_OPTIONAL_APPS=()

ask_optional_apps() {
    local labels=() entry
    for entry in "${OPTIONAL_APPS[@]}"; do
        labels+=("${entry%%|*}")
    done
    mapfile -t SELECTED_OPTIONAL_APPS < <(ask_choose_many "Select optional applications" none "${labels[@]}")
}

install_optional_apps() {
    if [ ${#SELECTED_OPTIONAL_APPS[@]} -eq 0 ]; then
        info "No optional applications were selected."
        return
    fi

    local selected=("${SELECTED_OPTIONAL_APPS[@]}")
    info "Installing ${#selected[@]} optional applications"

    for sel in "${selected[@]}"; do
        for entry in "${OPTIONAL_APPS[@]}"; do
            local label="${entry%%|*}"
            local target="${entry##*|}"
            if [ "$label" = "$sel" ]; then
                local install_type="${target%%:*}"
                local install_id="${target##*:}"
                case "$install_type" in
                    flatpak)
                        install_one_flatpak "$install_id"
                        if [ "$install_id" = "org.signal.Signal" ]; then
                            info "Configuring Signal to use GNOME Keyring"
                            flatpak override --user --env=SIGNAL_PASSWORD_STORE=gnome-libsecret org.signal.Signal 2>/dev/null || true
                        fi
                        ;;
                    script)
                        case "$install_id" in
                            dotnet) install_dotnet ;;
                            opencode) install_opencode ;;
                            claude) install_claude ;;
                            *) warning "Unknown install script: $install_id" ;;
                        esac
                        ;;
                    rpm)
                        install_one_rpm "$install_id"
                        ;;
                    *) warning "Unknown install type: $install_type" ;;
                esac
                break
            fi
        done
    done
}

