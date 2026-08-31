#!/usr/bin/env bash
set -euo pipefail

TIMELEDGE_DISABLE_SWIFTPM_SANDBOX=0 exec \
  "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/build_and_run.sh" --build
