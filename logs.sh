#!/bin/bash

# View app logs in real-time

echo "📋 Viewing LuidGPT logs..."
echo "Press Ctrl+C to stop"
echo ""

# Get bundle ID
BUNDLE_ID="com.luidgpt.LuidGPT"

# Get booted simulator
SIMULATOR_ID=$(xcrun simctl list devices | grep "Booted" | head -1 | sed 's/.*(\(.*\)).*/\1/')

if [ -z "$SIMULATOR_ID" ]; then
    echo "❌ No simulator is running"
    exit 1
fi

# Follow logs
xcrun simctl spawn "$SIMULATOR_ID" log stream --predicate "processImagePath contains \"LuidGPT\"" --level debug
