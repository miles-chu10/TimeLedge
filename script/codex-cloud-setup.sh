#!/usr/bin/env bash
set -euo pipefail

swift --version
swift package dump-package >/dev/null
swift package resolve

printf '%s\n' \
  'Codex Cloud setup complete.' \
  'Native AppKit build and test checks require macOS CI or a local Mac with Xcode.'
