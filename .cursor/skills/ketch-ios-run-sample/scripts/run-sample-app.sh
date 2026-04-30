#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: run-sample-app.sh [local] [--build-only] [--no-unified-logs] [--full-system-logs]

  (no first argument)  Use the released KetchSDK Swift package from GitHub: pins the highest
                        X.Y.Z tag from git ls-remote (not CocoaPods). Override with KETCH_IOS_SPM_VERSION
                        or track a branch with KETCH_IOS_SPM_BRANCH.
  local                Point the sample Xcode project at this repo checkout (../..) and build.

Environment:
  SIMULATOR_NAME        Preferred simulator name when none is booted. Default: iPhone 15 Pro
  DEVICE_ID             Specific simulator UUID to use.
  CONFIGURATION         Xcode build configuration. Default: Debug
  DERIVED_DATA_PATH     Derived data output path. Default: Examples/KetchSDKSample/build
  KETCH_IOS_SPM_REPO_URL
                        Git URL for the remote package (default: https://github.com/ketch-com/ketch-ios.git).
  KETCH_IOS_SPM_VERSION or KETCH_IOS_SPM_EXACT_VERSION
                        Pin remote dependency to this exact semver (no git tag discovery).
  KETCH_IOS_SPM_BRANCH  Track this branch instead of latest tag (e.g. main).

The default run configures the sample for the remote package (if needed), builds, installs,
streams unified logs for Ketch SDK messages only (subsystem com.ketch.sdk), then launches with
--console-pty so print/stdout/stderr appear in this terminal.

Use --full-system-logs to stream all unified logs for the app process (noisy).
USAGE
}

PACKAGE_MODE="remote"
if [[ "${1:-}" == "local" ]]; then
  PACKAGE_MODE="local"
  shift
fi

build_only=0
stream_unified_logs=1
full_system_logs=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-only)
      build_only=1
      shift
      ;;
    --no-unified-logs)
      stream_unified_logs=0
      shift
      ;;
    --full-system-logs)
      full_system_logs=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command not found: $1" >&2
    exit 1
  fi
}

require_command xcrun
require_command xcodebuild
require_command python3
require_command git

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SAMPLE_DIR="$REPO_ROOT/Examples/KetchSDKSample"
PROJECT_PATH="$SAMPLE_DIR/KetchSDK.xcodeproj"
PBXPROJ="$PROJECT_PATH/project.pbxproj"
SCHEME="KetchSDK-Example"
CONFIGURATION="${CONFIGURATION:-Debug}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$SAMPLE_DIR/build}"
BUNDLE_ID="com.ketch.iOS-SwiftUI-Example"
APP_PROCESS_NAME="KetchSDK_Example"
KETCH_LOG_SUBSYSTEM="com.ketch.sdk"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 15 Pro}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Sample project not found: $PROJECT_PATH" >&2
  exit 1
fi

python3 "$SCRIPT_DIR/configure-sample-package.py" "$PACKAGE_MODE" "$PBXPROJ" "$REPO_ROOT"

booted_device_id() {
  python3 <<'PY'
import json
import subprocess

data = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "booted", "--json"]))
for devices in data.get("devices", {}).values():
    for device in devices:
        if device.get("state") == "Booted" and device.get("isAvailable", True):
            print(device["udid"])
            raise SystemExit(0)
PY
}

select_available_device_id() {
  python3 - "$SIMULATOR_NAME" <<'PY'
import json
import subprocess
import sys

preferred_name = sys.argv[1]
data = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "--json"]))

exact_matches = []
iphone_matches = []

for runtime, devices in data.get("devices", {}).items():
    if "iOS" not in runtime:
        continue

    for device in devices:
        if not device.get("isAvailable", True):
            continue

        name = device.get("name", "")
        if name == preferred_name:
            exact_matches.append(device["udid"])
        elif "iPhone" in name:
            iphone_matches.append(device["udid"])

if exact_matches:
    print(exact_matches[-1])
elif iphone_matches:
    print(iphone_matches[-1])
else:
    raise SystemExit("No available iOS simulator devices found.")
PY
}

requested_device_id="${DEVICE_ID:-}"
current_booted_device_id="$(booted_device_id)"

device_is_booted() {
  xcrun simctl list devices booted | grep -Fq "$1"
}

boot_device_if_needed() {
  local device_id="$1"

  if device_is_booted "$device_id"; then
    echo "Using simulator: $device_id"
    return
  fi

  echo "Booting simulator: $device_id"
  xcrun simctl boot "$device_id"
  open -a Simulator
  xcrun simctl bootstatus "$device_id" -b
}

if [[ -n "$requested_device_id" ]]; then
  DEVICE_ID="$requested_device_id"
  boot_device_if_needed "$DEVICE_ID"
elif [[ -n "$current_booted_device_id" ]]; then
  DEVICE_ID="$current_booted_device_id"
  echo "Using simulator: $DEVICE_ID"
else
  DEVICE_ID="$(select_available_device_id)"
  echo "No booted simulator found. Booting $SIMULATOR_NAME or nearest available iPhone: $DEVICE_ID"
  boot_device_if_needed "$DEVICE_ID"
fi

if [[ "$PACKAGE_MODE" == "local" ]]; then
  echo "Building $SCHEME using local KetchSDK at $REPO_ROOT"
else
  echo "Building $SCHEME using remote KetchSDK from ${KETCH_IOS_SPM_REPO_URL:-https://github.com/ketch-com/ketch-ios.git} (latest tag, KETCH_IOS_SPM_VERSION, or KETCH_IOS_SPM_BRANCH)"
fi

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "platform=iOS Simulator,id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build

APP_PATH="$DERIVED_DATA_PATH/Build/Products/${CONFIGURATION}-iphonesimulator/KetchSDK_Example.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Built app not found: $APP_PATH" >&2
  exit 1
fi

echo "Installing $APP_PATH"
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install "$DEVICE_ID" "$APP_PATH"

if [[ "$build_only" -eq 1 ]]; then
  echo "Build/install complete. Skipping launch because --build-only was provided."
  exit 0
fi

log_stream_pid=""
cleanup() {
  if [[ -n "$log_stream_pid" ]] && kill -0 "$log_stream_pid" >/dev/null 2>&1; then
    kill "$log_stream_pid" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT INT TERM

open -a Simulator

if [[ "$stream_unified_logs" -eq 1 ]]; then
  if [[ "$full_system_logs" -eq 1 ]]; then
    log_predicate="process == \"$APP_PROCESS_NAME\""
    echo "Streaming unified logs for process == \"$APP_PROCESS_NAME\" (full system logs)"
  else
    log_predicate="process == \"$APP_PROCESS_NAME\" AND subsystem == \"$KETCH_LOG_SUBSYSTEM\""
    echo "Streaming unified logs for subsystem == \"$KETCH_LOG_SUBSYSTEM\" (Ketch SDK only)"
  fi
  xcrun simctl spawn "$DEVICE_ID" log stream \
    --level debug \
    --style compact \
    --predicate "$log_predicate" &
  log_stream_pid="$!"
fi

echo "Launching $BUNDLE_ID with console output attached. Press Ctrl-C to stop."
xcrun simctl launch \
  --terminate-running-process \
  --console-pty \
  "$DEVICE_ID" \
  "$BUNDLE_ID"
