# Kite

A personal web browser built on Chromium.

This repo does not contain Chromium itself. It holds:

- `chromium_version.txt`: the Chromium stable release we build on (pinned).
- `patches/`: our changes to Chromium, applied in the order listed in `patches/series`.
- `scripts/`: download, patch and build scripts.
- `design/`: UI mockups (`browser-designs.html`; the default look is "Clean").

The Chromium source lives in `chromium/` and the build tools in `depot_tools/`; both are gitignored.
Moving to a new Chromium version = bump `chromium_version.txt`, re-apply the patches, fix any that no longer apply.

See `PROGRESS.md` for where things stand.
