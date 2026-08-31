#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT_DIR/Assets/AppIcon/TimeLedge-1024.png"
OUTPUT="$ROOT_DIR/Resources/TimeLedge.icns"
ICONSET_DIR="$(mktemp -d /private/tmp/timeledge-iconset.XXXXXX)/TimeLedge.iconset"

cleanup() {
  rm -rf "$(dirname "$ICONSET_DIR")"
}
trap cleanup EXIT

test -f "$SOURCE"
mkdir -p "$ICONSET_DIR" "$(dirname "$OUTPUT")"

make_icon() {
  local points="$1"
  local pixels="$2"
  local suffix="$3"
  /usr/bin/sips -z "$pixels" "$pixels" "$SOURCE" \
    --out "$ICONSET_DIR/icon_${points}x${points}${suffix}.png" >/dev/null
}

make_icon 16 16 ""
make_icon 16 32 "@2x"
make_icon 32 32 ""
make_icon 32 64 "@2x"
make_icon 128 128 ""
make_icon 128 256 "@2x"
make_icon 256 256 ""
make_icon 256 512 "@2x"
make_icon 512 512 ""
make_icon 512 1024 "@2x"

/usr/bin/iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT"
/usr/bin/sips -g pixelWidth -g pixelHeight "$SOURCE" >/dev/null
printf 'Generated %s\n' "$OUTPUT"
