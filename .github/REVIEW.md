# Review

Reviewed on 2026-11-08 at 15:19, up to `9b10a82`, the README's edit of 2026-10-19, which the local
clone at `main` matches with nothing in flight. The tree names no person; the README's quick install
goes through a short link that resolves to the account's earlier handle and the repository's earlier
name, `GnomeBlueprint`, and a stale branch of that name stands on the remote 78 commits behind main
with nothing of its own. The history's 245 commits carry the earlier handle as author on 227 of
them, 11 with a personal address, and three messages name it. The installer's last substantial
commit is of 2026-05-23, so its outside dependencies are read as they are today before anything is
kept. The installed Rewaita, 1.1.8, keeps its themes as CSS custom properties in a `:root` block
where the repository's three themes are `@define-color` lists, and reads preference keys the
installer's `prefs.json` does not write, `accent`, `accent-fg`, `accent-tabs`, `firefox-theme`,
`dark-panel`, `trans-panel` and `no-pills`, remaking the file when one is missing. The Compose
services pin `latest` for Ollama, Open WebUI and ZeroTier and an older Valkey for Immich than
upstream's current file. `install.sh` numbers two steps 7 and runs 27 where the README's table says
22, and the README's Customization section names `install.sh` for lists that live in `config.sh` and
dconf files that no longer exist. Item 1 is done in the tree at 15:24 by the Unity Essentials
session, which started here before the owner opened a session of this repository's own, `02Gnome`,
that takes item 2 onward; the README's quick install is a short link of the owner's choosing at
15:47, `tinyurl.com/02gnome`, which answers straight with the raw file under EggyStudio and names no
one on the way, the full address under it, `firefox/user.js` names this repository where it named
the earlier one, and the stale branch is the owner's to delete. The documents' name check reads its
pattern from a shell variable, `FORBIDDEN_NAMES`, so no file in the tree spells the name. Item 2 is
done in the tree at 15:28 but for shellcheck, which the machine lacks and the session may not fetch,
the owner asked; the three themes are `:root` blocks with the 68 properties of the fullest built-in
themes and the app's status colors in hex, the preferences written with every key of the app's
DEFAULTS, the theme set through the app's own `--theme` option after `flatpak kill`, the Oled step
the same way; the app's `get_all` returns the file as it is, so a file missing a key stops the app
in a recursion, which is why every key is written. Item 3 is done in the tree at 15:33, the four
Compose files passing `docker compose config`, Immich's the v3.3.6 release file whole with Valkey 9
and the major pinned in its env, Nextcloud at 35, Ollama at 0.40.15 and Open WebUI at 0.13, ZeroTier
at 1.14.2 with the capability and the variable upstream does not need dropped, the generated
password hex since Immich takes letters and digits alone, and each service's README saying what is
pinned and what an earlier install does to upgrade; Immich's file keeps upstream's comments as they
are, so the next release's file replaces it whole, which STYLE.md's scope says. Item 4 is done in
the tree at 15:40, the ten questions asked in a row after the bootstrap and the sudo keepalive, the
23 steps after them running without a prompt and numbered once, each question split from its step,
two faults of the plain fallback mended, the `read` that took the piped script's own stdin under
curl and the profile menu that fell into the captured name, the sleeps replaced by waits on what
they waited for, the Tailscale sign-in out of the run and named at its end since it blocks on a
browser (Decision 5), services started with sudo where the docker group is not yet in force, every
printed line by STYLE.md, the README's table at the 28 steps in order, and the 17 Flatpak ids and 15
extension uuids read as current. Item 5 is done in the tree at 15:42, the README read against the
installer as items 2 to 4 leave it, Fedora 45 and the atomic download address as they are today, the
profiles from their dconf files, a false line on the battery out, the structure tree matching the
tree, the Customization section naming config.sh's seven arrays and the profile folders, every link
answering, and the laptop's clock position mended in its setup.sh where the dconf and the comment
disagreed with it; every rpm-ostree call that changes the system runs through sudo with the polkit
reason at the first. Item 6 is done locally at 16:04 on the owner's confirmation, the old history a
verified bundle under `/home/user/Projects/OLD/Backups/02Gnome/2026-11-08/`, the 227 commits of the
earlier handle made the account's as author and committer with their dates, two messages mended,
every tree matching its old one, the two bot commits and GitHub's two merge committers as they were,
the uncommitted items back with the same diffstat, and the name found nowhere on main; the owner's
steps stand in Replies item 7, the leased force-push of main, the deletion of the stale branch and a
prune, and a clone elsewhere, `~/.dotfiles` on an installed machine among them, cannot fast-forward
until it is reset or cloned again. The installer's own clone step handles that from 16:05, fetching
first, fast-forwarding only where the history leads on and otherwise stopping with its own words to
move the clone aside and carry config.sh's edits over, never resetting; two unused functions of the
bootstrap module went with it (Replies item 8). At 16:11 shellcheck 0.11.0, run from its container
on the owner's word, passes over install.sh with every module it sources and over each script alone;
its real findings are mended, kernel and orphan lists passed as quoted arrays, two chained updates
braced, the atomic gum download an if and else that finds the binary and installs it, at gum 2.0.2,
and a template count by find. Items 1 to 6 are done in the tree; the owner commits by Replies item 6
and pushes by item 7. The owner committed items 1 to 6's work in five commits of the shared form,
`f19c0f0` the documents, `ed8d353` the Rewaita themes, `925a15c` the Compose services, `ad8e14e` the
installer's order, questions and mends, and `da002ea` the README, on the rewritten history, and on
their word the reviewing session force-pushed main with a lease at 17:40 on 2026-11-08, the remote's
every author the account and the stale branch gone; the repository is at `da002ea` with nothing in
flight. Nothing is committed or pushed by the working session.

