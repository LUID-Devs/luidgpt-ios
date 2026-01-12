# LuidGPT iOS - Model Browsing & Credit System Implementation Plan

## 📋 Overview
Implement Replicate AI model browsing, execution, and credit management in the iOS app, matching the functionality of the luidgpt-frontend web app.

## 🏗️ Architecture

### Backend Services
1. **luidgpt-backend** (Port 3000)
   - Manages AI models catalog (categories, models, providers)
   - Handles model execution
   - Integrates with Luidhub for credit checks/deductions

2. **Luidhub-backend** (Port 4000)
   - Credit balance management
   - Credit transactions (deduct/add)
   - Stripe integration for credit purchases
   - Service-to-service auth with API key

### iOS App Structure
```
LuidGPT/
├── Models/
│   ├── ReplicateModel.swift         # Model data structures
│   ├── ModelCategory.swift
│   ├── ModelGeneration.swift
│   └── CreditBalance.swift
├── Services/
│   ├── ModelService.swift           # API calls for models
│   ├── CreditService.swift          # Credit operations
│   └── GenerationService.swift      # Model execution
├── ViewModels/
│   ├── ModelsViewModel.swift        # Model browsing state
│   ├── ModelDetailViewModel.swift   # Single model + execution
│   └── CreditsViewModel.swift       # Credit balance
└── Views/
    ├── ModelsView.swift             # Main browsing view
    ├── CategoryView.swift           # Category filter
    ├── ModelDetailView.swift        # Model execution
    ├── ModelCardView.swift          # Grid item
    └── GenerationsView.swift        # History
```

## 📊 Data Models

### 1. Model Category
```swift
struct ModelCategory: Codable, Identifiable {
    let id: String
    let name: String
    let slug: String
    let description: String?
    let icon: String?
    let creditCostDefault: Int
    let modelCount: Int
    let featured: Bool
}
```

### 2. Replicate Model
```swift
struct ReplicateModel: Codable, Identifiable {
    let id: String
    let modelId: String           // e.g., "openai/sora-2"
    let name: String
    let description: String?
    let category: ModelCategory?
    let categorySlug: String
    let tags: [String]
    let creditCost: Int
    let tier: String              // "standard", "premium", "pro"
    let coverImage: String?
    let thumbnailUrl: String?
    let provider: String?
    let runCount: Int?
    let featured: Bool
    let schemaUrl: String?
}
```

### 3. Credit Balance
```swift
struct CreditBalance: Codable {
    let totalCredits: Int
    let subscriptionCredits: Int
    let purchasedCredits: Int
    let promotionalCredits: Int
    let plan: String
    let periodStart: Date?
    let periodEnd: Date?
    let nextReset: Date?
}

struct CreditBalanceResponse: Codable {
    let success: Bool
    let data: CreditBalanceData

    struct CreditBalanceData: Codable {
        let totalCredits: Int
        let subscriptionCredits: Int
        let purchasedCredits: Int
        let promotionalCredits: Int
        let plan: String
        let periodStart: String?
        let periodEnd: String?
        let nextReset: String?
    }
}
```

### 4. Model Generation
```swift
struct ModelGeneration: Codable, Identifiable {
    let id: String
    let modelId: String
    let modelName: String
    let status: String            // "processing", "succeeded", "failed"
    let input: [String: Any]      // Dynamic input
    let output: [String: Any]?    // Dynamic output
    let error: String?
    let creditsCost: Int
    let createdAt: Date
    let completedAt: Date?
}
```

## 🔌 API Endpoints

### luidgpt-backend (http://localhost:3000/api)

#### Categories
- `GET /models/categories` - List all categories
- `GET /models/categories/:slug` - Get single category
- `GET /models/categories/:slug/models` - Models in category

#### Models
- `GET /models/search?q=query` - Search models
- `GET /models/featured` - Featured models
- `GET /models/providers` - List providers
- `GET /models/providers/:provider` - Models by provider
- `GET /models/:modelId` - Model details (URL encode modelId)
- `GET /models/:modelId/schema` - Model input schema

