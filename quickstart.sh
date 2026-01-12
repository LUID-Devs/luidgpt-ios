#!/bin/bash

# QuickStart script for LuidGPT iOS

cat << "EOF"
╔═══════════════════════════════════════╗
║      LuidGPT iOS - Quick Start        ║
╚═══════════════════════════════════════╝
EOF

echo ""
echo "This will set up and run LuidGPT iOS app in 3 steps."
echo ""

# Step 1: Check Xcode project
if [ ! -d "LuidGPT.xcodeproj" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "STEP 1: Create Xcode Project (Required)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Opening Xcode to create project..."
    echo ""
    echo "In Xcode:"
    echo "  1. File → New → Project"
    echo "  2. Choose: iOS → App"
    echo "  3. Product Name: LuidGPT"
    echo "  4. Organization ID: com.luidgpt"
    echo "  5. Interface: SwiftUI"
    echo "  6. Language: Swift"
    echo "  7. Save location: $(pwd)"
    echo "     (Use the folder picker to select THIS folder)"
    echo "  8. IMPORTANT: Delete ContentView.swift"
    echo "  9. Right-click 'LuidGPT' → Add Files"
    echo "  10. Select all folders in LuidGPT/"
    echo "      (Core, Models, Views, ViewModels)"
    echo "  11. Uncheck 'Copy items if needed'"
    echo "  12. Click Add"
    echo ""
    read -p "Press Enter to open Xcode..."
    open -a Xcode
    echo ""
    echo "After setting up in Xcode, close it and run this script again."
    echo ""
    exit 0
fi

echo "✅ Xcode project found"
echo ""

# Step 2: Build
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Building App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./build.sh

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Build failed. Check errors above."
    exit 1
fi

# Step 3: Run
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: Launching Simulator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./run.sh

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║     🎉 Setup Complete!                ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "Commands:"
echo "  ./build.sh  - Rebuild app"
echo "  ./run.sh    - Launch app"
echo "  ./logs.sh   - View live logs"
echo ""
