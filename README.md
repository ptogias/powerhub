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

All data lives in the browser: every save goes to `localStorage` (instant, but capped at roughly 5 MB, which a busy gym fills in about a year of attendance) **and** to IndexedDB (a far larger budget). On load the app reads `localStorage` for an instant first paint, then adopts the IndexedDB copy if it is newer — so once `localStorage` is full, saving simply continues in IndexedDB and an amber notice suggests taking a backup. There is no server component — data does not sync between browsers or devices unless you use the export/import backup feature (or the optional live file-save described above).

## Running it

Just open `index.html` in a modern browser (Chrome/Edge recommended for live file-save support; other browsers fall back to `localStorage` + manual JSON export/import).

```
open index.html
```

## Project structure

```
index.html             the entire app — markup, styles, and logic
README.md
windows-launcher/       distribution tooling for the Windows end user (see below)
  PowerHub.vbs
  Δημιουργία Συντόμευσης.vbs
  powerhub.ico
```

`index.html` is the only file the app itself needs. Everything under `windows-launcher/` exists solely to get updates to a non-technical Windows user automatically — it's not part of the app.

## Shipping updates to a non-technical user (Windows)

`PowerHub.vbs` is the launcher for the person running the app locally on Windows. Instead of opening `index.html` directly, they double-click this file (or a desktop shortcut to it — see below), which:

1. Tries to download the latest `index.html` from this repo's `main` branch (5 second timeout) and compares it to the local copy by SHA-256 hash, all inside one hidden PowerShell call — no console window ever appears. TLS 1.2 is enabled explicitly so it also works on older Windows versions.
2. Shows a small popup that auto-closes after a few seconds, saying exactly what happened:
   - **"Δεν υπάρχει σύνδεση στο διαδίκτυο - δεν έγιναν ενημερώσεις."** — no internet reachable at all.
   - **"Βρέθηκε σύνδεση στο διαδίκτυο, αλλά η ενημέρωση απέτυχε - δεν έγιναν ενημερώσεις."** — internet works, but the download itself failed (e.g. wrong URL/branch, GitHub down) — a sign something's misconfigured, worth checking on your end.
   - **"Βρέθηκε σύνδεση στο διαδίκτυο - δεν υπάρχουν ενημερώσεις."** — downloaded fine, but it's identical to what they already have.
   - **"Βρέθηκε σύνδεση στο διαδίκτυο - έγιναν ενημερώσεις."** — a real update was found and applied.
   - **"Η ενημέρωση απέτυχε (...) - δεν έγιναν ενημερώσεις."** — something local went wrong (e.g. `index.html` is read-only or locked, PowerShell missing). The message includes the Windows error text.
3. Opens `index.html` in the default browser either way, using whatever local copy is current at that point. If `index.html` is missing next to the launcher (and couldn't be downloaded), it says so instead of failing silently.

Overwriting the file **in place, at the same path**, is what matters: Firefox keys `file://` storage off the file's location, so a renamed or moved file would look like a brand-new app with no data. (Chrome and Edge share one storage area across all local files, so they are more forgiving — but keep the path stable regardless.)

Both `.vbs` files **must be saved as UTF-16 LE with BOM** — Windows Script Host cannot read UTF-8 and would turn every Greek popup into gibberish. The repo's `.gitattributes` stores them as UTF-8 in git but checks them out as UTF-16 with CRLF line endings automatically; if you edit them by hand outside git, keep that encoding.

The repo is **public**, so the raw-file URL works with no authentication — no token to manage or rotate. This is fine because no user data is ever committed to the repo (it only ever holds app code); if that ever changes, revisit this.

### Setup, once this repo exists on GitHub

1. `rawUrl` in `windows-launcher/PowerHub.vbs` already points at this repo's `main` branch; change it only if the repo moves. Remember that the person only receives what has been **pushed** to `main`.
2. On the person's PC, put `index.html` together with the three files from `windows-launcher/` **flattened into one folder** (`PowerHub.vbs`, `Δημιουργία Συντόμευσης.vbs`, and `powerhub.ico` all sit next to `index.html`, not in a subfolder) — the launcher expects `index.html` to be right next to it.
3. Have them double-click `Δημιουργία Συντόμευσης.vbs` **once** — it creates a "PowerHub" shortcut on their Desktop pointing at `PowerHub.vbs`, using `powerhub.ico` as its icon, so they never need to open this folder again.
4. Tell them to always launch the app via that Desktop shortcut, not by opening `index.html` directly.
5. From then on, pushing changes to `main` is enough — they'll pick them up next time they launch the app.

### The Windows security warning on first run

Because `PowerHub.vbs` isn't a digitally signed, well-known application, Windows will likely show an **"Open File - Security Warning"** dialog the first time it's run (this is normal for any script received via email/USB/zip — it's not specific to this app, and code-signing to remove it costs money for a cert that isn't worth it for a single-user internal tool). Tell the person: the first time it appears, click **"Run"** (there may also be an "Unblock" checkbox in the file's Properties dialog that prevents the warning on future runs of that same file).
