# LuidGPT iOS - Native Mobile App

Native iOS application for LuidGPT's AI model platform built with SwiftUI, providing access to 100+ AI models across 11 categories including video generation, image generation, text generation, and more.

## Project Overview

- **Platform:** iOS 16.0+
- **Language:** Swift 5.9+
- **Architecture:** MVVM + Combine
- **UI Framework:** SwiftUI
- **Backend API:** luidgpt-backend (Node.js/Express)

## Features

- ✅ Dynamic Replicate model registry (100+ models)
- ✅ 11 AI categories (video, image, audio, text, etc.)
- ✅ Dynamic credit system with tier-based pricing
- ✅ AWS Cognito authentication (email/password + Google OAuth)
- ✅ Generation history tracking
- ✅ Organization/workspace management
- ✅ Stripe payment integration
- ✅ Dark theme matching web app

## Project Structure

```
LuidGPT/
├── Core/
│   ├── DesignSystem/
│   │   ├── LGColors.swift           # Color system matching web app
│   │   ├── LGTypography.swift       # Typography scale
│   │   ├── LGSpacing.swift          # Spacing & layout constants
│   │   └── Components/
│   │       ├── LGCard.swift         # Card component
│   │       ├── LGButton.swift       # Button variants
│   │       ├── LGBadge.swift        # Badges (category, tier, status)
│   │       ├── LGTextField.swift    # Text inputs & text areas
│   │       └── LGLoadingView.swift  # Loading/empty/error states
│   ├── Network/
│   ├── Auth/
│   ├── Storage/
│   └── Constants/
├── Models/                          # Data models (Category, Model, Generation, User)
├── ViewModels/                      # MVVM ViewModels
├── Views/
│   ├── Auth/                        # Login, Register, Verification
│   ├── Home/                        # Dashboard
│   ├── Models/                      # Browse, Search, Detail
│   ├── Generations/                 # History & Results
│   └── Profile/                     # Settings & Profile
├── Services/                        # Business logic services
└── Resources/                       # Assets, fonts, etc.
```

## Design System

### Colors

The app uses a dark theme matching the web app exactly:

- **Background:** Pure black (#000000)
- **Surfaces:** Neutral grays (950, 900, 800, 700)
- **Primary Action:** Blue (#3B82F6)
- **11 Category Colors:** Purple (video), Blue (image), Green (editing), Yellow (text), Red (audio), Pink (music), Cyan (upscaling), Orange (vision), Indigo (3D), Teal (face), Gray (utility)
- **Tier Colors:** Green (free), Blue (standard), Purple (premium)

See `LGColors.swift` for full color palette.

### Typography

- **Font:** SF Pro (iOS default, matches Geist Sans from web)
- **Scale:** Display (48pt) → Body (16pt) → Caption (12pt)
- **Weights:** Regular (400), Medium (500), Semibold (600), Bold (700)

### Components

All components are prefixed with `LG` (LuidGPT):

- **LGCard:** Standard card with rounded corners, neutral-900 bg
- **LGButton:** Primary, secondary, outline, ghost, danger variants
- **LGBadge:** Category, tier, and status badges with color coding
- **LGTextField:** Text inputs with icons, validation, error states
- **LGTextArea:** Multi-line text input for prompts
- **LGLoadingView:** Loading spinners, skeleton loaders
- **LGEmptyState:** Empty state messages with actions
- **LGErrorView:** Error messages with retry actions

## Dependencies (Swift Package Manager)

Add these dependencies in Xcode → File → Add Packages:

### Required

- **Alamofire** (https://github.com/Alamofire/Alamofire)
  - Networking layer for API calls

- **KeychainSwift** (https://github.com/evgenyneu/keychain-swift)
  - Secure token storage

- **SDWebImageSwiftUI** (https://github.com/SDWebImage/SDWebImageSwiftUI)
  - Image caching and loading

- **AWSMobileClient** (AWS SDK for iOS)
  - Cognito authentication

- **GoogleSignIn-iOS** (https://github.com/google/GoogleSignIn-iOS)
  - Google OAuth integration

- **Stripe** (https://github.com/stripe/stripe-ios)
  - Payment processing

## Setup Instructions

### 1. Open in Xcode

```bash
cd /Users/alaindimabuyo/luid_projects/luidgpt-ios
open LuidGPT.xcodeproj
```

### 2. Install Dependencies

1. Go to **File → Add Packages...**
2. Add each dependency listed above
3. Select the appropriate version (latest stable)

### 3. Configure Environment

Create `Config.swift` in Core/Constants/ with:

```swift
enum AppConfig {
    static let apiBaseURL = "YOUR_API_URL" // e.g., http://localhost:3000/api
    static let cognitoPoolId = "us-east-1_SpqXBs7w9"
    static let cognitoClientId = "32rjg890i69r0ka6c9eh1jlra"
    static let stripePublishableKey = "YOUR_STRIPE_KEY"
}
```

### 4. Build and Run

1. Select a simulator or device
2. Command + R to build and run

## Development Phases

### ✅ Phase 1: Project Setup & Design System (Complete)
- [x] Directory structure
- [x] Design System (Colors, Typography, Spacing)
- [x] Core UI components (Card, Button, Badge, TextField, Loading)

### 🔄 Phase 2: Authentication (In Progress)
- [ ] Cognito integration
- [ ] Login/Register/Verification UI
- [ ] Token management

### ⏳ Phase 3: Core Architecture
- [ ] API Client & networking layer
- [ ] Data models (Category, Model, Generation, User)
- [ ] Services layer

### ⏳ Phase 4: Main Navigation
- [ ] Tab bar structure
- [ ] Home dashboard
- [ ] Navigation flow

### ⏳ Phase 5: Models Browser
- [ ] Category navigation
- [ ] Model cards (3 variants)
- [ ] Search & filters
- [ ] Model detail view
- [ ] Dynamic form generation

### ⏳ Phase 6: Generation Flow
- [ ] Credit validation
- [ ] Model execution
- [ ] Progress tracking
- [ ] Result display (image/video/audio/text)

### ⏳ Phase 7: History & Profile
- [ ] Generations list
- [ ] Generation detail view
- [ ] Profile & settings
- [ ] Credits & billing

## API Integration

The app connects to the luidgpt-backend API:

### Key Endpoints

```
POST   /api/auth/login
POST   /api/auth/register
POST   /api/auth/verify-email
GET    /api/auth/me

GET    /api/models/categories
GET    /api/models/categories/:slug/models
GET    /api/models/search
GET    /api/models/:modelId
POST   /api/models/:modelId/run

GET    /api/models/user/generations
GET    /api/models/user/generations/:id

GET    /api/credits
GET    /api/organizations
```

See backend API documentation for full endpoint list.

## Design Fidelity

The iOS app matches the luidgpt-frontend (Next.js) design:

- ✅ Same dark theme (#000 background)
- ✅ Identical category colors with opacity backgrounds
- ✅ Matching card layouts and spacing
- ✅ Same credit badge styling
- ✅ Consistent tier color system
- ✅ Similar animations and transitions
- ✅ Adapted navigation for mobile (tabs instead of sidebar)

## Contributing

1. Follow the established design system
2. Match web app styling and UX patterns
3. Use MVVM architecture
4. Add unit tests for ViewModels
5. Test on multiple device sizes

## License

MIT License - See LICENSE file

## Contact

For questions or issues, contact the LUID team.
# luidgpt-ios
