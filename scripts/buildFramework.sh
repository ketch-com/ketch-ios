# Merge Script
 
# 1
# Set bash script to exit immediately if any commands fail.
set -e
 
# 2
# Setup some constants for use later on.
ROOT_FOLDER=$(pwd)
FRAMEWORK_NAME="Tender"
SRCROOT="${ROOT_FOLDER}/Tender"
BUILD_PATH="${SRCROOT}/build"
DESTINATION_PATH="${ROOT_FOLDER}/build"
 
# 3
# If remnants from a previous build exist, delete them.
if [ -d "${DESTINATION_PATH}" ]; then
rm -rf "${DESTINATION_PATH}"
fi
 
# 4
# Build the framework for device and for simulator (using
# all needed architectures).
cd "${SRCROOT}"
if [ -d "build" ]; then
rm -rf "build"
fi
# xcodebuild -workspace "${WORKSPACE_PATH}" -scheme "${TARGET_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 11' ONLY_ACTIVE_ARCH=NO ARCHS='x86_64' BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" ENABLE_BITCODE=YES OTHER_CFLAGS="-fembed-bitcode" BITCODE_GENERATION_MODE=bitcode clean build
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch arm64 only_active_arch=no defines_module=yes -sdk "iphoneos"
xcodebuild -target "${FRAMEWORK_NAME}" -configuration Release -arch x86_64 only_active_arch=no defines_module=yes -sdk "iphonesimulator"
cd "${ROOT_FOLDER}"
 
# 6
# Copy the device version of framework to Desktop.
cp -R "${SRCROOT}/build/Release-iphoneos" "${DESTINATION_PATH}/"


#7
# Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
SIMULATOR_SWIFT_MODULES_DIR="${SRCROOT}/build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${DESTINATION_PATH}/${FRAMEWORK_NAME}.framework/Modules/${FRAMEWORK_NAME}.swiftmodule"
fi
 
# 8
# Replace the framework executable within the framework with
# a new version created by merging the device and simulator
# frameworks' executables with lipo.
lipo -create -output "${DESTINATION_PATH}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "${SRCROOT}/build/Release-iphoneos/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "${SRCROOT}/build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
 
# 9
# Delete the most recent build.
if [ -d "${SRCROOT}/build" ]; then
rm -rf "${SRCROOT}/build"
fi