#### Execution (Requires Auth)
- `POST /models/:modelId/run` - Execute model
  - Body: `{ input: {...} }`
  - Response includes `credits_deducted`

#### Generations (Requires Auth)
- `GET /models/user/generations?page=1&limit=20` - List generations
- `GET /models/user/generations/:id` - Get generation
- `PATCH /models/user/generations/:id` - Update generation
- `DELETE /models/user/generations/:id` - Delete generation
- `POST /models/user/generations/:id/cancel` - Cancel generation

### Luidhub-backend (http://localhost:4000)

#### Credits (Requires Auth)
- `GET /credit/balance` - Get credit balance
- `POST /credit/deduct` - Deduct credits (called by luidgpt-backend)
- `GET /credit/transactions?page=1&limit=20` - Transaction history
- `GET /credit/packages` - Available credit packages
- `POST /credit/purchase` - Create Stripe checkout session

## 🎨 UI Components

### 1. ModelsView (Main Screen)
**Layout:**
- Top: Category horizontal scroll
- Search bar with filters
- Grid of ModelCards (2 columns)
- Pull to refresh
- Infinite scroll pagination

**Features:**
- Category filtering
- Search functionality
- Sort by: Featured, Popular, New, Cost
- Filter by: Tier, Speed, Provider

### 2. ModelCardView
**Design:**
```
┌────────────────────────┐
│  [Cover Image]         │
│  Featured★ Fast⚡      │
│                        │
│  Model Name            │
│  by Provider           │
│  [5 credits] [▶]      │
└────────────────────────┘
```

**Elements:**
- Cover image with gradient overlay
- Featured/Speed badges
- Model name + provider
- Credit cost badge
- Tap to details

### 3. ModelDetailView
**Sections:**
- Header with image
- Description
- Credit cost & speed
- Dynamic form (based on schema)
- "Generate" button
- Recent generations list

### 4. Credit Balance Badge
**Display in:** Navigation bar or toolbar
```
[✨ 127 credits]
```
Tap to see:
- Balance breakdown
- Transaction history
- Purchase options

## 🔄 Implementation Phases

### Phase 1: Credit System Integration ✅
**Files:**
- `Models/CreditBalance.swift`
- `Services/CreditService.swift`
- `ViewModels/CreditsViewModel.swift`

**Tasks:**
1. Create credit models
2. Implement CreditService with balance/transactions
3. Add CreditsViewModel to app state
4. Display credit balance in UI
5. Test with Luidhub-backend

### Phase 2: Model Data Layer
**Files:**
- `Models/ReplicateModel.swift`
- `Models/ModelCategory.swift`
- `Services/ModelService.swift`

**Tasks:**
1. Define all model structures
2. Implement ModelService API calls
3. Handle URL encoding for model IDs
4. Add pagination support
5. Implement search/filter logic

### Phase 3: Browse UI
**Files:**
- `Views/ModelsView.swift`
- `Views/CategoryView.swift`
- `Views/ModelCardView.swift`

**Tasks:**
1. Create category selector
2. Implement ModelCard grid
3. Add search bar
4. Implement filters
5. Add pull-to-refresh
6. Implement infinite scroll

### Phase 4: Model Details & Execution
**Files:**
- `Views/ModelDetailView.swift`
- `ViewModels/ModelDetailViewModel.swift`
- `Services/GenerationService.swift`

**Tasks:**
1. Fetch model schema
2. Build dynamic form UI
3. Implement model execution
4. Show generation progress
5. Display results
6. Save to history

### Phase 5: Generations History
**Files:**
- `Views/GenerationsView.swift`
- `ViewModels/GenerationsViewModel.swift`

**Tasks:**
1. List user generations
2. View generation details
3. Retry failed generations
4. Delete generations
5. Share results

## 🎯 Key Features

### Credit Management
- [x] Display credit balance (done in Phase 1)
- [ ] Real-time balance updates after model execution
- [ ] Transaction history view
- [ ] Low credit warnings
- [ ] Purchase credit packages (Stripe)

### Model Browsing
- [ ] Category-based browsing
- [ ] Search with autocomplete
- [ ] Filter by tier/speed/provider
- [ ] Sort options
- [ ] Featured models section
- [ ] Infinite scroll pagination

