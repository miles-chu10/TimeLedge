#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="TimeLedge"
BUNDLE_ID="com.mileschu.TimeLedge"
MIN_SYSTEM_VERSION="13.0"
VERSION="0.1.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
ICON_FILE="$ROOT_DIR/Resources/TimeLedge.icns"
PRIVACY_FILE="$ROOT_DIR/Resources/PrivacyInfo.xcprivacy"
MODULE_CACHE="$ROOT_DIR/.build/codex-module-cache"
SWIFT=(/usr/bin/xcrun swift)

if ! /usr/bin/xcodebuild -version >/dev/null 2>&1; then
  printf 'TimeLedge requires full Xcode; xcode-select currently points to %s\n' \
    "$(/usr/bin/xcode-select -p 2>/dev/null || printf 'no developer directory')" >&2
  exit 1
fi

mkdir -p "$MODULE_CACHE"
export CLANG_MODULE_CACHE_PATH="$MODULE_CACHE"
export SWIFTPM_MODULECACHE_OVERRIDE="$MODULE_CACHE"

/usr/bin/pkill -x "$APP_NAME" >/dev/null 2>&1 || true

SWIFT_BUILD_ARGS=(build --product "$APP_NAME")
if [[ "${TIMELEDGE_DISABLE_SWIFTPM_SANDBOX:-1}" == "1" ]]; then
  SWIFT_BUILD_ARGS+=(--disable-sandbox)
fi

"${SWIFT[@]}" "${SWIFT_BUILD_ARGS[@]}"
BUILD_BINARY="$("${SWIFT[@]}" build --show-bin-path)/$APP_NAME"

test -f "$ICON_FILE"
test -f "$PRIVACY_FILE"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
cp "$ICON_FILE" "$APP_RESOURCES/TimeLedge.icns"
cp "$PRIVACY_FILE" "$APP_RESOURCES/PrivacyInfo.xcprivacy"
chmod +x "$APP_BINARY"

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleIconFile</key>
  <string>TimeLedge.icns</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.utilities</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSHumanReadableCopyright</key>
  <string>Copyright © 2026 TimeLedge contributors</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

/usr/bin/plutil -lint "$INFO_PLIST" >/dev/null
/usr/bin/codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
  run)
    open_app
    ;;
  --build|build)
    printf 'Built %s\n' "$APP_BUNDLE"
    ;;
  --debug|debug)
    /usr/bin/lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --verify|verify)
    open_app
    sleep 2
    /usr/bin/pgrep -x "$APP_NAME" >/dev/null
    printf 'Verified running process: %s\n' "$APP_NAME"
    ;;
  --settings|settings)
    /usr/bin/open -n "$APP_BUNDLE" --args --show-settings
    ;;
  *)
    printf 'usage: %s [run|--build|--debug|--logs|--verify|--settings]\n' "$0" >&2
    exit 2
    ;;
esac
