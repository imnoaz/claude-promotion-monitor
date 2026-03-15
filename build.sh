#!/bin/bash
set -e

APP_NAME="Claude Promotion Monitor"
BUNDLE_ID="com.imnoaz.claude-promotion-monitor"
BUILD_DIR=".build"
APP_DIR="${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"

echo "=== Building ClaudePromotionMonitor ==="

swift build -c release 2>&1

echo "=== Creating app bundle ==="

rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${CONTENTS_DIR}/Resources"

cp "${BUILD_DIR}/release/ClaudePromotionMonitor" "${MACOS_DIR}/ClaudePromotionMonitor"
cp Info.plist "${CONTENTS_DIR}/Info.plist"

# Ad-hoc code sign
codesign --force --sign - "${APP_DIR}" 2>/dev/null || true

echo "=== Done ==="
echo "App bundle created: ${APP_DIR}"
echo ""
echo "To run:  open \"${APP_DIR}\""
echo "To install: cp -r \"${APP_DIR}\" /Applications/"