### Model Execution
- [ ] Dynamic form generation from schema
- [ ] Credit cost preview
- [ ] Execution progress tracking
- [ ] Result display (image/video/text)
- [ ] Save to device
- [ ] Share results

### Offline Support
- [ ] Cache model list
- [ ] Cache categories
- [ ] Queue failed requests
- [ ] Offline indicator

## 🔧 Technical Considerations

### 1. Model ID Handling
Model IDs contain slashes (e.g., `openai/sora-2`):
```swift
let encodedId = modelId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
let url = "\(baseURL)/models/\(encodedId!)"
```

### 2. Dynamic Schema Forms
Models have different input schemas. Build dynamic forms:
```swift
struct ModelInput {
    let schema: [String: Any]  // JSON schema
    var values: [String: Any]   // User input
}
```

### 3. Credit Deduction Flow
```
1. User taps "Generate"
2. Check credit balance (CreditService)
3. If sufficient, call /models/:id/run
4. Backend checks credits again
5. Backend executes model
6. Backend deducts credits on success
7. iOS updates local balance
```

### 4. Real-time Updates
For long-running models:
```swift
// Poll generation status
func pollGeneration(id: String) async throws -> ModelGeneration {
    repeat {
        let gen = try await fetchGeneration(id)
        if gen.status == "succeeded" || gen.status == "failed" {
            return gen
        }
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2s
    } while true
}
```

### 5. Image/Video Handling
Results can be URLs or base64:
```swift
enum GenerationOutput {
    case imageUrl(String)
    case imageData(Data)
    case videoUrl(String)
    case text(String)
    case json([String: Any])
}
```

## 📝 API Response Examples

### Categories
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Image Generation",
      "slug": "image-generation",
      "description": "Create images from text",
      "creditCostDefault": 5,
      "modelCount": 150,
      "featured": true
    }
  ]
}
```

### Models
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "modelId": "openai/sora-2",
      "name": "Sora 2",
      "description": "Text to video generation",
      "categorySlug": "video-generation",
      "tags": ["speed:fast", "style:realistic"],
      "creditCost": 10,
      "tier": "premium",
      "coverImage": "https://...",
      "provider": "OpenAI",
      "featured": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 24,
    "total": 300,
    "hasMore": true
  }
}
```

### Model Execution
```json
{
  "success": true,
  "generationId": "uuid",
  "status": "processing",
  "credits_deducted": 10,
  "credit_request_id": "lg_1234"
}
```

### Credit Balance
```json
{
  "success": true,
  "data": {
    "total_credits": 127,
    "subscription_credits": 100,
    "purchased_credits": 27,
    "promotional_credits": 0,
    "plan": "pro",
    "period_start": "2026-01-01T00:00:00Z",
    "period_end": "2026-02-01T00:00:00Z",
    "next_reset": "2026-02-01T00:00:00Z"
  }
}
```

## 🚀 Next Steps

1. ✅ **Start Luidhub-backend** (Done - running on port 4000)
2. **Implement Phase 1** - Credit system integration
3. **Test credit endpoints** with existing user
4. **Implement Phase 2** - Model data layer
5. **Build Phase 3** - Browse UI
6. Continue with remaining phases

## 📚 References

- **luidgpt-frontend source:** `/Users/alaindimabuyo/luid_projects/luidgpt-frontend/src`
- **luidgpt-backend source:** `/Users/alaindimabuyo/luid_projects/luidgpt-backend/src`
- **Luidhub-backend source:** `/Users/alaindimabuyo/luid_projects/Luidhub-backend/src`

## 🎨 Design System

Match existing iOS design:
- **Colors:** Blue primary (#3B82F6), neutral backgrounds
- **Typography:** SF Pro system font
- **Cards:** Rounded corners (12pt), shadows
- **Badges:** Pill-shaped with icons
- **Buttons:** Primary blue, secondary gray

---

**Status:** Ready to implement
**Estimated time:** 4-5 days for complete implementation
**Current Phase:** Phase 1 - Credit System Integration
