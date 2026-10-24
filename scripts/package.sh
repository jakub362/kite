#!/usr/bin/env bash
# Packs the runnable browser from out/Release into dist/kite-<version>-linux-x64.tar.xz.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/chromium_version.txt")"
OUT="$ROOT/chromium/src/out/Release"
NAME="kite-$VERSION-linux-x64"
STAGE="$(mktemp -d)"

mkdir -p "$STAGE/$NAME" "$ROOT/dist"
cd "$OUT"

# Only what the browser needs at runtime; obj/ and gen/ are build leftovers.
cp -a chrome chrome_crashpad_handler chrome_sandbox ./*.pak ./*.bin icudtl.dat locales "$STAGE/$NAME/"
# GPU libraries (ANGLE, SwiftShader software rendering, Vulkan loader).
cp -a ./lib*.so* ./*.json "$STAGE/$NAME/" 2>/dev/null || true
for d in MEIPreload PrivacySandboxAttestationsPreloaded; do
  if [ -d "$d" ]; then cp -a "$d" "$STAGE/$NAME/"; fi
done

tar -C "$STAGE" -I 'xz -T0' -cf "$ROOT/dist/$NAME.tar.xz" "$NAME"
rm -rf "$STAGE"
ls -lh "$ROOT/dist/$NAME.tar.xz"
