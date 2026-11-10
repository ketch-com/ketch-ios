#!/bin/bash
# Ketch iOS SDK Integration Tests Runner
# This script generates and runs the integration tests for the Ketch iOS SDK.

# Exit immediately if a command exits with a non-zero status
set -e

# Change to the integration-tests directory (where this script is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "Error: xcodegen is not installed or not in PATH."
    echo "Please install it with: brew install xcodegen"
    echo "Or visit: https://github.com/yonaskolb/XcodeGen"
    exit 1
fi

echo "=== Generating Xcode project ==="
xcodegen generate

# Check if the project was generated successfully
if [ ! -d "KetchIntegrationTests.xcodeproj" ]; then
    echo "Error: Failed to generate Xcode project."
    exit 1
fi

echo "=== Running integration tests ==="
# Dynamically pick a simulator that exists
PREFERRED_DEVICES=(
  "iPhone 16"
  "iPhone 16 Pro"
  "iPhone 16 Pro Max"
  "iPhone 16 Plus"
  "iPhone 16e"
  "iPhone 15"
  "iPhone 15 Pro"
  "iPhone 15 Pro Max"
  "iPhone 15 Plus"
  "iPhone SE (3rd generation)"
)

# Fetch list of available devices once
AVAILABLE_DEVICES="$(xcrun simctl list devices available | awk -F '[()]' '{print $1}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

SELECTED_DEVICE=""
for device in "${PREFERRED_DEVICES[@]}"; do
    if echo "$AVAILABLE_DEVICES" | grep -q "^${device}$"; then
        SELECTED_DEVICE="$device"
        break
    fi
done

if [ -z "$SELECTED_DEVICE" ]; then
    echo "No preferred simulator found. Falling back to 'Any iOS Simulator Device'."
    DESTINATION="platform=iOS Simulator,name=Any iOS Simulator Device"
else
    echo "Using simulator: $SELECTED_DEVICE"
    DESTINATION="platform=iOS Simulator,name=$SELECTED_DEVICE"
fi

# Run the tests and pipe to xcpretty if available
if command -v xcpretty &> /dev/null; then
    xcodebuild \
      -project KetchIntegrationTests.xcodeproj \
      -scheme KetchIntegrationTestsApp \
      -destination "$DESTINATION" \
      test | xcpretty
    
    # Capture the exit code from xcodebuild (not xcpretty)
    TEST_RESULT=${PIPESTATUS[0]}
else
    xcodebuild \
      -project KetchIntegrationTests.xcodeproj \
      -scheme KetchIntegrationTestsApp \
      -destination "$DESTINATION" \
      test
    
    TEST_RESULT=$?
fi

# Check if tests passed
if [ $TEST_RESULT -eq 0 ]; then
    echo "=== Integration tests completed successfully ==="
    exit 0
else
    echo "=== Integration tests failed with exit code $TEST_RESULT ==="
    exit $TEST_RESULT
fi
