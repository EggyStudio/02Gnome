#!/usr/bin/env bash
# 02Gnome's themes, Adwaita, Rewaita, Oled, Add Water and Firefox.
# install.sh sources this file, which is not run on its own.

setup_themes() {
    info "Setting up Adwaita themes"

    if [ "$IS_ATOMIC" = true ]; then
        if ! rpm -q adw-gtk3-theme &>/dev/null 2>&1; then
            info "Installing adw-gtk3-theme"
            pkg_install adw-gtk3-theme
        else
            info "adw-gtk3-theme is already installed."
        fi
    elif command -v dnf &>/dev/null; then
        if ! rpm -q adw-gtk3-theme &>/dev/null 2>&1; then
            info "Installing adw-gtk3-theme"
            sudo dnf install -y adw-gtk3-theme || warning "Could not install adw-gtk3-theme."
        else
            info "adw-gtk3-theme is already installed."
        fi
    elif command -v pacman &>/dev/null; then
        if ! pacman -Qi adw-gtk3 &>/dev/null 2>&1; then
            info "Installing adw-gtk3"
            if sudo pacman -S --noconfirm adw-gtk3; then
                true
            elif command -v yay &>/dev/null; then
                yay -S --noconfirm adw-gtk3 \
                    || warning "Could not install adw-gtk3 through yay, so install it from the AUR."
            elif command -v paru &>/dev/null; then
                paru -S --noconfirm adw-gtk3 \
                    || warning "Could not install adw-gtk3 through paru, so install it from the AUR."
            else
                warning "Could not install adw-gtk3, so install it from the AUR."
            fi
        else
            info "adw-gtk3 is already installed."
        fi
    fi

    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

    flatpak override --user --filesystem=xdg-config/gtk-4.0 2>/dev/null || true
    flatpak override --user --filesystem=xdg-config/gtk-3.0 2>/dev/null || true

    info "Themes applied."
    info "Open Rewaita to browse and apply Adwaita theme variants."
}

REWAITA_APP_ID="io.github.swordpuffin.rewaita"
REWAITA_DATA_DIR="$HOME/.var/app/$REWAITA_APP_ID/data"
REWAITA_DARK_THEME="A Default Dark Theme.css"
REWAITA_OLED_THEME="A Pure Dark Theme.css"
REWAITA_LIGHT_THEME="A Default Light Theme.css"

install_rewaita_themes() {
    info "Installing the Rewaita themes"

    local dark_dir="$REWAITA_DATA_DIR/dark"
    local light_dir="$REWAITA_DATA_DIR/light"
    mkdir -p "$dark_dir" "$light_dir"

    local theme
    for theme in "$REWAITA_DARK_THEME" "$REWAITA_OLED_THEME"; do
        cp -f "$DOTFILES_DIR/assets/themes/dark/$theme" "$dark_dir/" \
            || warning "Could not copy the Rewaita theme $theme."
    done
    cp -f "$DOTFILES_DIR/assets/themes/light/$REWAITA_LIGHT_THEME" "$light_dir/" \
        || warning "Could not copy the Rewaita theme $REWAITA_LIGHT_THEME."

    apply_rewaita_themes
}

# Rewaita's --theme option takes the file name lowercased, without its emoji and
# extension, with hyphens for spaces. The themes here carry no emoji.
_rewaita_cli_name() {
    local name="${1%.css}"
    name="${name// /-}"
    printf '%s' "${name,,}"
}

