# 🛵 Meeem Rider - Delivery Partner App (Flutter + GetX + Clean Architecture)

A production-grade, enterprise-ready **Delivery Rider (Driver) Application** built with **Flutter**, **GetX** (State Management, Dependency Injection, and Named Routing with Middleware), and **Clean Architecture**.

---

## 🎨 Design System & Visual Identity

- **Primary Brand Color**: `#0834C2` (Electric Sapphire)
- **Secondary CTA Accent**: `#FF6B00` (Warm Amber/Orange for critical actions like *Accept Order* and *Cash Out*)
- **Semantic Colors**:
  - **Success**: `#00C853` / `#10B981` (Delivered, Online, Verified Documents)
  - **Warning**: `#FFA000` / `#F59E0B` (Pending, In Transit, Special Instructions)
  - **Error**: `#EF4444` / `#D32F2F` (Rejected, Cancelled, Offline)
  - **Info**: `#0284C7` (Navigation, Turn Guidance)
- **Themes**: Full **Material 3 Light and Dark Modes** derived dynamically from `#0834C2`.
- **Typography**: Clean typography hierarchy powered by Google Fonts (Inter & Poppins).
- **Interactive Elements**: Custom rounded cards (16px radius), `SwipeButton` (swipe-to-confirm delivery steps to prevent accidental taps), and full-screen reactive modals.

---

## 🏗️ Architecture: Clean Architecture + GetX

The project is strictly organized into four decoupled layers:

```
lib/
├── core/
│   ├── theme/            # app_colors.dart, app_theme.dart, text_styles.dart
│   ├── constants/        # api_endpoints.dart, app_strings.dart, app_constants.dart
│   ├── network/          # dio_client.dart, api_interceptor.dart, mock_interceptor.dart, network_info.dart
│   ├── utils/            # validators.dart, formatters.dart, extensions.dart
│   ├── error/            # failures.dart, exceptions.dart
│   └── widgets/          # custom_button.dart, swipe_button.dart, custom_text_field.dart, status_badge.dart, custom_card.dart, etc.
│
├── data/
│   ├── models/           # DTOs (fromJson / toJson / toEntity)
│   ├── datasources/      # Remote (DioClient) & Local (GetStorage)
│   └── repositories/     # Concrete implementations of Domain Repository contracts
│
├── domain/
│   ├── entities/         # Pure Dart business models (Equatable, zero Flutter dependencies)
│   ├── repositories/     # Abstract repository interfaces
│   └── usecases/         # Single-responsibility use cases returning Either<Failure, T>
│
├── presentation/
│   ├── routes/           # app_pages.dart, app_routes.dart, auth_guard.dart (GetMiddleware)
│   └── modules/
│       ├── splash/       # Splash view, binding, auth check redirect
│       ├── auth/         # Login (phone), OTP verification (with timer), Rider registration
│       ├── main_layout/  # Bottom navigation container hosting tabs with live badge counters
│       ├── dashboard/    # Online/offline toggle, today metrics, incoming order alert with 30s countdown
│       ├── orders/       # Active order progression, swipeable status transitions, delivery proof (photo + OTP), history
│       ├── navigation/   # Live turn-by-turn guidance, route polyline, distance/ETA, external Google Maps launcher
│       ├── earnings/     # Daily/weekly/monthly breakdown, interactive performance chart, instant cash-out modal
│       ├── profile/      # Rider stats, vehicle details, document verification hub (license, insurance), dark mode toggle
│       └── notifications/# Categorized push alerts & announcements
│
├── app.dart              # GetMaterialApp configuration (themes, routes, bindings)
└── main.dart             # Storage init, services init, and app entrypoint
```

---

## 🚀 Core Features & Modules

### 1. 🔐 Authentication & Onboarding
- Phone Number login with country code dropdown.
- 6-digit OTP verification with 45s resend timer countdown.
- 3-step Rider Onboarding (Personal info, Vehicle type & License plate, Document upload).
- `AuthGuard` middleware protecting internal screens.

### 2. ⚡ Dashboard & Incoming Order Ping
- Online / Offline live switch with simulated background location status.
- Real-time today's summary: Earnings, completed trips, acceptance rate, customer rating.
- **Incoming Order Alert Modal**:
  - 30-second reactive circular countdown timer.
  - Store name, pickup address, dropoff address, trip distance, and estimated earnings.
  - Quick "Accept Order" (Amber CTA) & "Decline" actions.
  - One-tap "Test Incoming Order" simulation button for testing.

