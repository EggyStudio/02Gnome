#!/usr/bin/env bash
# 02Gnome's GNOME configuration, dconf, the profile, the preferences, Nautilus and the rest.
# install.sh sources this file, which is not run on its own.

import_gnome_settings() {
    local profile="$1"
    local dconf_dir="$DOTFILES_DIR/gnome/${profile}"

    if [ ! -d "$dconf_dir" ]; then
        warning "No dconf directory found at $dconf_dir, so GNOME settings import is skipped."
        return
    fi

    if ! command -v dconf &>/dev/null; then
        warning "dconf not found, so GNOME settings import is skipped."
        return
    fi

    info "Importing GNOME settings for profile '${profile}'"

    local count=0
    for dconf_file in "$dconf_dir"/*.dconf; do
        [ -f "$dconf_file" ] || continue
        local fname
        fname=$(basename "$dconf_file")
        info "  Loading ${fname}"
        sed "s|DOTFILES_DIR|${DOTFILES_DIR}|g" "$dconf_file" | dconf load / || \
            warning "Failed to load ${fname}, so it is skipped."
        count=$((count + 1))
    done

    if [ "$count" -eq 0 ]; then
        warning "No .dconf files found in $dconf_dir."
    else
        info "GNOME settings imported successfully ($count file(s) loaded)."
    fi
}

ask_profile() {
    local choice
    choice=$(ask_choose_one "Select a profile:" "Desktop" "Laptop")
    PROFILE="${choice,,}"
    if [ -z "$PROFILE" ]; then
        PROFILE="desktop"
        warning "No profile was selected, so the desktop profile is used."
    fi
    info "Profile ${BOLD}${PROFILE}${NC}"
}

run_profile() {
    local profile="$1"
    local script="$DOTFILES_DIR/gnome/${profile}/setup.sh"

    if [ ! -f "$script" ]; then
        warning "No setup script found at $script, so profile setup is skipped."
        return
    fi

    info "Running ${profile} profile setup"
    chmod +x "$script"
    bash "$script"
}

USER_PREF_LABELS=(
    "Show the clock in 24-hour format"
    "Hide the weekday in the clock"
    "Log in automatically without a password"
    "Keep the screen on and undimmed when idle"
    "Turn off the automatic screen lock"
    "Start with Bluetooth off"
    "Set the regional formats from the time zone"
)
USER_PREFS=()

ask_user_preferences() {
    mapfile -t USER_PREFS < <(ask_choose_many "Select preferences" all "${USER_PREF_LABELS[@]}")
}

apply_user_preferences() {
    info "Applying the user preferences"

    local pref
    for pref in "${USER_PREFS[@]+"${USER_PREFS[@]}"}"; do
        case "$pref" in
            "Show the clock in 24-hour format")
                info "Showing the clock in 24-hour format"
                gsettings set org.gnome.desktop.interface clock-format '24h' 2>/dev/null || true
                ;;
            "Hide the weekday in the clock")
                info "Hiding the weekday in the clock"
                gsettings set org.gnome.desktop.interface clock-show-weekday false 2>/dev/null || true
                ;;
            "Log in automatically without a password")
                info "Turning on automatic login"
                local current_user
                current_user=$(whoami)
                local gdm_conf=""
                for f in /etc/gdm/custom.conf /etc/gdm3/custom.conf; do
                    if [ -f "$f" ]; then gdm_conf="$f"; break; fi
                done
                if [ -z "$gdm_conf" ]; then
                    sudo mkdir -p /etc/gdm 2>/dev/null || true
                    gdm_conf="/etc/gdm/custom.conf"
                fi
                if [ -f "$gdm_conf" ]; then
                    sudo sed -i '/^\[daemon\]/,/^\[/ { /^AutomaticLoginEnable/d; /^AutomaticLogin=/d; }' "$gdm_conf"
                    sudo sed -i "/^\[daemon\]/a AutomaticLoginEnable=True\nAutomaticLogin=${current_user}" "$gdm_conf"
                else
                    echo -e "[daemon]\nAutomaticLoginEnable=True\nAutomaticLogin=${current_user}" \
                        | sudo tee "$gdm_conf" > /dev/null
                fi
                info "Automatic login enabled for user '${current_user}'."
                ;;
            "Keep the screen on and undimmed when idle")
                info "Keeping the screen on and undimmed when idle"
                gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true
                gsettings set org.gnome.settings-daemon.plugins.power idle-dim false 2>/dev/null || true
                ;;
            "Turn off the automatic screen lock")
                info "Turning off the automatic screen lock"
                gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true
                ;;
            "Start with Bluetooth off")
                info "Turning off Bluetooth at startup"
                sudo systemctl disable bluetooth 2>/dev/null || true
                sudo rfkill block bluetooth 2>/dev/null || true
                ;;
            "Set the regional formats from the time zone")
                info "Setting the regional formats from the time zone"
                local tz=""
                tz=$(timedatectl show --property=Timezone --value 2>/dev/null) || true
                if [ -z "$tz" ]; then
                    tz=$(cat /etc/timezone 2>/dev/null) || true
                fi
                if [ -z "$tz" ]; then
                    warning "Could not detect timezone, so regional format is skipped."
                else
                    local cc=""
                    cc=$(awk -v tz="$tz" '$3 == tz { print $1; exit }' /usr/share/zoneinfo/zone.tab 2>/dev/null) || true
                    if [ -z "$cc" ]; then
                        warning "Could not determine country for timezone $tz, so it is skipped."
                    else
                        local region_locale=""
                        region_locale=$(locale -a 2>/dev/null \
                            | grep -i "_${cc}\." \
                            | grep -i 'utf' \
                            | head -1) || true
                        if [ -n "$region_locale" ]; then
                            region_locale=$(echo "$region_locale" | sed 's/utf8/UTF-8/; s/\.utf-8/.UTF-8/i')
                            dconf write /system/locale/region "'$region_locale'" 2>/dev/null || true
                            info "Regional format set to $region_locale."
                            info "Timezone: $tz, country: $cc."
                        else
                            warning "No UTF-8 locale found for country $cc, so it is skipped."
                        fi
                    fi
                fi
                ;;
        esac
    done

    if [ ${#USER_PREFS[@]} -eq 0 ]; then
        info "No preferences were selected, so GNOME's defaults stand."
    fi
}

configure_nautilus() {
    info "Configuring Nautilus (Files)"

    gsettings set org.gnome.nautilus.preferences sort-directories-first true 2>/dev/null || true
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view' 2>/dev/null || true
    gsettings set org.gnome.nautilus.preferences show-create-link true 2>/dev/null || true
    gsettings set org.gnome.nautilus.preferences show-delete-permanently true 2>/dev/null || true
    gsettings set org.gnome.nautilus.list-view use-tree-view true 2>/dev/null || true
    gsettings set org.gnome.nautilus.list-view default-zoom-level 'small' 2>/dev/null || true
    gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true 2>/dev/null || true

    local current_user
    current_user=$(whoami)
    local starred_folders=(
        "/home/${current_user}/.var/app"
        "/home/${current_user}/.local/share/gnome-shell/extensions"
    )

    for folder in "${starred_folders[@]}"; do
        if [ -d "$folder" ]; then
            gio set -t stringv "$folder" metadata::xdg-tags "starred" 2>/dev/null \
                || warning "Could not star $folder"
            info "Starred: $folder"
        else
            mkdir -p "$folder" 2>/dev/null || true
            gio set -t stringv "$folder" metadata::xdg-tags "starred" 2>/dev/null \
                || warning "Could not star $folder"
            info "Created & starred: $folder"
        fi
    done

    local steam_folder="/home/${current_user}/.steam/steam/steamapps/common"
    if flatpak list --app --columns=application 2>/dev/null | grep -qx "com.valvesoftware.Steam" \
       || rpm -q steam &>/dev/null \
       || [ -d "$steam_folder" ]; then
        if [ -d "$steam_folder" ]; then
            gio set -t stringv "$steam_folder" metadata::xdg-tags "starred" 2>/dev/null \
                || warning "Could not star $steam_folder"
            info "Starred: $steam_folder"
        else
            info "Steam installed but library folder not yet created."
            info "star it after first launch."
        fi
    fi

    info "Nautilus configuration complete."
}

setup_templates() {
    local tpl_dir
    tpl_dir=$(xdg-user-dir TEMPLATES 2>/dev/null || echo "$HOME/Templates")
    info "Setting up Templates directory at ${tpl_dir}"

    mkdir -p "$tpl_dir"

    [ -f "$tpl_dir/untitled-document.txt" ] \
        || touch "$tpl_dir/untitled-document.txt"

    [ -f "$tpl_dir/untitled-document.md" ] \
        || touch "$tpl_dir/untitled-document.md"

    if [ ! -f "$tpl_dir/untitled-script.sh" ]; then
        echo '#!/usr/bin/env bash' > "$tpl_dir/untitled-script.sh"
        chmod +x "$tpl_dir/untitled-script.sh"
    fi

    if [ ! -f "$tpl_dir/untitled-script.py" ]; then
        echo '#!/usr/bin/env python3' > "$tpl_dir/untitled-script.py"
    fi

    [ -f "$tpl_dir/untitled-class.cs" ] \
        || touch "$tpl_dir/untitled-class.cs"

    if [ ! -f "$tpl_dir/untitled-document.html" ]; then
        cat > "$tpl_dir/untitled-document.html" << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Untitled</title>
</head>
<body>

</body>
</html>
HTML
    fi

    info "The templates folder holds $(find "$tpl_dir" -mindepth 1 -maxdepth 1 | wc -l) templates."
}

configure_app_defaults() {
    info "Configuring app defaults"
    gsettings set org.gnome.Ptyxis restore-session false 2>/dev/null || true
    gsettings set org.gnome.Ptyxis restore-window-size false 2>/dev/null || true
    gsettings set org.gnome.TextEditor restore-session false 2>/dev/null || true
    info "App defaults configured."
}

reset_app_grid() {
    info "Resetting app grid to flat alphabetical layout"
    gsettings reset org.gnome.shell app-picker-layout 2>/dev/null || true
    dconf reset /org/gnome/shell/app-picker-layout 2>/dev/null || true
    gsettings set org.gnome.desktop.app-folders folder-children '@as []' 2>/dev/null || true
    dconf reset -f /org/gnome/desktop/app-folders/folders/ 2>/dev/null || true
    dconf write /org/gnome/desktop/app-folders/folder-children '@as []' 2>/dev/null || true
    info "The app grid is reset, and every app appears in one alphabetical view."
}

_resolve_desktop_file() {
    local flatpak_id="$1"
    local rpm_names="$2"

    if flatpak list --app --columns=application 2>/dev/null | grep -qx "$flatpak_id"; then
        echo "${flatpak_id}.desktop"
        return
    fi

    IFS=',' read -ra names <<< "$rpm_names"
    for name in "${names[@]}"; do
        for dir in /usr/share/applications /usr/local/share/applications "$HOME/.local/share/applications"; do
            if [ -f "$dir/${name}.desktop" ]; then
                echo "${name}.desktop"
                return
            fi
        done
    done
}

pin_optional_apps_to_favorites() {
    local current_favs
    current_favs=$(gsettings get org.gnome.shell favorite-apps 2>/dev/null) || return 0

    local -a tail_apps=(
        "org.gnome.Nautilus.desktop"
        "org.gnome.Ptyxis.desktop"
        "org.gnome.Software.desktop"
    )

    for tail in "${tail_apps[@]}"; do
        current_favs=$(echo "$current_favs" | sed "s/, *'${tail}'//g; s/'${tail}', *//g; s/'${tail}'//g")
    done

    local changed=false

    for entry in "${OPTIONAL_PIN_ORDER[@]}"; do
        local flatpak_id="${entry%%|*}"
        local rpm_names="${entry#*|}"
        local desktop
        desktop=$(_resolve_desktop_file "$flatpak_id" "$rpm_names")

        if [ -n "$desktop" ]; then
            if ! echo "$current_favs" | grep -q "'${desktop}'"; then
                current_favs="${current_favs%]*}, '${desktop}']"
                changed=true
                info "Pinned $desktop to favorites."
            fi
        fi
    done

    for tail in "${tail_apps[@]}"; do
        current_favs="${current_favs%]*}, '${tail}']"
    done
    changed=true

    if [ "$changed" = true ]; then
        gsettings set org.gnome.shell favorite-apps "$current_favs" 2>/dev/null || true
    fi
}

register_opencode_shortcut() {
    if ! command -v opencode &>/dev/null; then
        return
    fi

    info "Registering Super+C shortcut for OpenCode"

    local current
    current=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null) || return 0

    local path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"

    if echo "$current" | grep -q "custom2"; then
        info "The custom keybinding slot custom2 is in use, so the OpenCode shortcut is skipped."
        return
    fi

    current="${current%]*}, '${path}']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$current" 2>/dev/null || true

    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/name "'OpenCode'" 2>/dev/null || true
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/command "'ptyxis -e opencode'" 2>/dev/null || true
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/binding "'<Super>c'" 2>/dev/null || true

    info "OpenCode shortcut registered: Super+C"
}