## Now

The owner's ask of 2026-11-08, the same treatment as Unity Essentials and the installer brought up
to date and bettered where necessary, the containers, the TUI and the order among the places named.
The items in the order they are done; the session changes files and reports each item in the
Replies and to the reviewing session, by file, with the reason.

1. **The address the reader reaches.** The README's quick install line shows the full address, `curl
    -fsSL https://raw.githubusercontent.com/EggyStudio/02Gnome/main/install.sh | bash`, the short
    link beside it only if the owner re-points it, which is theirs to do and is asked; the stale
    `GnomeBlueprint` branch is named for the owner to delete. A search of every file for the two
    parts of the name, case-insensitive, finds nothing and is run again at the end. Done in the tree
    at 15:24 on 2026-11-08, the quick install `curl -fsSL tinyurl.com/02gnome | bash` on the owner's
    word of 15:47, the link answering straight with the raw file under EggyStudio, the full address
    under it (Decision 4).

2. **Rewaita as the installed app has it.** Read the app's own source in its Flatpak,
    `/app/share/rewaita/rewaita/`, for how it lists, reads and applies a theme file and how it reads
    and remakes `prefs.json`, and bring the installer to it, the three themes under `assets/themes`
    written as the app's built-in themes are, a `:root` block of custom properties with every
    property a built-in theme has, the pure theme keeping its extra rules if the app keeps them; the
    theme chosen through the app's own command line option where it has one rather than by writing
    `prefs.json`, and where the file must be written, every key the app reads written with the app's
    default, so the app does not remake the file and drop the choice; the Oled step the same way.
    The user's data folder on this machine is read for the layout and never written. Done in the
    tree at 15:28 on 2026-11-08, shellcheck passing at 16:11.

3. **The containers against upstream.** Each service's Compose file read against the service's own
    current file or documentation, Immich's release file first, and brought to it where it drifted,
    images pinned to a version or a major rather than `latest`, the `env` files and the services'
    READMEs matching, the `.env` copy and the generated password kept, and `docker compose config`
    passing on each where Docker is present. What a service's upgrade asks of an existing install, a
    database step or a renamed volume, is said in its README. Done in the tree at 15:33 on
    2026-11-08, shellcheck passing at 16:11.

4. **The order and the TUI.** The questions asked first, profile, Tailscale, Oled, user preferences,
    wallpapers, bloat, optional applications and services, one after another at the start with gum
    and the plain fallback, and the steps then run without stopping, so a run of twenty minutes
    needs the user at its start alone; the steps numbered once in `install.sh` and the README's
    table saying the same steps in the same order; the sleep after the extensions replaced by a wait
    on what it waits for; every prompt and information line by STYLE.md. Shellcheck over every
    script, its findings fixed, and `bash -n` on each. Done in the tree at 15:40 on 2026-11-08, shellcheck passing at 16:11.

5. **The README and the services' READMEs.** The README read against the installer as the items
    above leave it and against STYLE.md, the Customization section naming `config.sh` and the
    profile folders as they are, the structure tree matching the tree, the Fedora release named as
    the current one, British spellings made American, the steps' table from item 4; the services'
    READMEs from item 3. The words under the header stand. Done in the tree at 15:42 on 2026-11-08.

6. **The history, last.** As for Unity Essentials and on the owner's confirmation, every author and
    committer of the earlier handle rewritten to the account's identity over main, the three
    messages mended and every other message and tree kept, the old history kept as a verified bundle
    under `Backups/` outside the tree, and the owner's force-push steps written in the Replies; the
    owner pushes. Done locally at 16:04 on 2026-11-08, for the owner to force-push.

