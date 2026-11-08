#!/usr/bin/env bash
# 02Gnome's configuration. The arrays below set what the installer installs
# and removes. The installer sources this file before its modules, so an edit
# takes effect at the next run of install.sh.

# Essential Flatpak applications, installed on every run.
ESSENTIAL_APPS=(
    "com.mattjakeman.ExtensionManager"     # Extension Manager, which browses and toggles GNOME extensions
    "com.github.tchx84.Flatseal"           # Flatseal, which manages Flatpak permissions
    "io.github.fabrialberio.pinapp"        # Pins, which creates application shortcuts
    "dev.qwery.AddWater"                   # Add Water, which applies the Adwaita theme to Firefox
    "io.github.swordpuffin.rewaita"        # Rewaita, which brings color to Adwaita
    "io.missioncenter.MissionCenter"       # Mission Center, a system monitor
    "org.pvermeer.WebAppHub"               # Web App Hub, which manages web applications
)

# Optional applications, offered at the start.
# Format: "Label|type:id"   type = flatpak | rpm | script
OPTIONAL_APPS=(
    # Entertainment
    "Steam|rpm:steam"
    "Discord|flatpak:com.discordapp.Discord"
    "Signal|flatpak:org.signal.Signal"
    "VLC|flatpak:org.videolan.VLC"
    # Creative
    "Blender|flatpak:org.blender.Blender"
    "GIMP|flatpak:org.gimp.GIMP"
    "Unity Hub|flatpak:com.unity.UnityHub"
    # Utilities
    "Visual Studio Code|flatpak:com.visualstudio.code"
    "JetBrains Rider|flatpak:com.jetbrains.Rider"
    "GitHub Desktop|flatpak:io.github.shiftey.Desktop"
    "Trayscale (Tailscale GUI)|flatpak:dev.deedles.Trayscale"
    # Developer Tools
    "Claude (AI assistant)|script:claude"
    "OpenCode (AI coding agent)|script:opencode"
    # Runtimes
    ".NET SDK & Runtimes|script:dotnet"
)

# GNOME Shell extensions, installed and enabled.
# Format: "uuid|Human-readable name"
GNOME_EXTENSIONS=(
    "appindicatorsupport@rgcjonas.gmail.com|AppIndicator"
    "arcmenu@arcmenu.com|ArcMenu"
    "clipboard-history@alexsaveau.dev|Clipboard History"
    "dash-to-dock@micxgx.gmail.com|Dash to Dock"
    "gtk4-ding@smedius.gitlab.com|Gtk4 Desktop Icons NG (DING)"
    "just-perfection-desktop@just-perfection|Just Perfection"
    "logomenu@aryan_k|Logo Menu"
    "panel-corners@aunetx|Panel Corners"
    "pip-on-top@rafostar.github.com|PiP on top"
    "quick-settings-audio-panel@rayzeq.github.io|Quick Settings Audio Panel"
    "restartto@tiagoporsch.github.io|Restart To"
    "user-theme@gnome-shell-extensions.gcampax.github.com|User Themes"
    "azwallpaper@azwallpaper.gitlab.com|Wallpaper Slideshow"
)

# Extensions to install but keep disabled by default
GNOME_EXTENSIONS_DISABLED=(
    "rounded-window-corners@fxgn|Rounded Window Corners Reborn"
    "Vitals@CoreCoding.com|Vitals"
)

# GNOME applications removed when the question at the start is answered yes.
# Format: "flatpak-id|dnf-pkg|pacman-pkg|Display Name"
GNOME_BLOAT_APPS=(
    "org.gnome.Boxes|gnome-boxes|gnome-boxes|Boxes"
    "org.gnome.Calendar|gnome-calendar|gnome-calendar|Calendar"
    "org.gnome.Snapshot|snapshot|snapshot|Camera"
    "org.gnome.Characters|gnome-characters|gnome-characters|Characters"
    "org.gnome.clocks|gnome-clocks|gnome-clocks|Clocks"
    "org.gnome.Connections|gnome-connections|gnome-connections|Connections"
    "org.gnome.Contacts|gnome-contacts|gnome-contacts|Contacts"
    "org.gnome.Extensions|gnome-extensions-app|gnome-extensions-app|Extensions"
    "org.gnome.baobab|baobab|baobab|Disk Usage Analyzer"
    "org.gnome.SimpleScan|simple-scan|simple-scan|Document Scanner"
    "org.fedoraproject.MediaWriter|mediawriter|-|Fedora Media Writer"
    "org.gnome.Yelp|yelp|yelp|Help"
    "-|libreoffice-calc|libreoffice-still-calc|LibreOffice Calc"
    "-|libreoffice-impress|libreoffice-still-impress|LibreOffice Impress"
    "-|libreoffice-writer|libreoffice-still-writer|LibreOffice Writer"
    "org.gnome.Maps|gnome-maps|gnome-maps|Maps"
    "org.gnome.SystemMonitor|gnome-system-monitor|gnome-system-monitor|System Monitor"
    "org.gnome.Tour|gnome-tour|gnome-tour|Tour"
    "org.gnome.Weather|gnome-weather|gnome-weather|Weather"
)

# The order of the optional applications in the dock.
# Format: "flatpak-id|rpm-desktop-name(s)"
OPTIONAL_PIN_ORDER=(
    "com.valvesoftware.Steam|steam"
    "com.discordapp.Discord|discord"
    "org.signal.Signal|signal-desktop"
    "org.blender.Blender|blender"
    "org.gimp.GIMP|gimp"
    "com.unity.UnityHub|unityhub"
    "com.visualstudio.code|code"
    "com.jetbrains.Rider|jetbrains-rider"
    "io.github.shiftey.Desktop|github-desktop"
)

# Docker Compose services, offered at the start.
# Format: "Label|directory-name"  (must exist under docker/)
DOCKER_SERVICES=(
    "Immich|immich"
    "Nextcloud|nextcloud"
    "Ollama + Open WebUI|ollama"
    "ZeroTier One|zerotierone"
)