# Rewaita 1.1.8 reads every key of its defaults at start. When an existing
# prefs.json lacks one, it retries the read until Python's recursion limit ends
# the start, so every key is written. Keys the user has set are kept.
_write_rewaita_prefs() {
    python3 - "$REWAITA_DATA_DIR/prefs.json" "$1" "$2" <<'EOF'
import json, os, sys

path, dark, light = sys.argv[1:4]
defaults = {
    "light-theme": "default",
    "dark-theme": "default",
    "window-controls": "default",
    "modify-gtk3-theme": True,
    "modify-gnome-shell": True,
    "modify-cinnamon-shell": True,
    "run-in-background": True,
    "transparency": False,
    "window": False,
    "sharp": False,
    "firefox-theme": False,
    "accent-fg": 0,
    "accent-tabs": False,
    "light-text": False,
    "dark-panel": False,
    "trans-panel": False,
    "no-pills": False,
    "accent": "'blue'",
}
try:
    with open(path) as f:
        prefs = json.load(f)
    if not isinstance(prefs, dict):
        prefs = {}
except (OSError, ValueError):
    prefs = {}

for key, value in defaults.items():
    prefs.setdefault(key, value)
prefs["dark-theme"] = dark
prefs["light-theme"] = light

os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(prefs, f, indent=4)
EOF
}

