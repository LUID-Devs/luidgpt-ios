#!/bin/bash

# Build script for LuidGPT iOS

echo "🔨 Building LuidGPT..."
echo ""

# Set scheme and project
SCHEME="LuidGPT"
PROJECT="LuidGPT/LuidGPT.xcodeproj"

# Check if project exists
if [ ! -d "$PROJECT" ]; then
    echo "❌ Error: $PROJECT not found"
    echo "Run ./setup-xcode.sh for instructions"
    exit 1
fi

# Build for simulator
cd LuidGPT
xcodebuild \
    -project "LuidGPT.xcodeproj" \
    -scheme "$SCHEME" \
    -sdk iphonesimulator \
    -configuration Debug \
    clean build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "App location:"
    find build -name "LuidGPT.app" 2>/dev/null
    echo ""
    echo "Next: Run ./run.sh to launch in simulator"
else
    echo ""
    echo "❌ Build failed"
    exit 1
fi
