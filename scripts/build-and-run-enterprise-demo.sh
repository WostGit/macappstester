#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-enterprise}"
LEVEL="${2:-1}"
ACTION="${3:-run}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT_DIR/apps/EnterpriseDemoApp.swift"
BUILD_DIR="$ROOT_DIR/build"
APP="$BUILD_DIR/EnterpriseDemoApp-Level${LEVEL}.app"
BIN="$APP/Contents/MacOS/EnterpriseDemoApp"

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun not found. Install Xcode or Xcode Command Line Tools first."
  exit 1
fi

mkdir -p "$APP/Contents/MacOS"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>EnterpriseDemoApp</string>
  <key>CFBundleIdentifier</key>
  <string>com.wostgit.macappstester.enterprise-demo.level${LEVEL}</string>
  <key>CFBundleName</key>
  <string>EnterpriseDemoApp-Level${LEVEL}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

xcrun swiftc "$SRC" -framework AppKit -O -o "$BIN"

echo "Built: $APP"

case "$ACTION" in
  build)
    exit 0
    ;;
  run)
    echo "Running mode=$MODE level=$LEVEL"
    DEMO_MODE="$MODE" DEMO_LEVEL="$LEVEL" open -n "$APP"
    ;;
  run-wait)
    echo "Running and waiting mode=$MODE level=$LEVEL"
    DEMO_MODE="$MODE" DEMO_LEVEL="$LEVEL" open -W -n "$APP"
    ;;
  screenshot)
    OUT="$BUILD_DIR/enterprise-demo-level${LEVEL}-${MODE}.png"
    echo "Running, waiting 4 seconds, then screenshotting to: $OUT"
    DEMO_MODE="$MODE" DEMO_LEVEL="$LEVEL" open -n "$APP"
    sleep 4
    screencapture -x "$OUT"
    echo "Screenshot: $OUT"
    ;;
  *)
    echo "Usage: $0 [enterprise|metrics] [level 1-5] [build|run|run-wait|screenshot]"
    exit 2
    ;;
esac
