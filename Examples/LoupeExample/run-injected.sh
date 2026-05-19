#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
DEVICE="${LOUPE_DEVICE:-booted}"
PORT="${LOUPE_PORT:-}"

cd "$ROOT_DIR"

if ! xcrun simctl list devices booted | grep -q Booted; then
  FIRST_DEVICE="$(xcrun simctl list devices available | awk -F '[()]' '/iPhone/ { print $2; exit }')"
  xcrun simctl boot "$FIRST_DEVICE"
  DEVICE="booted"
fi

swift build

xcodebuild \
  -scheme LoupeInjector \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  build >/tmp/loupe-injector-build.log

xcodebuild \
  -project Examples/LoupeExample/LoupeExample.xcodeproj \
  -scheme LoupeExample \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  build >/tmp/loupe-example-build.log

export LOUPE_INJECTOR_PATH="$(
  find "$HOME/Library/Developer/Xcode/DerivedData" \
    -path '*Debug-iphonesimulator/PackageFrameworks/LoupeInjector.framework/LoupeInjector' \
    -print0 | xargs -0 ls -t | head -1
)"

APP_PATH="$(
  find "$HOME/Library/Developer/Xcode/DerivedData" \
    -path '*Debug-iphonesimulator/LoupeExample.app' \
    -print0 | xargs -0 ls -td | head -1
)"

xcrun simctl install "$DEVICE" "$APP_PATH"
xcrun simctl terminate "$DEVICE" dev.loupe.example >/dev/null 2>&1 || true

LAUNCH_ARGUMENTS=(
  --device "$DEVICE"
  --bundle-id dev.loupe.example
  --inject
)
if [[ -n "$PORT" ]]; then
  LAUNCH_ARGUMENTS+=(--env "LOUPE_PORT=$PORT")
fi
LAUNCH_OUTPUT="$(.build/debug/loupe launch "${LAUNCH_ARGUMENTS[@]}")"
HOST="$(awk '/^loupe host: / { print $3 }' <<<"$LAUNCH_OUTPUT" | tail -1)"
if [[ -z "$HOST" ]]; then
  echo "error: loupe launch did not report a runtime host" >&2
  echo "$LAUNCH_OUTPUT" >&2
  exit 1
fi

sleep 2

curl -sS "$HOST/health"
echo

SNAPSHOT_PATH="/tmp/loupe-example-snapshot.json"
LOGS_PATH="/tmp/loupe-example-logs.json"
INSPECT_PATH="/tmp/loupe-example-inspect.json"
curl -sS "$HOST/snapshot" > "$SNAPSHOT_PATH"
curl -sS "$HOST/logs" > "$LOGS_PATH"

.build/debug/loupe query "$SNAPSHOT_PATH" --test-id example.customerList
.build/debug/loupe inspect "$SNAPSHOT_PATH" --test-id example.customerList > "$INSPECT_PATH"
grep -q '"example_customers_visible"' "$LOGS_PATH"
grep -q '"screen"' "$INSPECT_PATH"
grep -q '"customers"' "$INSPECT_PATH"
