# LuidGPT iOS - Terminal Guide

Complete guide to building and running LuidGPT iOS app from the terminal.

## Quick Start (Easiest)

```bash
cd /Users/alaindimabuyo/luid_projects/luidgpt-ios
./quickstart.sh
```

This will guide you through all steps automatically!

---

## Manual Steps

### 1. Create Xcode Project (One-Time Setup)

Unfortunately, Apple doesn't provide a CLI to create `.xcodeproj` files. You need to use Xcode GUI **once** (takes 2 minutes):

```bash
# Open Xcode
open -a Xcode
```

**In Xcode:**
1. File → New → Project
2. Choose: **iOS → App**
3. Settings:
   - Product Name: `LuidGPT`
   - Team: None (or your team)
   - Organization Identifier: `com.luidgpt`
   - Interface: **SwiftUI**
   - Language: **Swift**
4. **Important:** Save to `/Users/alaindimabuyo/luid_projects/luidgpt-ios`
   - This is the PARENT folder (use folder picker to select it)
   - Xcode will create `LuidGPT.xcodeproj` here
5. **Delete the default `ContentView.swift`** file
6. Right-click on `LuidGPT` folder → **Add Files to "LuidGPT"...**
7. Select all these folders:
   - `Core/`
   - `Models/`
   - `Views/`
   - `ViewModels/`
8. **IMPORTANT:** Uncheck "Copy items if needed"
9. Click **Add**
10. Close Xcode (or keep it open for later)

### 2. Build from Terminal

```bash
./build.sh
```

This will:
- Clean previous builds
- Compile all Swift files
- Create `LuidGPT.app` for iOS Simulator
- Show build progress and errors

### 3. Run in Simulator

```bash
./run.sh
```

This will:
- Boot iPhone 15 simulator (or any available)
- Install the app
- Launch the app
- Open Simulator window

### 4. View Live Logs

```bash
./logs.sh
```

Press `Ctrl+C` to stop viewing logs.

---

## Alternative: Full Terminal Commands

If you prefer raw commands instead of scripts:

### Build

```bash
xcodebuild \
    -project LuidGPT.xcodeproj \
    -scheme LuidGPT \
    -sdk iphonesimulator \
    -configuration Debug \
    clean build
```

### List Simulators

```bash
xcrun simctl list devices available | grep iPhone
```

### Boot Simulator

```bash
# Get first iPhone 15 simulator ID
SIMULATOR_ID=$(xcrun simctl list devices | grep "iPhone 15 " | head -1 | sed 's/.*(\(.*\)).*/\1/')

# Boot it
xcrun simctl boot $SIMULATOR_ID

# Open Simulator app
open -a Simulator
```

### Install App

```bash
# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "LuidGPT.app" | head -1)

# Install on simulator
xcrun simctl install $SIMULATOR_ID "$APP_PATH"
```

### Launch App

```bash
xcrun simctl launch $SIMULATOR_ID com.luidgpt.LuidGPT
```

---

## Troubleshooting

### "Project not found"
- You need to create the Xcode project first (see Step 1)
- Make sure you're in the correct directory: `cd /Users/alaindimabuyo/luid_projects/luidgpt-ios`

### Build errors about missing files
- Make sure you added all Swift files to the Xcode project
- In Xcode: right-click `LuidGPT` → Add Files → select all folders
- **Uncheck** "Copy items if needed"

### "No such module 'SwiftUI'"
- Make sure you selected **iOS** (not macOS) when creating the project
- Check Deployment Target is iOS 16.0 or later

### Simulator won't launch
```bash
# Kill all simulators
killall Simulator

# Try again
./run.sh
```

### App crashes on launch
```bash
# View crash logs
./logs.sh
```

---

## Available Scripts

- `./quickstart.sh` - Interactive setup wizard (recommended for first time)
- `./setup-xcode.sh` - Check if Xcode project is set up correctly
- `./build.sh` - Build the app
- `./run.sh` - Launch app in simulator
- `./logs.sh` - View live app logs

---

## Working with Cursor

You can still edit code in Cursor while building from terminal:

1. **Open in Cursor:**
   ```bash
   cursor .
   ```

2. **Edit Swift files in Cursor** (use AI, make changes)

3. **Build from terminal:**
   ```bash
   ./build.sh && ./run.sh
   ```

This gives you the best of both worlds!

---

## Next Steps After Running

Once the app is running, you'll see:
- ✅ Splash screen with gradient logo
- ✅ Login screen (since no user is logged in)
- ✅ Beautiful auth UI with dark theme

**To test:**
1. Click "Sign up" to see registration screen
2. Fill in test data
3. Try password strength indicator
4. Test validation and error states

**Note:** The app won't fully work yet because:
- Backend API is not connected (localhost:3000)
- Need to start your backend server
- Need to add SPM dependencies (optional for now)

---

## Advanced: Building for Real Device

```bash
# 1. Connect iPhone via USB
# 2. Build for device
xcodebuild \
    -project LuidGPT.xcodeproj \
    -scheme LuidGPT \
    -sdk iphoneos \
    -configuration Debug \
    CODE_SIGN_IDENTITY="iPhone Developer" \
    build

# 3. Install (requires Xcode)
# Easier to use Xcode GUI for device deployment
```

---

**Questions?** Check `README.md` or `PROGRESS.md` for more info!
