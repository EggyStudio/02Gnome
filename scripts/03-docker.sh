#!/usr/bin/env bash
# 02Gnome's Docker, Tailscale and Docker Compose services.
# install.sh sources this file, which is not run on its own.

install_docker() {
    if command -v docker &>/dev/null; then
        info "Docker is already installed."
        return
    fi

    info "Installing Docker"

    if [ "$IS_ATOMIC" = true ]; then
        sudo rpm-ostree uninstall -y podman-docker 2>/dev/null || true

        local docker_repo="https://download.docker.com/linux/fedora/docker-ce.repo"
        sudo curl -fsSL "$docker_repo" -o /etc/yum.repos.d/docker-ce.repo 2>/dev/null || {
            warning "Could not add Docker repo, so it is skipped."
            return
        }

        local fedora_ver
        fedora_ver=$(rpm -E %fedora 2>/dev/null) || true
        if [ -n "$fedora_ver" ] && [ -f /etc/yum.repos.d/docker-ce.repo ]; then
            sudo sed -i "s|\$releasever|${fedora_ver}|g" /etc/yum.repos.d/docker-ce.repo 2>/dev/null || true
        fi

        sudo rpm-ostree install --idempotent --allow-inactive -y \
            docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
            || { warning "Docker layering failed, so it is skipped."; return; }

        sudo systemctl enable docker 2>/dev/null || true
        sudo usermod -aG docker "$(whoami)" 2>/dev/null || true
        info "Docker layered via rpm-ostree. A reboot is required to activate."
        return

    elif command -v dnf &>/dev/null; then
        sudo dnf remove -y docker docker-client docker-client-latest \
            docker-common docker-latest docker-latest-logrotate \
            docker-logrotate docker-engine podman-docker 2>/dev/null || true

        local docker_repo="https://download.docker.com/linux/fedora/docker-ce.repo"
        sudo dnf config-manager addrepo --from-repofile="$docker_repo" \
            2>/dev/null || sudo dnf config-manager --add-repo "$docker_repo" \
            2>/dev/null || { warning "Could not add Docker repo, so it is skipped."; return; }

        if [ -f /etc/yum.repos.d/docker-ce.repo ]; then
            local fedora_ver
            fedora_ver=$(rpm -E %fedora 2>/dev/null) || true
            if [ -n "$fedora_ver" ]; then
                sudo sed -i "s|\$releasever|${fedora_ver}|g" /etc/yum.repos.d/docker-ce.repo 2>/dev/null || true
            fi
        fi

        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
            || { warning "Docker install failed, so it is skipped."; return; }

    elif command -v apt-get &>/dev/null; then
        curl -fsSL https://get.docker.com | bash \
            || { warning "Docker install failed, so it is skipped."; return; }

    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm docker docker-compose \
            || { warning "Docker install failed, so it is skipped."; return; }
    else
        warning "Unsupported package manager, so Docker install is skipped."
        return
    fi

    sudo systemctl enable --now docker 2>/dev/null || true
    sudo usermod -aG docker "$(whoami)" 2>/dev/null || true
    info "Docker installed."
    info "Log out and back in for group membership to take effect."
}

WANT_TAILSCALE=false

ask_install_tailscale() {
    if ask_yes_no no "Install Tailscale (VPN)?"; then
        WANT_TAILSCALE=true
    fi
}

# Signing in waits for the browser, so it is left to the user at the end of the
# run, and the steps between run without them.
install_tailscale() {
    [ "$WANT_TAILSCALE" = true ] || return 0

    if command -v tailscale &>/dev/null; then
        info "Tailscale is installed."
    else
        info "Installing Tailscale"
        curl -fsSL https://tailscale.com/install.sh | bash \
            || { warning "Tailscale did not install, so it is skipped."; return; }
    fi

    sudo systemctl enable --now tailscaled 2>/dev/null || true
    info "Tailscale runs. Sign in with sudo tailscale up once the installer ends."
}

SELECTED_DOCKER_SERVICES=()

ask_docker_services() {
    local labels=() entry
    for entry in "${DOCKER_SERVICES[@]}"; do
        labels+=("${entry%%|*}")
    done
    mapfile -t SELECTED_DOCKER_SERVICES < <(ask_choose_many "Select Docker Compose services" none "${labels[@]}")
}

# Docker added in this run is not usable by the user until the next login, when
# the docker group applies, or on an atomic system until the reboot.
_compose_up() {
    local dir="$1"
    if ! command -v docker &>/dev/null; then
        info "Docker is available after the reboot. Start the service then with docker compose up -d in $dir."
        return
    fi
    if docker info &>/dev/null; then
        (cd "$dir" && docker compose up -d)
    else
        (cd "$dir" && sudo docker compose up -d)
    fi
}

