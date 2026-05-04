# PantrySync - iOS Development Guide

## Executive Summary

PantrySync is an all-in-one smart kitchen manager that unifies grocery lists, pantry inventory, recipe management, meal planning, and nutrition tracking into a single iOS application. Unlike existing apps that force users to juggle 3-5 separate tools, PantrySync creates a seamless loop: shop, stock, cook, track, repeat.

**Target Audience**: US households (25-45 year olds) struggling with food waste ($1,500+/year average), app fragmentation, and disconnected nutrition tracking.

**Key Differentiators**:
- Only app combining grocery list + pantry inventory + nutrition tracking in one
- Receipt OCR scanning for instant pantry stocking
- Barcode scanning with Open Food Facts database integration
- Expiration alerts + waste analytics
- Recipe recommendations based on current pantry contents
- iCloud family sharing at no extra cost
- Fair pricing: generous free tier + affordable subscription

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **AnyList** | Best grocery list sharing, Siri/Alexa, recipe import, $9.99/yr | No pantry inventory, no nutrition tracking, no expiration alerts | PantrySync adds full inventory + nutrition + expiry on top of grocery lists |
| **KitchenPal** | Pantry + recipes + barcode scan, recipe-by-ingredient | Clunky UI, limited nutrition, premium required for basic features, $4-6/mo | Cleaner SwiftUI design, receipt OCR, nutrition tracking, better free tier |
| **Pantry Inventory Tracker** | Clean SwiftUI, Open Food Facts, offline-first, no account needed | No grocery list, no recipes, no meal planning, no nutrition goals | Full feature suite: grocery + recipes + meal plan + nutrition in one app |

## Apple Design Guidelines Compliance

- **Navigation**: Tab-based navigation with 5 tabs (Pantry, Grocery, Recipes, Meal Plan, Nutrition) following Apple's tab bar guidelines
- **Haptic Feedback**: Use UIImpactFeedbackGenerator for check-offs, UINotificationFeedbackGenerator for alerts
- **Dark Mode**: Full support using semantic colors (Color.primary, Color.secondary, system backgrounds)
- **Dynamic Type**: All text scales with user's preferred content size
- **SF Symbols**: Use system symbols throughout (checkmark, cart, fork.knife, chart.bar.fill)
- **Swipe Actions**: Standard swipe-to-delete and swipe-to-check on list items
- **Search**: Use searchable modifier with suggested tokens for categories
- **Sheets**: Use sheet presentations for add/edit flows, not full-screen pushes
- **Notifications**: Local notifications for expiration alerts, following Apple's notification design guidelines

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (camera/scanner overlays)
- **Data**: SwiftData with @Model classes, local-first with optional iCloud sync
- **Scanning**: AVFoundation + VisionKit for barcode, Vision Framework for receipt OCR
- **Networking**: URLSession for Open Food Facts API and Spoonacular API
- **Charts**: Swift Charts for nutrition and waste analytics
- **Notifications**: UserNotifications framework for local expiration alerts
- **Widgets**: WidgetKit for home screen quick view
- **Minimum iOS**: 17.0

## Module Structure

```
PantrySync/
├── PantrySyncApp.swift
├── Models/
│   ├── PantryItem.swift
│   ├── GroceryItem.swift
│   ├── Recipe.swift
│   ├── RecipeIngredient.swift
│   ├── MealPlan.swift
│   ├── MealPlanDay.swift
│   ├── DailyNutritionLog.swift
│   └── NutritionInfo.swift
├── Views/
│   ├── Pantry/
│   │   ├── PantryView.swift
│   │   ├── PantryItemRow.swift
│   │   ├── AddPantryItemView.swift
│   │   └── PantryFilterView.swift
│   ├── Grocery/
│   │   ├── GroceryListView.swift
│   │   ├── GroceryItemRow.swift
│   │   └── AddGroceryItemView.swift
│   ├── Recipes/
│   │   ├── RecipeListView.swift
│   │   ├── RecipeDetailView.swift
│   │   ├── AddRecipeView.swift
│   │   └── RecipeSearchView.swift
│   ├── MealPlan/
│   │   ├── MealPlanView.swift
│   │   └── MealPlanDayView.swift
│   ├── Nutrition/
│   │   ├── NutritionDashboardView.swift
│   │   └── NutritionLogView.swift
│   ├── Scanner/
│   │   ├── BarcodeScannerView.swift
│   │   └── ReceiptScannerView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── ContactSupportView.swift
│   └── Shared/
│       ├── CategoryPicker.swift
│       └── ExpiryBadge.swift
├── ViewModels/
│   ├── PantryViewModel.swift
│   ├── GroceryListViewModel.swift
│   ├── RecipeViewModel.swift
│   ├── MealPlanViewModel.swift
│   └── NutritionViewModel.swift
├── Services/
│   ├── ReceiptScanner.swift
│   ├── BarcodeLookupService.swift
│   ├── NotificationService.swift
│   └── SpoonacularService.swift
└── Utilities/
    ├── Constants.swift
    └── Extensions.swift
```

