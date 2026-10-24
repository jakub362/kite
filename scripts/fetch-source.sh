#!/usr/bin/env bash
# Downloads the pinned Chromium source tarball and unpacks it into chromium/src.
# Safe to re-run: an interrupted download resumes where it stopped, and
# finished steps are skipped.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/chromium_version.txt")"
NAME="chromium-$VERSION-lite.tar.xz"
URL="https://commondatastorage.googleapis.com/chromium-browser-official/$NAME"
DL="$ROOT/downloads"
SRC="$ROOT/chromium/src"

mkdir -p "$DL" "$ROOT/chromium"

# depot_tools: Google's helper scripts (gclient, gn wrapper, autoninja, siso).
# --depth=1 skips the git history, which we never need.
if [ ! -d "$ROOT/depot_tools" ]; then
  echo "== Cloning depot_tools (shallow)"
  git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git "$ROOT/depot_tools"
fi

if [ -d "$SRC" ]; then
  echo "== $SRC already exists, nothing to do"
  exit 0
fi

# -C - continues a partial file; --retry keeps going through dropped connections.
echo "== Downloading $NAME"
curl -fL -C - --retry 50 --retry-all-errors --retry-delay 15 -o "$DL/$NAME" "$URL"
curl -fsSL --retry 5 -o "$DL/$NAME.hashes" "$URL.hashes"

# Make sure the file is exactly what Google published before we unpack it.
echo "== Verifying sha256"
expected="$(awk '$1 == "sha256" { print $2 }' "$DL/$NAME.hashes")"
echo "$expected  $DL/$NAME" | sha256sum -c -

# xz -T0 decompresses on all CPU cores.
echo "== Unpacking (a few minutes)"
tar -I 'xz -T0 -d' -xf "$DL/$NAME" -C "$ROOT/chromium"
mv "$ROOT/chromium/chromium-$VERSION" "$SRC"

echo "== Done: $SRC"
du -sh "$SRC"