## Decisions

1. **The same treatment.** On 2026-11-08 at about 15:10 the owner asked for the same treatment on
    this repository as on Unity Essentials and for it to be fixed, "as it is already more than 6
    months old and for example rewaita changed its data format too", and improved "generally all
    around where necessary, for example the containers and the tui and the order". Items 1 to 6.

2. **Files, not commits.** As the owner said for Unity Essentials the same day, the working
    session changes the files and the owner commits and pushes; the session commits nothing and
    pushes nothing, and reports by file. COMMITS.md records the history's form.

3. **The documents here.** The repository takes `AGENTS.md` and `.github/REVIEW.md`, `STYLE.md` and
    `COMMITS.md` as the engines have them, naming no person, and the owner commits them with the
    work.

4. **The short link.** On 2026-11-08 at about 15:35 the owner asked for the short install line back,
    valid and easier to write, so the README's quick install is `curl -fsSL bit.ly/02gnome | bash`
    with the full address under it; the link resolves today to the raw file under the earlier handle
    and repository name, which GitHub redirects, and the owner re-points it at
    `https://raw.githubusercontent.com/EggyStudio/02Gnome/main/install.sh` so the redirect names no
    one. At about 15:45 the owner reversed it, "just use this yes", the full address, "forget the
    short handle bitly", so the README's quick install is the one full line and no short link stands
    in it. At 15:47 the owner chose a short link that names no one, `tinyurl.com/02gnome`, which
    answers straight with the raw file under EggyStudio, so the quick install is that line with the
    full address under it.

5. **The questions first, the sign-in after.** On 2026-11-08 at 15:40 the review accepted item 4's
    shape, every question is asked at the start and the steps then run without stopping, so a run
    needs the user at its start alone, and `sudo tailscale up`, which blocks on a browser sign-in,
    is out of the steps and named at the run's end for the user to run. A step that would stop the
    run for a browser or a dialog is treated the same way.

6. **One STYLE.md and one COMMITS.md, and a file taken whole.** On 2026-11-08 at about 15:50 the
    owner said the rules do not change from project to project, the other projects' documents being
    right as they are, so this repository's STYLE.md and COMMITS.md are the shared texts the
    engines, the game and the modules keep, changed only in their opening sentence, the
    Documentation section said for Bash, the Scope and Checks for this repository's files and the
    When section, which says the owner commits and pushes here. A file taken whole from its
    upstream, as Immich's Compose file is from its release, keeps upstream's text as the shared
    Spelling rule keeps a license's text, so the next release's file replaces it whole, and the
    checks' hits in its comments are read and left; the service's README names the release. Recorded
    at 15:56.

7. **The history rewritten, confirmed.** On 2026-11-08 at 16:00 the owner confirmed item 6,
    "everything should say eggystudio not the clear name": every author and committer of the earlier
    handle, the noreply and the personal address alike, becomes the account's identity over main,
    the three messages that name the handle are mended, every other message and tree is kept, the
    old history is kept as a verified bundle outside the repository, and the owner force-pushes main
    from their own tools, the stale remote branch deleted with it.

## Replies

1. **Item 1, 2026-11-08.**
    - `README.md`: the quick install line is
      `curl -fsSL https://raw.githubusercontent.com/EggyStudio/02Gnome/main/install.sh | bash`,
      which returns HTTP 200, and the short link is gone from the README. On the owner's word
      of 2026-11-08 the README carries no short link, and the full address is its one line.
    - `firefox/user.js`: its header named the earlier repository name, `GnomeBlueprint`, and its
      address. Both name 02Gnome.
    - The remote has a branch `GnomeBlueprint` beside `main`, for the owner to delete with
      `git push origin --delete GnomeBlueprint`.
    - Disputed. The two parts of the name appear in the tree in one form only, the search
      pattern in the checks of `.github/STYLE.md` and `.github/COMMITS.md`. Committed as written,
      those documents carry the name into the repository and its history. A pattern that does not
      spell the name, read from an environment variable or a file kept outside the tree, keeps
      both documents clean. This session edits only the Replies, so the change is the reviewing
      session's or the owner's.
    - Item 1 is the Unity Essentials session's, and it stops there. The owner moved 02Gnome to its
      own session, which starts at item 2. This session changed `README.md` and `firefox/user.js`
      and nothing else in the tree. For item 2 it read Rewaita 1.1.8's `main.py` and the
      `Preferences` class in `utils.py` and changed no file.

