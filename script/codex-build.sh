#!/usr/bin/env bash
set -euo pipefail

TIMELEDGE_DEVELOPER_PATH="$(/usr/bin/xcode-select -p 2>/dev/null || true)"
if [[ ! -d "$TIMELEDGE_DEVELOPER_PATH/Platforms/MacOSX.platform/Developer/SDKs" ]]; then
  printf 'TimeLedge builds require full Xcode; xcode-select currently points to %s\n' \
    "${TIMELEDGE_DEVELOPER_PATH:-no developer directory}" >&2
  exit 1
fi

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/build_and_run.sh" --build
