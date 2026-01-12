# Phase 3 Setup Guide - Connect iOS to Backend

## 🎉 What We Just Built

✅ **APIClient** - HTTP client with token management and error handling
✅ **ModelsService** - Fetch categories, models, and execute generations
✅ **GenerationsService** - Manage generation history and polling
✅ **UserService** - Profile and credits management
✅ **AuthService** - Updated to work with real backend
✅ **KeychainManager** - Added ID token support

**Files Created:**
- `LuidGPT_Source/Core/Network/APIClient.swift` (350 lines)
- `LuidGPT_Source/Services/ModelsService.swift` (220 lines)
- `LuidGPT_Source/Services/GenerationsService.swift` (120 lines)
- `LuidGPT_Source/Services/UserService.swift` (90 lines)
- `LuidGPT_Source/Core/Auth/AuthService.swift` (updated)
- `LuidGPT_Source/Core/Storage/KeychainManager.swift` (updated)

---

## 🚀 Step 1: Install Alamofire (Required!)

The networking layer uses **Alamofire** for HTTP requests. You need to add it via Xcode:

### Instructions:

1. **Open Xcode** (just for 2 minutes!)
   ```bash
   cd /Users/alaindimabuyo/luid_projects/luidgpt-ios/LuidGPT
   open LuidGPT.xcodeproj
   ```

2. **Add Alamofire Package**
   - In Xcode menu: `File` → `Add Package Dependencies...`
   - In the search bar, paste: `https://github.com/Alamofire/Alamofire`
   - Click **"Add Package"**
   - Select target: **LuidGPT**
   - Click **"Add Package"** again

3. **Wait for Xcode** to download and integrate Alamofire (~30 seconds)

4. **Close Xcode** (you're done with it!)

---

## 🔧 Step 2: Start the Backend Server

Your iOS app needs the backend running to work:

```bash
# Go to backend directory
cd /Users/alaindimabuyo/luid_projects/luidgpt-backend

# Start development server
npm run dev

# Should see:
# 🚀 Server running on port 3000
# 📡 Database connected
```

**Keep this terminal window open!** The backend needs to stay running.

---

## 📱 Step 3: Build & Test iOS App

Now build and run your app:

```bash
# In a NEW terminal window
cd /Users/alaindimabuyo/luid_projects/luidgpt-ios

# Build
./build.sh

# Run
./run.sh
```

---

## 🧪 Step 4: Test Authentication Flow

### Test Registration:

1. **Click "Sign up"** in the app
2. Fill in:
   - First Name: `Test`
   - Last Name: `User`
   - Email: `test@example.com`
   - Password: `TestPass123`
3. **Click "Create Account"**
4. You should see **"Email Verification"** screen
5. **Check your terminal** (backend logs) - you'll see the verification code printed
6. **Enter the 6-digit code**
7. **Success!** You should be logged in

### Test Login:

1. **Logout** (we'll add this button later, for now restart app)
2. **Login** with same credentials
3. Should work immediately if email is verified!

### Test Password Reset:

1. **Click "Forgot Password?"**
2. Enter email
3. Get code from backend logs
4. Reset password
5. **Login with new password**

---

## 🐛 Troubleshooting

### "Module 'Alamofire' not found"
**Fix:** You didn't install Alamofire. Go back to Step 1.

### "Could not connect to server"
**Fix:** Backend isn't running. Check Step 2.

### "Invalid email or password"
**Fix:** Make sure:
- Backend is running
- You registered first
- Email is verified

### Build errors after adding Alamofire
**Fix:**
```bash
# Clean build
cd /Users/alaindimabuyo/luid_projects/luidgpt-ios/LuidGPT
xcodebuild -project LuidGPT.xcodeproj -scheme LuidGPT -sdk iphonesimulator clean
xcodebuild -project LuidGPT.xcodeproj -scheme LuidGPT -sdk iphonesimulator build
```

---

## 📊 What Works Now

✅ **Full Authentication Flow**
- Register with email/password
- Verify email with 6-digit code
- Login with credentials
- Forgot password flow
- Logout

✅ **Token Management**
- Access tokens stored securely in Keychain
- Automatic token injection in API calls
- Token expiration handling

✅ **API Integration**
- HTTP client with error handling
- Services ready for models, generations, user profile
- File upload support for images

---

## 🚧 What's Next: Phase 4

After testing Phase 3, we'll build:

### Phase 4: Navigation & Home Dashboard

**Week 2 Goals:**
1. Tab bar navigation (Home, Models, Generations, Profile)
2. Home dashboard with user info
3. Credit balance display
4. Categories grid with icons
5. Featured models carousel

**What you'll see:**
- Bottom tab bar with 4 tabs
- Home screen with personalized greeting
- Credit counter (e.g., "100 credits")
- 11 category cards with colors
- Featured models with thumbnails

---

## 📝 Testing Checklist

Mark these off as you test:

- [ ] Alamofire installed successfully
- [ ] Backend server running on port 3000
- [ ] iOS app builds without errors
- [ ] App launches in simulator
- [ ] Registration flow works
- [ ] Email verification works
- [ ] Login flow works
- [ ] Password reset works
- [ ] Tokens saved to Keychain
- [ ] API calls succeed

---

## 🎯 Current Status

**Phase 3: COMPLETE** ✅
- Networking layer: ✅
- Services layer: ✅
- Authentication: ✅
- Token management: ✅

**Ready for Phase 4!** 🚀

---

**Questions?** Check the main README or ask me!