2. **Item 2, 2026-11-08.**
    - `assets/themes/dark/A Default Dark Theme.css`, `assets/themes/dark/A Pure Dark Theme.css`,
      `assets/themes/light/A Default Light Theme.css`: written as Rewaita 1.1.8's built-in themes
      are, a `:root` block of custom properties followed by the `toast` and `toggle:checked` rules
      the built-in Adwaita theme has. Each holds the 68 properties of the fullest built-in themes,
      the shades 1 to 5 of every palette color and the active toggle colors among them, and the
      success, warning, destructive and error colors the app's own custom template has. Every value
      is a hex color, because the app copies the values into its GTK 3 and GNOME Shell templates
      and its GtkSourceView scheme, where a `var()` reference does not resolve. Read through the
      app's own parsing on this machine, each file leaves no template color unresolved that the
      app does not fill itself. The window, view, header bar, popover, card, sidebar and status
      colors are the earlier files'. The accent is no longer fixed in the theme, since the app
      takes it from GNOME's accent setting through the palette, and the palette's first shades
      are the built-in Adwaita theme's libadwaita accent colors, blue `#3584e4` among them, the
      accent the earlier files fixed. The pure theme had no rules beyond the other two.
    - `scripts/07-themes.sh`: `_write_rewaita_prefs` writes every key of the app's
      `Preferences.DEFAULTS`, `modify-cinnamon-shell` and the theme defaults of `"default"`
      among them, keeping a value the user has set, and records the dark and light theme.
      The app reads every key at start and, on a missing key, retries the read until Python's
      recursion limit ends the start, so a partial file stops it starting rather than being
      remade. `apply_rewaita_themes` then applies the theme for the current color scheme
      through the app's `--theme` option, by the name the app derives from the file name,
      `a-default-dark-theme`, `a-pure-dark-theme` or `a-default-light-theme`. The option sets
      only the scheme that is current, so the other theme is set through the file, and the app
      applies it when the scheme changes. A running instance would receive the second
      instance's command line without the option's value, so the step stops Rewaita first with
      `flatpak kill`, and its autostart entry starts it again at the next login. The run is
      bounded by `timeout 60` and its output read for the app's "was not found". The Oled step
      calls the same function with the pure theme as the dark theme, in place of its own write
      of `prefs.json`. The Python reads its paths and theme names as arguments rather than
      having them pasted into its source.
    - Checked by `bash -n`, by running `_rewaita_cli_name` and `_write_rewaita_prefs` alone
      against copies in the session's scratch space, which on the earlier file of this
      machine's data folder adds the eight missing keys and keeps the ten it has, and by the
      checks of STYLE.md over the changed lines, whose one hit is `python3 -` reading its
      script from standard input. The data folder was read and not written, and Rewaita was not
      run.
    - Blocked. Shellcheck is not on the machine, and fetching its static release was refused by
      the session's permission settings, so shellcheck has not run on this item. The owner
      can allow the download or install shellcheck, and the run follows.
    - For the owner. This machine's `prefs.json` is of 2026-04-20 and lacks eight of the keys,
      yet the data folder holds links to the built-in themes made at 15:13 today, which the
      app makes only once its window opens. The app was not run here to settle it, and a run
      of the step on this machine is the test that does.

3. **Item 3, 2026-11-08.**
    - `docker/immich/docker-compose.yml`: replaced whole by the file of Immich's current release,
      v3.3.6, which moves Valkey from 8 to 9 with its digest, makes the Redis health check look
      for `PONG`, and adds the database's health check and the comment over its volume. The file
      is kept as Immich publishes it, its comments included, so a later release's file replaces
      it whole; those comments hold the spaced hyphen STYLE.md rules out, which is for the
      reviewing session to accept or to have rewritten.
    - `docker/immich/env`: from the release's `example.env`, `IMMICH_VERSION=v3` in place of
      `release`, which pins the major, and the release's notes on the database folder and on the
      password's characters. The placeholder stays `please-change-me` for the installer to replace.
    - `docker/nextcloud/docker-compose.yml`: `nextcloud:35-apache` in place of `nextcloud:apache`,
      35 being the current major. Nextcloud upgrades one major at a time, and the unpinned tag
      moved an install across several at a pull. PostgreSQL `16-alpine` and Redis `7-alpine`
      stand, since each is pinned to a major and a PostgreSQL major change needs a dump and a
      restore.
    - `docker/nextcloud/env`: the password's comment says the installer generates it and takes
      `A-Za-z0-9`.
    - `docker/ollama/docker-compose.yml`: Ollama `0.40.15`, the current release, since its image
      has no tag for a minor version, and Open WebUI `0.13`, a tag that takes that minor version's
      patches. `OLLAMA_NUM_GPU_LAYERS` is removed, since Ollama's `envconfig` reads no such
      variable; the GPU request stays.
    - `docker/zerotierone/docker-compose.yml`: `zerotier/zerotier:1.14.2`, the latest version
      on Docker Hub, where 1.16 is not published. `SYS_ADMIN` and `ZT_OVERRIDE_LOCAL_CONF` are
      removed, since ZeroTier's container documentation asks for `NET_ADMIN` and `/dev/net/tun`
      alone and its entrypoint reads no such variable.
    - `scripts/03-docker.sh`: the generated database password is `openssl rand -hex 20`, since
      Immich takes only `A-Za-z0-9` and base64 gave `+`, `/` and `=`. A pipe through `head`
      was not used, because under the installer's `pipefail` its broken pipe stops the run.
      The `.env` copy and its placeholder replacement are kept.
    - `docker/*/README.md`: each says what is pinned and how to update within it, in the terms
      of STYLE.md. Immich's says an earlier install sets `IMMICH_VERSION=v3` in the `.env` the
      installer keeps, the VectorChord migration for one that never ran v1.133.0 or later, and
      links the v3 migration guide. Nextcloud's gives the command that prints an install's
      major and the stepping through each major to 35. Ollama's says Open WebUI 0.13 changes its
      database schema, so its data folder is copied first.
    - Checked by `docker compose config -q` on each service with its `env` copied as `.env` for
      the run and removed after, all four passing, by `bash -n` on `scripts/03-docker.sh`, and
      by the checks of STYLE.md over the changed lines, whose hits are Immich's own comment
      ("If you want to change") and the `python3 -` of item 2. Shellcheck waits as in item 2.

