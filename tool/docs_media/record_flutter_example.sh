#!/bin/bash
# Records `example_flutter` on an iOS simulator and turns it into the README
# GIF (assets/example.gif) and still (assets/example.png).
#
# Usage: ./tool/docs_media/record_flutter_example.sh [simulator-udid]
# Needs: Xcode with a booted iOS simulator, Flutter, python3 with Pillow.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
UDID="${1:-$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -1)}"
if [ -z "$UDID" ]; then
  echo "No booted simulator found. Boot one or pass its UDID." >&2
  exit 1
fi

WORK="$(mktemp -d)"
FRAMES="$WORK/frames"
LOG="$WORK/flutter_test.log"
mkdir -p "$FRAMES"

xcrun simctl status_bar "$UDID" override --time 9:41 --batteryState charged \
  --batteryLevel 100 --wifiBars 3 --cellularBars 4

cd "$ROOT/example_flutter"
flutter test integration_test/docs_media_test.dart -d "$UDID" >"$LOG" 2>&1 &
TEST_PID=$!

until grep -q DOCS_MEDIA_START "$LOG"; do
  if ! kill -0 "$TEST_PID" 2>/dev/null; then
    cat "$LOG"
    exit 1
  fi
  sleep 0.2
done
python3 "$ROOT/tool/docs_media/simulator_gif.py" capture "$UDID" "$FRAMES" &
CAPTURE_PID=$!

until grep -q DOCS_MEDIA_END "$LOG"; do
  if ! kill -0 "$TEST_PID" 2>/dev/null; then
    break
  fi
  sleep 0.2
done
touch "$FRAMES/stop"
wait "$CAPTURE_PID"
wait "$TEST_PID" || { cat "$LOG"; exit 1; }

xcrun simctl status_bar "$UDID" clear
python3 "$ROOT/tool/docs_media/simulator_gif.py" build "$FRAMES" \
  "$ROOT/assets/example.gif" "$ROOT/assets/example.png"
rm -rf "$WORK"
