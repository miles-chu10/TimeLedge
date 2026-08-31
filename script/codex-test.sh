#!/usr/bin/env bash
set -euo pipefail

if ! /usr/bin/xcodebuild -version >/dev/null 2>&1; then
  printf 'TimeLedge tests require full Xcode; xcode-select currently points to %s\n' \
    "$(/usr/bin/xcode-select -p 2>/dev/null || printf 'no developer directory')" >&2
  exit 1
fi

exec /usr/bin/xcrun swift test --disable-sandbox