4. **Item 4, 2026-11-08.**
    - `scripts/01-common.sh`: `ask_yes_no`, `ask_choose_one` and `ask_choose_many` ask every
      question, with gum and with the plain fallback. They read the answer from `/dev/tty` and
      write the plain prompts to standard error. Under `curl | bash` the plain fallback's `read`
      took the script's own standard input, met its end and, under `set -e`, stopped the run,
      and `select_profile`'s menu was captured into the profile's name by the `$(...)` that
      called it. In the plain fallback, Enter on a list that gum shows preselected keeps all of
      it, as gum does, where it chose none before. `start_sudo_keepalive` asks for sudo's
      password once and renews it each minute in the background until the installer exits, so
      no step stops for it.
    - `install.sh`: steps 1 to 5 bootstrap, ask for sudo and install gum, ask whether to start,
      then ask every question one after another, the profile, Tailscale, Oled, the user
      preferences, the wallpapers, the removal of GNOME applications, the optional applications,
      the services, the NVIDIA drivers and the reboot. Steps 6 to 28 run without a question,
      each numbered once. The Rewaita step follows the Oled answer, since it is known by then.
    - The modules split each question from its step, `ask_profile`, `ask_install_tailscale`
      and `install_tailscale`, `ask_oled_preference` and `apply_oled_preference`,
      `ask_user_preferences` and `apply_user_preferences`, `ask_download_wallpapers` and
      `download_wallpapers`, `ask_uninstall_bloat` and `uninstall_bloat`, `ask_optional_apps`
      and `install_optional_apps`, `ask_docker_services` and `install_docker_services`,
      `ask_nvidia_drivers` and `install_nvidia_drivers`, and `ask_reboot` and
      `reboot_if_chosen`. The NVIDIA question is asked only on a machine with an NVIDIA GPU and
      no NVIDIA kernel module. The Ptyxis profile lookup the Oled step ran twice is
      `_ptyxis_profile_uuid`.
    - `scripts/03-docker.sh`: `sudo tailscale up` is no longer run inside the steps, since it
      waits for a sign-in in the browser. The step installs Tailscale and starts `tailscaled`,
      and the end of the run names `sudo tailscale up`. A service starts with `sudo docker
      compose` where the docker group added in this run does not yet apply, and on an atomic
      system, where Docker arrives at the reboot, the step names the command to run then.
    - `scripts/04-extensions.sh`: `wait_for_extension_settings` replaces the `sleep 3`. It
      waits until GNOME Shell's dconf settings stop changing between two reads a second apart,
      up to 20 seconds, which the profile's second import needs. On this machine, with
      nothing changing, it returns after one second. In `configure_firefox`, a wait for Firefox's
      processes to end, up to 10 seconds, replaces another `sleep 3`.
    - Every prompt and information line of the scripts, `config.sh`'s comments and the
      scripts' headers follow STYLE.md, without trailing ellipses, spaced hyphens or colons
      inside a sentence. The user preferences' labels read as sentences, "Keep the screen on and
      undimmed when idle" among them, and "Disk Usage Analyzer" is GNOME's spelling.
    - `README.md`: the steps' table lists the 28 steps in `install.sh`'s order. On the
      owner's word the quick install is `curl -fsSL tinyurl.com/02gnome | bash`, with the full
      address in a second block. The link redirects, over HTTP and HTTPS, straight to
      `https://raw.githubusercontent.com/EggyStudio/02Gnome/main/install.sh`, which returns 200,
      so no personal name shows on the way, where the two bit.ly links passed through the
      earlier handle or ended at a 404.
    - Read against their sources today, the 17 Flatpak ids of `config.sh` are on Flathub, and
      the 15 extension uuids each have a release for GNOME Shell 50.
    - Checked by `bash -n` on every script, by running the plain fallback's helpers and the
      ten questions alone with scripted answers under `script`, each answer arriving in its
      variable, and by the checks of STYLE.md, whose hits are the format labels of
      `config.sh`, Immich's upstream comments, and the README's British spellings, which are
      item 5's. Shellcheck waits as in item 2.
    - Every `rpm-ostree` call that changes the system, its `install`, `uninstall`, `override`,
      `upgrade` and `cleanup` across `install.sh` and the modules, runs through sudo under the
      kept credential, since polkit questions the unprivileged client alone and its dialog would
      stop the run. The comment over the first call, in `_early_install_git`, says so. The
      read-only `rpm-ostree status` stays the user's.

