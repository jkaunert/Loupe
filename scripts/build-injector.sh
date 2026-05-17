#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-Release}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/.build/loupe-injector}"

cd "$ROOT_DIR"

xcodebuild \
  -scheme LoupeInjector \
  -destination 'generic/platform=iOS Simulator' \
  -configuration "$CONFIGURATION" \
  CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
  build

INJECTOR="$BUILD_DIR/PackageFrameworks/LoupeInjector.framework/LoupeInjector"

if [[ ! -x "$INJECTOR" ]]; then
  echo "LoupeInjector was not produced at $INJECTOR" >&2
  exit 1
fi

echo "$INJECTOR"