### 3. 📦 Active Order & Multi-Step Delivery Flow
- Step-by-step delivery lifecycle:
  1. `Heading to Pickup`
  2. `Arrived at Store`
  3. `Order Picked Up` (with items checklist & customer notes)
  4. `On the Way`
  5. `Arrived at Customer`
  6. `Delivered` (triggers Proof of Delivery dialog: customer OTP + photo capture simulation).
- `SwipeButton` confirmation slider to prevent accidental status changes.
- Direct call/SMS shortcuts for customer and store contact.

### 4. 🗺️ Turn-by-Turn Navigation
- Interactive stylized live map with route polyline, live rider marker, and destination pin.
- Turn-by-turn instruction banner ("In 250m, Turn Right onto Broadway St").
- Live ETA, remaining distance, and current speed metrics.
- "Open in Google Maps" external navigation launcher.

### 5. 💰 Earnings & Wallet
- Daily, weekly, and monthly period filters.
- Interactive weekly earnings bar chart.
- Payout breakdown: Base fare, customer tips, surge & incentives.
- Instant Cash Out bottom sheet to withdraw available balance to bank account.
- Itemized transaction history.

### 6. 📄 Profile, Documents & Vehicle Info
- Rider profile with rating, total trips, and avatar.
- Document Verification Hub: Real-time status for Driver's License, Vehicle Insurance, and Background Check (`Verified`, `Under Review`, `Action Required`).
- Dynamic Dark / Light theme switcher with local persistence.

---

## 🛠️ State Management Rules (GetX)

1. **Controllers**: Extend `GetxController` and expose `.obs` reactive state variables.
2. **Dependency Injection**: Registered lazily via `Bindings` (`Get.lazyPut()`)—controllers are never instantiated directly in widgets.
3. **Use Cases**: Controllers call single-responsibility **UseCases** returning `Future<Either<Failure, T>>` (`dartz`). Controllers never communicate directly with repositories or Dio.
4. **Mock Interceptor**: Out-of-the-box `MockInterceptor` in Dio allows instant, zero-backend testing and full interactivity.

---

## ➕ How to Add a New Module

Follow this 4-step workflow to add any new feature (e.g. `Chat`):

### Step 1: Define Domain Layer
1. Create entity in `lib/domain/entities/chat_message_entity.dart`.
2. Create repository interface in `lib/domain/repositories/chat_repository.dart`.
3. Create use cases in `lib/domain/usecases/chat/send_message_usecase.dart` and `get_messages_usecase.dart`.

### Step 2: Implement Data Layer
1. Create model DTO in `lib/data/models/chat_message_model.dart` with `fromJson`/`toJson`.
2. Create datasource in `lib/data/datasources/chat_remote_datasource.dart`.
3. Implement repository in `lib/data/repositories/chat_repository_impl.dart`.

### Step 3: Build Presentation Layer
1. Create controller in `lib/presentation/modules/chat/controllers/chat_controller.dart`.
2. Create binding in `lib/presentation/modules/chat/bindings/chat_binding.dart`.
3. Create view screen in `lib/presentation/modules/chat/views/chat_view.dart`.

### Step 4: Register Route
1. Add route name in `lib/presentation/routes/app_routes.dart`:
   ```dart
   static const String chat = '/chat';
   ```
2. Register `GetPage` in `lib/presentation/routes/app_pages.dart`:
   ```dart
   GetPage(
     name: AppRoutes.chat,
     page: () => const ChatView(),
     binding: ChatBinding(),
     middlewares: [AuthGuard()],
   ),
   ```

---

## 🧪 Testing & Quality Assurance

Run the test suite:
```bash
flutter test
```

Run static analysis:
```bash
flutter analyze
```

---

## 📦 Running the Application with FVM

This project uses [FVM (Flutter Version Management)](https://fvm.app) for Flutter version pinning (`stable`).

```bash
# Setup FVM in the project (if cloning for the first time)
fvm use stable

# Get dependencies
fvm flutter pub get

# Run test suite
fvm flutter test

# Run static analysis
fvm flutter analyze

# Run on connected device or simulator
fvm flutter run
```
