#!/usr/bin/env bash
# Configures and builds Kite.
#   scripts/build.sh       dev build (flags/dev.gn) into chromium/src/out/Dev
#   scripts/build.sh ci    standalone build (flags/ci.gn) into chromium/src/out/Release
# Interrupting is safe: running this again continues where it stopped.
# BUILD_TIMEOUT (e.g. 4h) stops the build cleanly after that long; GitHub
# Actions uses it to build in parts.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${1:-dev}"
case "$CONFIG" in
  dev) OUT=out/Dev ;;
  ci) OUT=out/Release ;;
  *) echo "usage: $0 [dev|ci]" >&2; exit 2 ;;
esac
cd "$ROOT/chromium/src"

# Only copy the args when they changed: a new args.gn makes gn regenerate everything.
mkdir -p "$OUT"
if ! cmp -s "$ROOT/flags/$CONFIG.gn" "$OUT/args.gn"; then
  cp "$ROOT/flags/$CONFIG.gn" "$OUT/args.gn"
fi

# gn turns the BUILD.gn files + our args into ninja build files.
# (The tarball ships the real gn binary; depot_tools' wrapper would first
# bootstrap its own Python, which we don't need.)
buildtools/linux64/gn gen "$OUT"

limit=()
if [ -n "${BUILD_TIMEOUT:-}" ]; then
  limit=(timeout --signal=INT "$BUILD_TIMEOUT")
fi

# ninja compiles only what changed since the last build.
# nice -n 10 keeps the desktop responsive while all cores are busy.
time nice -n 10 "${limit[@]}" third_party/ninja/ninja -C "$OUT" chrome chrome_crashpad_handler chrome_sandbox
