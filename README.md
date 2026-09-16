# 🛒 Store & Catalog — Flutter Mobile Capstone App

A production-grade, offline-first E-Commerce and Product Catalog mobile application built with **Flutter**, **Provider** state management, **Hive** offline NoSQL local persistence, and **RESTful API** integration.

---

## 📋 Table of Contents
- [Architecture Overview](#-architecture-overview)
- [Module Breakdown](#-module-breakdown)
  - [Task 04: State Management & Offline Hive Storage](#task-04-state-management--offline-hive-storage)
  - [Task 05: RESTful API Integration & Network Handling](#task-05-restful-api-integration--network-handling)
  - [Task 06: Production Capstone Features & Build](#task-06-production-capstone-features--build)
- [Project Directory Structure](#-project-directory-structure)
- [State Management & Data Flow](#-state-management--data-flow)
- [Getting Started & Installation](#-getting-started--installation)
- [Testing Offline / Airplane Mode](#-testing-offline--airplane-mode)
- [Generating Release APK](#-generating-release-apk)

---

## 🏛️ Architecture Overview

The app follows **Clean Architecture** principles separating data models, services, business logic state management, and the presentation layer:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  (HomeScreen, DetailsScreen, CartScreen, LoginScreen, etc.) │
└──────────────────────────────┬──────────────────────────────┘
                               │ watches / consumes
┌──────────────────────────────▼──────────────────────────────┐
│                    State Management Layer                   │
│  (ProductsProvider, CartProvider, AuthProvider, etc.)       │
└──────────────────────────────┬──────────────────────────────┘
                               │ calls
        ┌──────────────────────┴──────────────────────┐
        ▼                                             ▼
┌──────────────────────────────┐      ┌──────────────────────────────┐
│         API Service          │      │    Storage Service (Hive)    │
│ (HTTP GET, POST, PUT / REST) │      │ (Offline NoSQL Cache Boxes)  │
└──────────────────────────────┘      └──────────────────────────────┘
```

---

## 🚀 Module Breakdown

### Task 04: State Management & Offline Hive Storage
* **Predictable State Management (`provider`)**:
  * `ThemeProvider`: Manages Dark/Light mode theme state and user preferences.
  * `AuthProvider`: Handles user session, JWT auth tokens, and login/logout state.
  * `CartProvider`: Manages cart additions, quantity adjustments, and subtotal calculation.
  * `FavoritesProvider`: Manages bookmarked items with immediate reactive updates.
  * `ProductsProvider`: Handles pagination, search, category filtering, and offline cache fallbacks.
* **Offline NoSQL Database (`hive` & `hive_flutter`)**:
  * `cached_products_box`: Persists fetched products for complete offline read capability.
  * `cart_box`: Stores cart items across app restarts.
  * `favorites_box`: Stores bookmarked items locally.
  * `auth_box`: Securely caches user auth tokens.
  * `settings_box`: Saves user preferences and theme settings.
* **Efficient UI Re-renders**:
  * State updates use targeted listeners (`context.watch`, `context.read`) preventing unnecessary widget tree rebuilds.

### Task 05: RESTful API Integration & Network Handling
* **Asynchronous Networking (`http`)**:
  * `GET /products?limit=10&skip=X`: Fetches paginated catalog data.
  * `GET /products/category/{category}`: Fetches filtered products by category.
  * `GET /products/search?q={query}`: Live search queries.
  * `POST /auth/login`: Authenticates users and returns JWT tokens.
  * `PUT /users/{id}`: Updates user profile data.
* **Data Serialization**:
  * `Product.fromJson()` and `Product.toJson()`
  * `UserModel.fromJson()` and `UserModel.toJson()`
  * `CartItem.fromJson()` and `CartItem.toJson()`
* **UI Feedback & Animations**:
  * **Pull-to-Refresh**: Integrated via `RefreshIndicator`.
  * **Infinite Scroll Pagination**: `ScrollController` listener detects bottom threshold and requests next page.
  * **Shimmer Skeleton Loading**: Custom animated gradient shimmer (`ShimmerSkeleton`, `ProductCardShimmer`) displayed while data loads.
  * **Network Error Banner**: Persistent `NetworkErrorBanner` with status icon and actionable "Retry" button.

### Task 06: Production Capstone Features & Build
* **User Authentication**: Login screen with demo credentials and persistent tokens.
* **Data Filtering & Search**: Category filter chips (`beauty`, `fragrances`, `furniture`, `groceries`) and real-time search.
* **Cart & Checkout Workflow**: Full checkout flow with summary calculation and order confirmation dialog.
* **In-App Notifications**: Floating toast banners confirming item additions, bookmarking, and orders.
* **Multi-Platform Ready**: Fully scaffolded for Android (`android/`) and Web (`web/`).

---

## 📂 Project Directory Structure

```
lib/
├── main.dart                      # App entry point, MultiProvider setup, Hive init
├── models/
│   ├── cart_item.dart             # Cart item data model with total price getter
│   ├── product.dart               # Product entity with JSON serialization
│   └── user_model.dart            # User profile and auth token model
├── providers/
│   ├── auth_provider.dart         # Global auth state & token persistence
│   ├── cart_provider.dart         # Cart state & item quantity management
│   ├── favorites_provider.dart    # Offline bookmarked favorites state
│   ├── products_provider.dart     # Catalog, pagination, search, & offline cache
│   └── theme_provider.dart        # Light/Dark mode theme toggle
├── screens/
│   ├── auth/
│   │   └── login_screen.dart      # User authentication screen
│   ├── cart_screen.dart           # Shopping cart overview & checkout
│   ├── details_screen.dart        # Product specifications & CTA
│   ├── favorites_screen.dart      # Offline-accessible saved favorites
│   ├── home_screen.dart           # Catalog, search, filters, pagination, shimmer
│   └── profile_screen.dart        # User profile, tokens, & settings
├── services/
│   ├── api_service.dart           # HTTP REST client (GET, POST, PUT)
│   └── storage_service.dart       # Hive NoSQL offline database helper
├── theme/
│   └── app_theme.dart             # Material 3 light & dark theme definitions
└── widgets/
    ├── network_error_banner.dart  # Offline & network error alert banner
    ├── product_card.dart          # Product display card with action buttons
    └── shimmer_loading.dart       # Animated skeleton shimmer effect
```

---

## 🔄 State Management & Data Flow

```text
User Action (Scroll / Filter / Add to Cart / Toggle Favorite)
                      │
                      ▼
               Provider Method
                      │
        ┌─────────────┴─────────────┐
        ▼                           ▼
  API Request                 Hive Local Box
  (Network)                   (Offline Storage)
        │                           │
        ▼                           ▼
   Update State ◄────────── Fallback on Failure
        │
        ▼
   notifyListeners()
        │
        ▼
  Granular Widget Rebuild (Consumer / context.watch)
```

---

## 🛠️ Getting Started & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19 or higher)
- Google Chrome or Android Studio / Device

### Setup Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/vedmishra598-hue/mobile-product.git
   cd mobile-product
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   # Run on Chrome (Web)
   flutter run -d chrome

   # Run on connected Android device / emulator
   flutter run -d android
   ```

---

## ✈️ Testing Offline / Airplane Mode

1. Open the app while connected to the internet to populate the local Hive cache.
2. Disconnect your Wi-Fi or turn on **Airplane Mode**.
3. Re-open or refresh the app:
   - The app gracefully detects offline status.
   - Cached products load instantly from **Hive local storage**.
   - An amber offline banner appears: *"Offline mode: Showing cached data"*.
   - You can still browse products, view details, and modify your cart/favorites offline.

---

## 📦 Generating Release APK

To generate a signed production release APK:

```bash
flutter build apk --release
```

The output APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

To build an Android App Bundle (AAB) for Google Play:
```bash
flutter build appbundle --release
```

---

## 📄 License
This project is developed as an offline-first mobile product slice capstone under the MIT License.
