#!/usr/bin/env bash
# 02Gnome's setup of the laptop profile.
# SPDX-License-Identifier: GPL-3.0-or-later
#
# install.sh runs this script for the laptop profile. It applies the GNOME
# settings for battery life and a touchpad.

set -euo pipefail

info() { echo -e "\033[0;36m[INFO]\033[0m  $*"; }

info "Applying Laptop profile settings"

if command -v gsettings &>/dev/null; then
    info "Applying laptop GNOME settings"

    # Enable automatic brightness via ambient light sensor
    gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled true \
        2>/dev/null || true

    # Suspend when lid is closed (on battery and on AC)
    gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'suspend' \
        2>/dev/null || true
    gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'suspend' \
        2>/dev/null || true

    # Enable tap-to-click on the touchpad
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true \
        2>/dev/null || true

    # Enable natural (reverse) scrolling on the touchpad
    gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true \
        2>/dev/null || true

    # Dim the screen after 5 minutes of inactivity to save battery
    gsettings set org.gnome.settings-daemon.plugins.power idle-dim true \
        2>/dev/null || true
    gsettings set org.gnome.desktop.session idle-delay 300 \
        2>/dev/null || true

    # Just Perfection puts the panel at the top and the clock in the center, the laptop default.
    gsettings set org.gnome.shell.extensions.just-perfection panel-position 0 \
        2>/dev/null || true
    gsettings set org.gnome.shell.extensions.just-perfection clock-menu-position 0 \
        2>/dev/null || true
fi

info "The laptop profile is set up."