## Implementation Flow

1. Set up SwiftData models (PantryItem, GroceryItem, Recipe, RecipeIngredient, MealPlan, MealPlanDay, DailyNutritionLog, NutritionInfo)
2. Create PantrySyncApp with TabView navigation and SwiftData container
3. Build Pantry module (inventory view, add item, filter by category/location, expiration badges)
4. Build Grocery List module (add items, check off, auto-move to pantry, link recipes)
5. Build Scanner module (barcode scanning with AVFoundation, receipt OCR with Vision)
6. Build Recipe module (list, detail, add, search via Spoonacular API)
7. Build Meal Plan module (weekly calendar, assign recipes to meals, generate grocery list)
8. Build Nutrition module (daily log, macro tracking, charts with Swift Charts)
9. Build Settings module (iCloud sync toggle, notification preferences, contact support, policy links)
10. Implement notification service for expiration alerts
11. Implement barcode lookup with Open Food Facts API
12. Add WidgetKit widget for quick pantry/grocery overview
13. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**: 
  - Primary: #34C759 (Apple Green - freshness, food)
  - Secondary: #FF9500 (Orange - warmth, kitchen)
  - Accent: #007AFF (Blue - trust, sync)
  - Background: System grouped background colors
  - Expiring Soon: #FF3B30 (Red)
  - Expiring Warning: #FF9500 (Orange)
  - Fresh: #34C759 (Green)

- **Typography**: 
  - Large Title: SF Pro Display 34pt Bold
  - Title 2: SF Pro Display 22pt Bold
  - Headline: SF Pro Text 17pt Semibold
  - Body: SF Pro Text 17pt Regular
  - Caption: SF Pro Text 12pt Regular

- **Layout**:
  - Tab bar with 5 tabs: Pantry, Grocery, Recipes, Meals, Nutrition
  - List-based views with swipe actions
  - Sheet presentations for add/edit flows
  - iPad: sidebar navigation + content area with .frame(maxWidth: 720)
  - Search bar at top of list views

- **Animations**:
  - Check-off animation on grocery items (strikethrough + fade)
  - Smooth tab transitions
  - Sheet slide-up for add forms
  - Progress ring animation for nutrition goals

## Code Generation Rules

- Use SwiftData @Model for all data models
- Use MVVM pattern with @Observable ViewModels
- All SwiftData model attributes must be optional or have default values
- Use @Query for fetching data in views
- Use #Preview macros for SwiftUI previews
- Use async/await for all network calls
- Use SF Symbols for all icons
- No third-party dependencies (Apple native only)
- No code comments unless explicitly requested
- iPad layout must use .frame(maxWidth: 720).frame(maxWidth: .infinity) for main content
- Never use .tabViewStyle(.sidebarAdaptable)

## Build & Deployment Checklist

1. Verify Bundle ID: com.zzoutuo.PantrySync
2. Verify Deployment Target: iOS 17.0
3. Configure App Icon (1024x1024)
4. Enable capabilities: Camera, Photo Library, Notifications, iCloud (CloudKit)
5. Add NSCameraUsageDescription to Info.plist
6. Add NSPhotoLibraryUsageDescription to Info.plist
7. Build and test on iPhone simulator
8. Build and test on iPad simulator
9. Push to GitHub repository
10. Deploy policy pages to GitHub Pages
11. Prepare App Store Connect metadata
