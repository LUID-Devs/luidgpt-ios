#!/bin/bash

# LuidGPT iOS - Xcode Project Setup Script
# This script helps set up the Xcode project from terminal

echo "🚀 LuidGPT iOS Setup"
echo "===================="
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "Please install Xcode from the App Store"
    exit 1
fi

echo "✅ Xcode is installed"

# Check if project exists
if [ ! -f "LuidGPT.xcodeproj/project.pbxproj" ]; then
    echo ""
    echo "⚠️  Xcode project not found!"
    echo ""
    echo "You need to create the Xcode project first:"
    echo "1. Open Xcode: open -a Xcode"
    echo "2. File → New → Project"
    echo "3. Choose: iOS → App"
    echo "4. Product Name: LuidGPT"
    echo "5. Organization Identifier: com.luidgpt"
    echo "6. Interface: SwiftUI"
    echo "7. Save to: $(pwd)"
    echo "8. Delete the default ContentView.swift"
    echo "9. Add all Swift files from LuidGPT folder"
    echo ""
    echo "After creating the project, run this script again."
    exit 1
fi

echo "✅ Xcode project found"
echo ""

# List available simulators
echo "📱 Available Simulators:"
xcrun simctl list devices available | grep "iPhone" | head -5

echo ""
echo "🎯 Next Steps:"
echo "1. Build: ./build.sh"
echo "2. Run: ./run.sh"
echo ""