# Records the dark and light themes, then applies the one for the current color
# scheme through Rewaita's own command line, which writes the GTK and GNOME Shell
# styles at once. The other theme is applied by Rewaita when the scheme changes.
apply_rewaita_themes() {
    local dark_theme="$REWAITA_DARK_THEME"
    [ "$USE_OLED" = true ] && dark_theme="$REWAITA_OLED_THEME"

    if ! _write_rewaita_prefs "$dark_theme" "$REWAITA_LIGHT_THEME"; then
        warning "Could not write Rewaita's prefs.json."
        return
    fi
    info "Rewaita uses ${dark_theme%.css} in dark mode and ${REWAITA_LIGHT_THEME%.css} in light mode."

    if ! have_flatpak_app "$REWAITA_APP_ID"; then
        warning "Rewaita is not installed, so the theme applies once it is installed and opened."
        return
    fi

    local current_theme="$REWAITA_LIGHT_THEME"
    if [ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" = "'prefer-dark'" ]; then
        current_theme="$dark_theme"
    fi

    # A running instance receives the command line of a second one without the
    # option's value, so it is stopped first. It starts again at the next login.
    flatpak kill "$REWAITA_APP_ID" &>/dev/null || true

    # Rewaita opens its window to apply the theme and exits, so the timeout stops
    # only a run that does not.
    local output
    output=$(timeout 60 flatpak run "$REWAITA_APP_ID" --theme="$(_rewaita_cli_name "$current_theme")" 2>&1) || true
    flatpak kill "$REWAITA_APP_ID" &>/dev/null || true
    if [[ "$output" == *"was not found"* ]]; then
        warning "Rewaita did not find ${current_theme%.css}, so choose it in Rewaita."
    else
        info "Rewaita applied ${current_theme%.css}."
    fi
}

ask_oled_preference() {
    if ask_yes_no no "Use the pure black Oled dark theme?"; then
        USE_OLED=true
    fi
}

# Prints the default Ptyxis profile's uuid, or the first profile's, or nothing.
_ptyxis_profile_uuid() {
    local uuid=""
    uuid=$(dconf read /org/gnome/Ptyxis/default-profile-uuid 2>/dev/null | tr -d "'" || true)
    if [ -z "$uuid" ]; then
        local raw_uuids=""
        raw_uuids=$(dconf read /org/gnome/Ptyxis/profile-uuids 2>/dev/null || true)
        if [ -n "$raw_uuids" ]; then
            uuid=$(echo "$raw_uuids" \
                | python3 -c "import sys,ast; l=ast.literal_eval(sys.stdin.read()); print(l[0] if l else '')" 2>/dev/null || true)
        fi
    fi
    printf '%s' "$uuid"
}

# Rewaita's dark theme follows USE_OLED in install_rewaita_themes. This step sets
# the applications Rewaita does not color.
apply_oled_preference() {
    local profile_uuid
    profile_uuid=$(_ptyxis_profile_uuid)

    if [ "$USE_OLED" = false ]; then
        info "The standard dark theme is used."
        gsettings set org.gnome.TextEditor style-scheme 'Adwaita-dark' 2>/dev/null || true
        if [ -n "$profile_uuid" ]; then
            dconf write "/org/gnome/Ptyxis/Profiles/$profile_uuid/palette" "'gnome'" 2>/dev/null || true
        fi
        return
    fi

    info "Applying the Oled settings"

    if command -v flatpak &>/dev/null; then
        _init_addwater
        if flatpak run --command=gsettings dev.qwery.AddWater set dev.qwery.AddWater.Firefox oled-black true 2>/dev/null; then
            info "Add Water uses true black for Firefox."
        else
            warning "Add Water's true black was not set, since Add Water has not run once."
        fi
    else
        warning "Flatpak is not available, so Add Water's true black is skipped."
    fi

    gsettings set org.gnome.TextEditor style-scheme 'classic-dark' 2>/dev/null || true
    info "Text Editor uses Classic Dark."

    # A system without a Ptyxis profile gets one, so the palette has a place.
    if [ -z "$profile_uuid" ]; then
        profile_uuid="d4e5f6a7-b8c9-0d1e-2f3a-4b5c6d7e8f90"
        dconf write /org/gnome/Ptyxis/default-profile-uuid "'$profile_uuid'" 2>/dev/null || true
        dconf write /org/gnome/Ptyxis/profile-uuids "['$profile_uuid']" 2>/dev/null || true
    fi
    dconf write "/org/gnome/Ptyxis/Profiles/$profile_uuid/palette" "'Dark Pastel'" 2>/dev/null || true
    info "The terminal uses the Dark Pastel palette."

    gsettings set org.gnome.Ptyxis interface-style 'dark' 2>/dev/null || true
}

_init_addwater() {
    have_flatpak_app dev.qwery.AddWater || return 1

    if flatpak run --command=gsettings dev.qwery.AddWater \
            get dev.qwery.AddWater.Firefox theme-enabled &>/dev/null; then
        return 0
    fi

    info "Starting Add Water once to create its settings"
    flatpak run dev.qwery.AddWater &>/dev/null &
    local pid=$!
    local waited=0
    while [ "$waited" -lt 15 ]; do
        sleep 1
        if flatpak run --command=gsettings dev.qwery.AddWater \
                get dev.qwery.AddWater.Firefox theme-enabled &>/dev/null; then
            break
        fi
        waited=$((waited + 1))
    done
    kill "$pid" 2>/dev/null || true
    sleep 1
}

configure_addwater() {
    info "Configuring Add Water for Firefox"

    if command -v flatpak &>/dev/null; then
        _init_addwater
        flatpak run --command=gsettings dev.qwery.AddWater set dev.qwery.AddWater.Firefox theme-enabled true 2>/dev/null || true
        flatpak run --command=gsettings dev.qwery.AddWater set dev.qwery.AddWater.Firefox hide-single-tab true 2>/dev/null || true
        flatpak run --command=gsettings dev.qwery.AddWater set dev.qwery.AddWater.Firefox normal-width-tabs true 2>/dev/null || true
        flatpak run --command=gsettings dev.qwery.AddWater set dev.qwery.AddWater.background-update true 2>/dev/null || true
        info "Add Water preferences set."
        info "Open Add Water once to apply the theme to Firefox."
    else
        warning "flatpak not available, so Add Water configuration is skipped."
    fi
}

_resolve_firefox_repo_file() {
    local rel_path="$1"
    local candidate

    for candidate in \
        "$DOTFILES_DIR/firefox/$rel_path" \
        "$DOTFILES_DIR/firefox-profile/$rel_path"
    do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

_has_firefox_profiles() {
    local root
    for root in "$@"; do
        [ -f "$root/profiles.ini" ] && return 0
        [ -d "$root" ] || continue
        if find "$root" -maxdepth 2 -name 'prefs.js' -type f -print -quit 2>/dev/null | grep -q .; then
            return 0
        fi
    done

    return 1
}

_stop_firefox_processes() {
    pkill -x firefox 2>/dev/null || true
    pkill -x firefox-esr 2>/dev/null || true
    pkill -f '/app/lib/firefox/firefox' 2>/dev/null || true
    pkill -f 'org.mozilla.firefox' 2>/dev/null || true
    pkill -f 'snap/firefox' 2>/dev/null || true
}

_start_firefox_headless_for_profile_init() {
    if command -v firefox &>/dev/null; then
        firefox --headless &>/dev/null &
        return 0
    fi

    if command -v firefox-esr &>/dev/null; then
        firefox-esr --headless &>/dev/null &
        return 0
    fi

    if have_flatpak_app org.mozilla.firefox; then
        (flatpak run --command=firefox org.mozilla.firefox --headless \
            || flatpak run org.mozilla.firefox --headless) &>/dev/null &
        return 0
    fi

    if have_snap_app firefox; then
        snap run firefox --headless &>/dev/null &
        return 0
    fi

    return 1
}

configure_firefox() {
    info "Configuring Firefox preferences"

    local src_user_js
    src_user_js=$(_resolve_firefox_repo_file "user.js") || true
    if [ ! -f "$src_user_js" ]; then
        warning "No user.js found in repo, so Firefox configuration is skipped."
        return
    fi

    local profile_dirs=()
    local search_roots=(
        "$HOME/.mozilla/firefox"
        "$HOME/.config/mozilla/firefox"
        "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
        "$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox"
        "$HOME/snap/firefox/common/.mozilla/firefox"
    )

    local needs_init=true
    if _has_firefox_profiles "${search_roots[@]}"; then
        needs_init=false
    fi

    if [ "$needs_init" = true ]; then
        info "Launching Firefox briefly to create profile directories"
        _stop_firefox_processes
        sleep 1

        if _start_firefox_headless_for_profile_init; then
            local waited=0
            while [ "$waited" -lt 15 ]; do
                sleep 1
                if _has_firefox_profiles "${search_roots[@]}"; then
                    break
                fi
                waited=$((waited + 1))
            done
        else
            warning "Firefox executable not found on PATH and no Flatpak/Snap Firefox install was detected."
        fi

        _stop_firefox_processes
        sleep 1

        if _has_firefox_profiles "${search_roots[@]}"; then
            info "Firefox profile directories created."
        else
            warning "Firefox profile directories were not detected after launch attempt."
            warning "Launch Firefox once manually, close it, then re-run the installer to configure it."
        fi
    else
        if pgrep -x firefox &>/dev/null || pgrep -x firefox-esr &>/dev/null; then
            info "Closing Firefox to apply the toolbar and preference changes"
            _stop_firefox_processes
            local waited=0
            while { pgrep -x firefox || pgrep -x firefox-esr; } &>/dev/null && [ "$waited" -lt 10 ]; do
                sleep 1
                waited=$((waited + 1))
            done
        fi
    fi

    for root in "${search_roots[@]}"; do
        [ -d "$root" ] || continue

        if [ -f "$root/profiles.ini" ]; then
            while IFS= read -r line || [ -n "$line" ]; do
                line="${line%%$'\r'}"
                line="${line#"${line%%[![:space:]]*}"}"
                case "$line" in
                    Path=*)
                        local value="${line#Path=}"
                        local pdir
                        if [[ "$value" = /* ]]; then
                            pdir="$value"
                        else
                            pdir="$root/$value"
                        fi
                        if [ -d "$pdir" ]; then
                            profile_dirs+=("$pdir")
                        fi
                        ;;
                esac
            done < "$root/profiles.ini"
        fi

        local found_prefs
        found_prefs=$(find "$root" -maxdepth 2 -name 'prefs.js' -type f 2>/dev/null) || true
        if [ -n "$found_prefs" ]; then
            while IFS= read -r pjs; do
                [ -n "$pjs" ] && profile_dirs+=("$(dirname "$pjs")")
            done <<< "$found_prefs"
        fi
    done

    if [ ${#profile_dirs[@]} -gt 0 ]; then
        local unique=()
        for d in "${profile_dirs[@]}"; do
            local dup=false
            for u in "${unique[@]+"${unique[@]}"}"; do
                [ "$d" = "$u" ] && { dup=true; break; }
            done
            $dup || unique+=("$d")
        done
        profile_dirs=("${unique[@]}")
    fi

    if [ ${#profile_dirs[@]} -eq 0 ]; then
        warning "No Firefox profiles found, so Firefox configuration is skipped."
        warning "Launch Firefox once, close it, then re-run the installer to configure it."
        return
    fi

    for profile in "${profile_dirs[@]}"; do
        local target="$profile/user.js"
        cp -f "$src_user_js" "$target"

        if [ "$USE_OLED" = true ]; then
            sed -i 's/user_pref("gnomeTheme.oledBlack", false);/user_pref("gnomeTheme.oledBlack", true);/' "$target"
            sed -i 's/user_pref("browser.display.background_color", "#2b2b2b");/user_pref("browser.display.background_color", "#000000");/' "$target"
        fi

        info "Configured Firefox profile: $(basename "$profile")"

        if [ -f "$profile/places.sqlite" ] && command -v sqlite3 &>/dev/null; then
            sqlite3 "$profile/places.sqlite" "DELETE FROM moz_bookmarks;" 2>/dev/null || true
            info "Cleared bookmarks for profile: $(basename "$profile")"
        fi
    done

    info "Firefox preferences applied (takes effect on next Firefox launch)."

    local src_policies
    src_policies=$(_resolve_firefox_repo_file "policies.json") || true
    if [ -f "$src_policies" ]; then
        info "Deploying Firefox enterprise policies (search engine, toolbar)"

        local firefox_dirs=(
            "/usr/lib/firefox"
            "/usr/lib64/firefox"
            "/usr/share/firefox"
            "/usr/lib/firefox-esr"
            "/opt/firefox"
            "/snap/firefox/current/usr/lib/firefox"
            "/var/lib/flatpak/app/org.mozilla.firefox/current/active/files/lib/firefox"
        )

        local found_any=false
        for fdir in "${firefox_dirs[@]}"; do
            if [ -d "$fdir" ]; then
                local dist_dir="$fdir/distribution"
                if [ "$IS_ATOMIC" = true ] && [[ "$fdir" == /usr/* ]]; then
                    continue
                fi
                sudo mkdir -p "$dist_dir" 2>/dev/null || continue
                if sudo cp -f "$src_policies" "$dist_dir/policies.json" 2>/dev/null; then
                    sudo chmod 644 "$dist_dir/policies.json" 2>/dev/null
                    info "Installed policies.json → $dist_dir/"
                    found_any=true
                fi
            fi
        done

        local snap_dist="$HOME/snap/firefox/common/.mozilla/firefox/distribution"
        if [ -d "$HOME/snap/firefox" ]; then
            mkdir -p "$snap_dist" 2>/dev/null
            cp -f "$src_policies" "$snap_dist/policies.json" 2>/dev/null && {
                info "Installed policies.json → $snap_dist/"
                found_any=true
            }
        fi

        local flatpak_dist="$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox/distribution"
        if [ -d "$HOME/.var/app/org.mozilla.firefox" ]; then
            mkdir -p "$flatpak_dist" 2>/dev/null
            cp -f "$src_policies" "$flatpak_dist/policies.json" 2>/dev/null && {
                info "Installed policies.json → $flatpak_dist/"
                found_any=true
            }
        fi

        if [ "$found_any" = false ]; then
            warning "Could not find Firefox installation directory to deploy policies.json."
            warning "You may need to manually copy policies.json to your Firefox distribution/ folder."
        else
            info "Firefox policies deployed (takes effect on next Firefox launch)."
        fi
    fi
}