5. **Item 5, 2026-11-08.**
    - `README.md`: read against the installer as items 2 to 4 leave it and against STYLE.md,
      the words under the header standing. Fedora Workstation 45 is the current release, which
      Fedora's `releases.json` lists, and Silverblue's link is its page under
      `atomic-desktops`. The profiles' lists say what the dconf files and `setup.sh` set. The
      laptop's line "Battery percentage shown" went, since both profiles set
      `show-battery-percentage=false`, and the desktop's power button and the laptop's dimming
      came in. The Theming section names `assets/themes`, where it named `themes`, and the
      Rewaita step's `--theme` option. The section on removals names the question at the start.
      The extensions' table has a State column for the two installed disabled, which sat in a
      third cell of a two-column table. The services' section says the images are pinned and
      the services' READMEs give the upgrade. The atomic note says Docker and the services
      start after the reboot, which the question at the start can schedule. The structure tree
      matches `git ls-files`, with `AGENTS.md` and `.github/` added and the modules' comments
      saying what each holds. Customization names `config.sh`'s seven arrays with each entry's
      form, the profile folders' dconf files with their full-path sections, and `REPO_URL` for
      a fork, where it named `install.sh` for the lists and `desktop.dconf` and `laptop.dconf`,
      which do not exist. British spellings are American, and the spaced hyphens, the colons
      inside a sentence and "nice" are gone outside the header. The quick install is item 1's and the steps'
      table item 4's.
    - `gnome/laptop/setup.sh`: Just Perfection's `clock-menu-position` is `0`, the center, as
      `gnome/laptop/04-extensions.dconf` sets it and the comment says. The script set `1`, the
      right, and the profile's second import set the center back. The headers of both profiles'
      scripts and their last lines follow STYLE.md, "optimised" among them.
    - The services' READMEs are item 3's.
    - Checked by the checks of STYLE.
    - Open. Shellcheck over every changed script, once the owner has installed it, and item 6,
      which waits for the owner's confirmation.