install_docker_services() {
    if [ ${#SELECTED_DOCKER_SERVICES[@]} -eq 0 ]; then
        info "No Docker Compose services were selected."
        return
    fi

    local selected=("${SELECTED_DOCKER_SERVICES[@]}")
    info "Setting up ${#selected[@]} Docker Compose services"

    for sel in "${selected[@]}"; do
        for entry in "${DOCKER_SERVICES[@]}"; do
            local label="${entry%%|*}"
            local dir_name="${entry##*|}"
            if [ "$sel" = "$label" ]; then
                local target_dir="$HOME/$dir_name"
                info "Setting up ${label} in ${target_dir}"

                mkdir -p "$target_dir"
                cp "$DOTFILES_DIR/docker/$dir_name/docker-compose.yml" "$target_dir/"
                cp "$DOTFILES_DIR/docker/$dir_name/README.md" "$target_dir/" 2>/dev/null || true

                if [ -f "$DOTFILES_DIR/docker/$dir_name/env" ]; then
                    if [ ! -f "$target_dir/.env" ]; then
                        cp "$DOTFILES_DIR/docker/$dir_name/env" "$target_dir/.env"
                        # Immich accepts only A-Za-z0-9 in DB_PASSWORD, so the password is hex.
                        if grep -q 'please-change-me' "$target_dir/.env" 2>/dev/null; then
                            local random_pw
                            random_pw=$(openssl rand -hex 20)
                            sed -i "s|please-change-me|${random_pw}|g" "$target_dir/.env"
                        fi
                    fi
                fi

                if ! lspci | grep -qi 'nvidia'; then
                    sed -i '/deploy:/,/capabilities: \[gpu\]/d' "$target_dir/docker-compose.yml" 2>/dev/null || true
                fi

                info "Starting ${label}"
                _compose_up "$target_dir" \
                    || warning "${label} did not start. Start it with docker compose up -d in ${target_dir}."

                info "${label} is set up, and ${target_dir}/README.md describes its use."
                INSTALLED_DOCKER_SERVICES+=("$dir_name")
                break
            fi
        done
    done
}

create_docker_web_apps() {
    local created=false

    if command -v tailscale &>/dev/null; then
        _create_web_app_desktop "Tailscale" "https://tailscale.com/" "tailscale"
        created=true
    fi

    for svc in "${INSTALLED_DOCKER_SERVICES[@]+"${INSTALLED_DOCKER_SERVICES[@]}"}"; do
        case "$svc" in
            immich)
                _create_web_app_desktop "Immich" "http://localhost:2283" "immich"
                created=true
                ;;
            nextcloud)
                local nc_port=8080
                if [ -f "$HOME/nextcloud/.env" ]; then
                    nc_port=$(grep -E '^NC_PORT=' "$HOME/nextcloud/.env" | cut -d= -f2)
                    nc_port=${nc_port:-8080}
                fi
                _create_web_app_desktop "Nextcloud" "http://localhost:${nc_port}" "nextcloud"
                created=true
                ;;
            ollama)
                _create_web_app_desktop "Open WebUI" "http://localhost:3000" "open-webui"
                created=true
                ;;
            zerotierone)
                _create_web_app_desktop "ZeroTier" "https://central.zerotier.com" "zerotier"
                created=true
                ;;
        esac
    done

    if [ "$created" = true ]; then
        info "Web app shortcuts created."
        info "You can also manage them in Web App Hub."
    fi
}

_create_web_app_desktop() {
    local name="$1" url="$2" icon_name="$3"
    local app_id
    app_id=$(echo "$name" | tr '[:upper:]' '[:lower:]-')

    local icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
    mkdir -p "$icon_dir"

    local src_icon=""
    case "$icon_name" in
        immich)    src_icon="$DOTFILES_DIR/assets/icons/immich.png" ;;
        nextcloud) src_icon="$DOTFILES_DIR/assets/icons/nextcloud.png" ;;
        open-webui) src_icon="$DOTFILES_DIR/assets/icons/open-webui-light.png" ;;
        zerotier)  src_icon="$DOTFILES_DIR/assets/icons/zerotier.png" ;;
        tailscale) src_icon="$DOTFILES_DIR/assets/icons/tailscale-light.png" ;;
    esac

    if [ -n "$src_icon" ] && [ -f "$src_icon" ]; then
        cp -f "$src_icon" "$icon_dir/${icon_name}.png"
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
    fi

    local desktop_file="$HOME/.local/share/applications/webapp-${app_id}.desktop"
    mkdir -p "$HOME/.local/share/applications"

    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=${name}
Exec=xdg-open ${url}
Icon=${icon_name}
Categories=Network;WebBrowser;
StartupNotify=true
EOF

    info "Created web app shortcut: ${name} → ${url}"
}

