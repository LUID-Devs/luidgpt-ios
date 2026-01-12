#!/bin/bash

# Run script for LuidGPT iOS

echo "📱 Running LuidGPT in Simulator..."
echo ""

# Find the built app in DerivedData
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "LuidGPT.app" 2>/dev/null | grep "Debug-iphonesimulator" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ App not found. Run ./build.sh first"
    exit 1
fi

echo "App found: $APP_PATH"
echo ""

# Get iPhone 15 simulator (or first available iPhone)
SIMULATOR_ID=$(xcrun simctl list devices available | grep "iPhone 15 " | head -1 | sed 's/.*(\(.*\)).*/\1/')

if [ -z "$SIMULATOR_ID" ]; then
    # Fallback to any iPhone
    SIMULATOR_ID=$(xcrun simctl list devices available | grep "iPhone" | head -1 | sed 's/.*(\(.*\)).*/\1/')
fi

echo "Using simulator: $SIMULATOR_ID"
echo ""

# Boot simulator if not running
echo "Booting simulator..."
xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || echo "Simulator already booted"

# Open Simulator app
open -a Simulator

# Wait for simulator to be ready
echo "Waiting for simulator..."
sleep 3

# Install app
echo "Installing app..."
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

# Get bundle ID
BUNDLE_ID="com.luidgpt.LuidGPT"

# Launch app
echo "Launching app..."
xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID"

echo ""
echo "✅ App launched!"
echo ""
echo "Simulator: $SIMULATOR_ID"
echo "Bundle ID: $BUNDLE_ID"
echo ""
echo "To view logs: ./logs.sh"