6. **Summary of items 1 to 5, 2026-11-08.** Every changed file by item, for the commits. A file
    that two items change carries both, so its hunks are staged by item with `git add -p`, or
    the file goes in the later item's commit.
    - Item 1
        - `README.md`, the quick install's full address (also items 4 and 5).
        - `firefox/user.js`, the header names 02Gnome.
    - Item 2
        - `assets/themes/dark/A Default Dark Theme.css`, Rewaita 1.1.8's `:root` format.
        - `assets/themes/dark/A Pure Dark Theme.css`, the same.
        - `assets/themes/light/A Default Light Theme.css`, the same.
        - `scripts/07-themes.sh`, the full `prefs.json` and the `--theme` option (also item 4).
    - Item 3
        - `docker/immich/docker-compose.yml`, Immich's v3.3.6 release file.
        - `docker/immich/env`, `IMMICH_VERSION=v3` and the release's notes.
        - `docker/immich/README.md`, the pin and the upgrade from an earlier install.
        - `docker/nextcloud/docker-compose.yml`, `nextcloud:35-apache`.
        - `docker/nextcloud/env`, the password's comment.
        - `docker/nextcloud/README.md`, the pins and the stepping through each major.
        - `docker/ollama/docker-compose.yml`, Ollama `0.40.15`, Open WebUI `0.13`, the unread variable out.
        - `docker/ollama/README.md`, the versions and Open WebUI's schema change.
        - `docker/zerotierone/docker-compose.yml`, `1.14.2`, `SYS_ADMIN` and the unread variable out.
        - `docker/zerotierone/README.md`, the version and the capability.
        - `scripts/03-docker.sh`, the hex password (also item 4).
    - Item 4
        - `install.sh`, the questions first, the 28 steps numbered once, rpm-ostree through sudo.
        - `scripts/01-common.sh`, the question helpers, the sudo keepalive, rpm-ostree through sudo.
        - `scripts/02-bootstrap.sh`, the messages and rpm-ostree through sudo.
        - `scripts/03-docker.sh`, Tailscale and the services split, `_compose_up`, rpm-ostree through sudo.
        - `scripts/04-extensions.sh`, `wait_for_extension_settings` and the messages.
        - `scripts/05-apps.sh`, the optional applications split and the messages.
        - `scripts/06-gnome.sh`, the profile and preferences split, the labels and the messages.
        - `scripts/07-themes.sh`, the Oled split, `_ptyxis_profile_uuid`, the Firefox wait, the messages.
        - `scripts/08-cleanup.sh`, the four questions split, the messages, rpm-ostree through sudo.
        - `config.sh`, the comments and "Disk Usage Analyzer".
        - `gnome/desktop/setup.sh`, the header and the messages (also item 5).
        - `gnome/laptop/setup.sh`, the header and the messages (also item 5).
        - `README.md`, the TinyURL line with the full address, and the steps' table (also items 1 and 5).
    - Item 5
        - `README.md`, read against the installer and STYLE.md (also items 1 and 4).
        - `gnome/laptop/setup.sh`, Just Perfection's clock in the center.
        - `gnome/desktop/setup.sh`, the header and the last line.
    - The documents
        - `AGENTS.md`, `.github/REVIEW.md`, `.github/STYLE.md` and `.github/COMMITS.md`, new, committed with the work as Decision 3 says.
    - Banners, on the owner's word of 2026-11-08
        - Every `# ─── Name ───` banner and `config.sh`'s box are removed from `install.sh`,
          `config.sh`, the eight modules and both profiles' `setup.sh`. The three that carried a
          reason stand as plain comments over their code, `PROTECTED_RE` in
          `scripts/01-common.sh`, the early helpers in `install.sh`, and the arrays of
          `config.sh`.
        - `.github/STYLE.md`, the banners' allowance out of Punctuation, Comments and Scope.
        - `firefox/user.js`, its eleven ruled section comments as plain `// Name` comments over
          their preferences, the names in STYLE.md's terms.
        - `install.sh`'s logo in block letters stays, on the owner's word of 2026-11-08, since it is
          the text the installer prints at its start and no comment banner.
    - Before the commits, shellcheck over every changed script, once the owner has installed it.
      Item 6 waits for the owner's confirmation.

7. **Item 6, 2026-11-08.** Done on the owner's confirmation, Decision 7, asked again in this
    session and answered "Yes, rewrite now".
    - The old history is kept as a bundle of every ref, `main`, `origin/main` and
      `origin/GnomeBlueprint`, at `Backups/02Gnome/2026-11-08/02Gnome-before-rewrite.bundle`
      beside the repository, outside its tree, 12 MB. `git bundle verify` reports a complete
      history. It holds the earlier identity and stays on this machine.
    - The uncommitted work of items 1 to 5 was stashed with the untracked documents, `main` was
      rewritten with `git filter-branch`, and the stash was popped. The tree's 27 modified files
      and four untracked documents are back, with the same diffstat as before the stash.
    - Of `main`'s 245 commits, 227 had the earlier handle as author and committer, 11 of them
      with the personal address. All 227 are EggyStudio with
      `57494543+EggyStudio@users.noreply.github.com` as author and as committer, where the
      committer was the handle; the 2 merges committed by GitHub keep GitHub as committer, and
      the 2 commits by `copilot-swe-agent[bot]` keep their author, since neither names a person.
      `main` counts 243 commits by EggyStudio and 2 by the bot.
    - Two messages named the handle and say EggyStudio. The merge of pull request #1 says
      `from EggyStudio/copilot/add-install-script-and-profiles`, and the commit before it has
      its `Agent-Logs-Url` under `EggyStudio/GnomeBlueprint` and its `Co-authored-by` line as
      EggyStudio with the noreply address. Every other message is unchanged, compared message
      by message against the old commits.
    - All 245 trees match their old counterparts in order, and every author and committer date
      is kept. No author, committer or message on `main` carries either part of the name or the
      personal address. Four commits made on GitHub's site carried GitHub's signature, which a
      rewrite cannot keep, so they are unsigned now.
    - `refs/original` is removed and the reflogs are expired and pruned, so no local ref but the
      remote-tracking ones reaches the old commits. Those go with the force-push below.

    The owner's steps, from this repository:

    ```bash
    # Main, replaced only if the remote is still at the old head, 9b10a82.
    git push --force-with-lease=main:9b10a829bd938c8bb5d6804c0eb05ef0e68c7d6c origin main

    # The stale branch of the earlier name, 78 commits behind with nothing of its own.
    git push origin --delete GnomeBlueprint

    git fetch --prune origin
    ```

    What changes for the owner:
    - Every commit's hash on `main` changes, so a clone elsewhere, `~/.dotfiles` on an
      installed machine among them, cannot fast-forward. The installer's `git pull --ff-only`
      fails there until the clone is replaced, with `git fetch origin` and
      `git reset --hard origin/main` in it, or by removing `~/.dotfiles` and running the
      installer again.
    - GitHub keeps the old commits reachable by hash for a time, and pull request #1 keeps its
      record, which names the handle as GitHub shows it; GitHub's support removes cached views
      on request.
    - The commit work of items 1 to 5 goes on top of the rewritten `main`, before or after the
      push.

