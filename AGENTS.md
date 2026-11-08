# 02Gnome

A Bash installer that configures a GNOME desktop in one run, `install.sh` cloning this repository
to `~/.dotfiles`, sourcing `config.sh` and the modules under `scripts/`, and walking the user
through profiles, applications, extensions, themes, Docker Compose services and cleanup with a
gum TUI and a plain fallback. Fedora Workstation and its atomic variants are the first targets,
other distributions follow where a step can.

## Documents

| File | Holds |
|---|---|
| [.github/REVIEW.md](.github/REVIEW.md) | Direction from the reviewing session, the items in their order, the decisions and the Replies the working session writes |
| [.github/STYLE.md](.github/STYLE.md) | Rules for every comment, message and Markdown file |
| [.github/COMMITS.md](.github/COMMITS.md) | How work reaches the history, and the form of a commit's message |

## Where things are

| Path | Holds |
|---|---|
| `install.sh` | The entry, bootstrap (atomic detection, git, the clone), the order of every step |
| `config.sh` | The user's lists, essential and optional applications, extensions, bloat, dock order, services |
| `scripts/` | The modules `install.sh` sources in number order, helpers and the TUI first, cleanup last |
| `gnome/<profile>/` | A profile's dconf files, imported in order, and its `setup.sh` |
| `docker/<service>/` | A Compose service, its `docker-compose.yml`, its `env` copied as `.env`, and its README |
| `firefox/` | Firefox's `user.js` and `policies.json` |
| `assets/themes/` | The Rewaita themes the installer copies into the app's data folder |
| `assets/icons/` | The web applications' icons |
| `.github/assets/` | The README's pictures |

## Conventions

- Prose follows `.github/STYLE.md`, which governs comments, messages, the TUI's text and Markdown.
  Read it before writing any of them.
- The account is EggyStudio and every address in the repository says so. No personal name appears
  in any file, link, message or commit.
- A document or a comment a user of the installer reads names no one who decided a thing, no
  owner, reviewer, session, tool or assistant, and gives the reason in their place.
- Nothing is committed or pushed by a working session. It changes the files and reports what it
  changed, by file, and the owner commits and pushes from their own tools in the form
  `.github/COMMITS.md` records.
- Of `.github/REVIEW.md`, its head, the items of the batch and the Replies are read before a batch
  is started. Only its Replies section is edited by the working session, for an item that is
  disputed or blocked and for the report of each batch.
- The installer changes the machine it runs on, so no step of it is run here to check it. A script
  is checked by `bash -n`, by shellcheck, by reading, and by running a function alone where it
  changes nothing, such as one that prints or parses. A Compose file is checked by
  `docker compose config` where Docker is present.
- Every outside thing the installer depends on, an application's Flatpak id, a Compose image, an
  extension's uuid, a data folder's layout, is read from its source as it is today before a line
  that names it is kept or changed, since the repository predates many of them by months.
