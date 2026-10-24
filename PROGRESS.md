# Progress

Name: **Kite**. Base: Chromium **156.0.8078.47** (stable, 2026-10-24).

## Phases
- [x] 0. Machine check + repo setup
- [ ] 1. Chromium building and launching (toolchain ready, build not started)
- [ ] 2. Branding, Widevine + proprietary codecs, DRM/H.264 verified
- [ ] 3. Built-in ad blocker (uBlock Origin, on by default)
- [ ] 4. New tab page (WebUI, Clean design, engine dropdown)
- [ ] 5. Compact + frameless modes, vertical tabs, customization settings

## Machine (checked 2026-10-24)
- Fedora 44, kernel 7.2.7, KDE Plasma, Secure Boot on (doesn't affect building or Widevine).
- Ryzen 5 7600X (12 threads), 30 GiB RAM + 8 GB zram swap.
- `/home` (btrfs): 239 GB free. Enough for the source plus build output (~100–150 GB).
- Have: git 2.55, python 3.14, gcc 16, ninja 1.13. Not needed system-wide: clang and gn (Chromium brings its own).

## Log
- 2026-10-24: Created repo, copied mockups into `design/`, pinned Chromium 156.0.8078.47.
- 2026-10-24: Phase 1 started on branch `phase-1/chromium-build`. Source comes from Google's
  "lite" tarball (1.87 GB, resumable, sha256-checked) via `scripts/fetch-source.sh`
  instead of `fetch` (git can't resume). depot_tools cloned shallow (13 MB).
  Only missing Fedora package: `gperf`.
- 2026-10-24: Name picked: **Kite** (backups: Tern, Glint). `gperf` installed.
- 2026-10-24: Source unpacked (11 GB). `scripts/sync-toolchain.sh` installed clang, Rust,
  Debian bullseye sysroot, Node.js v24. `gn gen out/Dev` OK (56,684 steps for `chrome`).
  Build NOT started locally: Jakub doesn't want to compile on his PC for now.
- 2026-10-24: Build moved to GitHub Actions (public repo github.com/jakub362/kite).
  `.github/workflows/build.yml` chains up to 5 parts of ~5 h each; each part saves the
  unfinished `out/Release` as an artifact and the next continues it. Settings: `flags/ci.gn`
  (standalone, no symbols). Result: `kite-linux-x64` artifact (made by `scripts/package.sh`).

## Errors & fixes
- Node.js unpack failed: `third_party/node/linux` doesn't exist in the tarball. Fix: `mkdir -p` first.
- depot_tools' `gn` wrapper wanted to bootstrap its own Python. Fix: call the tarball's
  `buildtools/linux64/gn` directly.