8. **Item 4, the clone after the rewrite, 2026-11-08.**
    - `install.sh`: `_early_clone_repo` fetches, then fast-forwards the existing clone at
      `~/.dotfiles` only where its `HEAD` leads to the upstream branch. Where the history no
      longer leads there, as on every installed machine once `main` is force-pushed, the run
      stops with the installer's own words, that the clone no longer follows the repository's
      history and is moved aside, with `mv ~/.dotfiles ~/.dotfiles.old` as the example, or
      removed before the installer runs again, the edits to `config.sh` carried over by hand.
      Where a fast-forward would overwrite an edited file, the run stops with the same advice
      in place of git's refusal. A clone is never reset, since `config.sh` is the user's to
      edit. A fetch that fails, with no network, warns and runs the clone as it is.
    - `scripts/02-bootstrap.sh`: its `install_git` and `clone_repo` are removed, since nothing
      calls them and `install.sh` does both before the modules can be sourced; the second
      held the same `pull --ff-only`. Its header says so.
    - The item 6 note on `~/.dotfiles` reads with this, so the reset given there is the owner's
      own choice for their clone and not the installer's.
    - Checked by `bash -n` on both files, by running `_early_clone_repo` alone under
      `set -euo pipefail` against four scratch clones, one that fast-forwards, one whose
      remote's history was replaced, one with an edit to `config.sh` that the update touches,
      and one already current, each giving the result above, and by the checks of STYLE.md
      over the changed lines, which find nothing.

9. **Shellcheck, 2026-11-08.** Shellcheck 0.11.0, run from the `docker.io/koalaman/shellcheck:stable`
    image with the tree mounted read-only, since the owner chose the container over installing it.
    - The first run, over `install.sh`, `config.sh`, the modules and both profiles' `setup.sh`,
      gave 26 findings. 21 came from the files being checked apart, the arrays of `config.sh`
      and the globals of `install.sh` read as unused, `BOLD` as unassigned, and the sourced
      modules as not followed. `install.sh` carries a `# shellcheck source=` line over each
      `source`, so a run over it follows every module and `config.sh` and reads them as one
      program.
    - `scripts/08-cleanup.sh`: the old kernels and the pacman orphans were passed to `dnf
      remove` and `pacman -Rns` as unquoted strings. Each is read into an array with `mapfile`
      and passed quoted.
    - `scripts/02-bootstrap.sh` and `scripts/08-cleanup.sh`: `apt-get update && apt-get upgrade
      || warning` groups the two commands in braces, so the warning follows either failing.
    - `scripts/02-bootstrap.sh`: on an atomic system the gum download used `A && { } || { }`,
      where a failed `tar` ran on into `chmod` on a missing file. It is an `if`, finds the
      binary in the archive wherever the release puts it, and installs it with `install -m 755`.
      Its version is 2.0.2, gum's current release, where it was 0.14.5; gum 2's notes name no
      change to its interface, and the Charm repositories the other distributions use serve the
      current release.
    - `scripts/06-gnome.sh`: the templates' count uses `find` where it parsed `ls`.
    - The second run reports nothing over `install.sh` with everything it sources, and nothing
      over `config.sh`, the modules and the profiles' scripts each alone, with only the three
      codes that come of a file checked apart, SC2034, SC2154 and SC1091, left out. `bash -n`
      passes on every script, and the checks of STYLE.md over the changed lines find nothing.
    - Items 1 to 6 and the clone's handling are done. The tree is the owner's to commit by the
      summary in Replies item 6, with `scripts/02-bootstrap.sh`, `scripts/06-gnome.sh`,
      `scripts/08-cleanup.sh` and `install.sh` carrying these fixes too, and to push by the
      steps in Replies item 7.
