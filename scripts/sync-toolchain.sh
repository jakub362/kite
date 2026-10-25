#!/usr/bin/env bash
# Downloads the compilers and tools Chromium builds with. The source tarball
# leaves these out; a normal git checkout gets them from `gclient runhooks`.
# Safe to re-run: each step skips what's already there.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/chromium/src"

# Chromium only builds with its own pinned clang, not the system one.
echo "== clang"
python3 tools/clang/scripts/update.py

echo "== rust"
python3 tools/rust/update_rust.py

# A sysroot is a small bundle of Debian system libraries + headers. Building
# against it instead of Fedora's libraries makes the result run on any distro.
echo "== sysroot"
python3 build/linux/sysroot_scripts/install-sysroot.py --arch=amd64

# Node.js runs the TypeScript/WebUI build steps. DEPS lists the exact file.
echo "== node"
if [ ! -x third_party/node/linux/node-linux-x64/bin/node ]; then
  block="$(sed -n "/'src\/third_party\/node\/linux'/,/output_file/p" DEPS)"
  obj="$(grep -oP "'object_name': '\K[0-9a-f]+" <<<"$block")"
  sha="$(grep -oP "'sha256sum': '\K[0-9a-f]+" <<<"$block")"
  dl="$ROOT/downloads/node-linux-x64-$obj.tar.gz"
  curl -fL -C - --retry 20 --retry-all-errors -o "$dl" "https://storage.googleapis.com/chromium-nodejs/$obj"
  echo "$sha  $dl" | sha256sum -c -
  mkdir -p third_party/node/linux
  tar -xzf "$dl" -C third_party/node/linux
fi
third_party/node/linux/node-linux-x64/bin/node --version

# Go runs Dawn's (WebGPU) code generator during the build. It's listed in
# Dawn's own DEPS as a CIPD package (Google's package store); depot_tools'
# `cipd` client fetches it at the exact pinned version.
echo "== go"
GO_DIR=third_party/dawn/tools/golang/linux-amd64
if [ ! -x "$GO_DIR/bin/go" ]; then
  go_version="$(grep -oP "'dawn_go_version': '\K[^']+" third_party/dawn/DEPS)"
  "$ROOT/depot_tools/cipd" install infra/3pp/tools/go/linux-amd64 "$go_version" -root "$GO_DIR"
fi
"$GO_DIR/bin/go" version

echo "== Toolchain ready"
