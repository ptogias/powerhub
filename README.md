# PowerHub

A single-file, client-side gym management app for tracking members, class schedules, attendance, and payments. No build step, no backend, no dependencies — just open `index.html` in a browser.

The UI is in Greek.

## Features

- **Members** — profiles with contact info, active/inactive status, and per-category class balances.
- **Class categories** — classes are tracked separately per category (e.g. Βάρη / Πιλάτες); a payment buys N classes in one category and only attendance in that category draws down its balance.
- **Weekly schedule** — recurring class slots with capacity, plus one-off overrides (cancel/edit a single occurrence without touching the recurring series).
- **Attendance** — mark members present, justified absence, or unjustified absence per class/date. Justified absences only cost a credit every 2nd time. Class credits are consumed FIFO against payment "packages," oldest first, by actual attendance date.
- **Payments** — record payments as packages of classes; a running ledger shows how each package was used and when it became active.
- **Notes** — free-form notes with a reviewed/unreviewed flag.
- **Dashboard** — a "needs attention" view surfacing members who are low on or out of classes.
- **Backup & restore** — export/import the entire dataset as a JSON file. On browsers that support the File System Access API, the app can also save live to a chosen file on disk instead of relying solely on `localStorage`.

## Data storage

All data lives in the browser's `localStorage` (with an optional live file-save fallback described above). There is no server component — data does not sync between browsers or devices unless you use the export/import backup feature.

## Running it

Just open `index.html` in a modern browser (Chrome/Edge recommended for live file-save support; other browsers fall back to `localStorage` + manual JSON export/import).

```
open index.html
```

## Project structure

Everything — markup, styles, and logic — lives in the single `index.html` file.

## Shipping updates to a non-technical user (Windows)

`Open PowerHub.bat` is a launcher for the person running the app locally on Windows. Instead of opening `index.html` directly, they double-click this file, which:

1. Tries to download the latest `index.html` from this repo's `main` branch (5 second timeout).
2. Overwrites the local `index.html` in place if the download succeeds.
3. Opens `index.html` in the default browser either way (falls back to the existing local copy if there's no internet).

Overwriting the file **in place, at the same path**, is what matters — browsers key `localStorage` for `file://` pages off the full file path, so as long as the filename and folder never change, the person's data survives every update.

The repo is **public**, so the raw-file URL works with no authentication — no token to manage or rotate. This is fine because no user data is ever committed to the repo (it only ever holds app code); if that ever changes, revisit this.

Setup, once this repo exists on GitHub:

1. In `Open PowerHub.bat`, replace `YOUR_GITHUB_USERNAME` and `YOUR_REPO_NAME` in the `RAW_URL` line with the actual repo path.
2. Give the person both `index.html` and `Open PowerHub.bat` in the same folder, and have them use the `.bat` file (a desktop shortcut to it works well) instead of opening `index.html` directly.
3. From then on, pushing changes to `main` is enough — they'll pick them up next time they launch the app.
