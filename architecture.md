# Flutter Development Rules

You are a senior Flutter engineer. Follow these rules STRICTLY.

---

## 🚫 Forbidden

Never use:

- Text
- ElevatedButton
- TextButton
- OutlinedButton
- Image.asset
- Image.network
- TextFormField
- ScaffoldMessenger
- Navigator.push
- Navigator.pop
- MaterialPageRoute
- setState for business logic
- setState for shared state

---

## ✅ Required

Always use:

- AppText
- AppButton
- AppImage
- AppAsset
- AppSVG
- AppFormField
- CustomSnackBar
- CustomLoading
- BounceIt

---

## ♻️ Reusability Rules

Before creating anything new:

- ALWAYS check `lib/core/widgets`
- Reuse existing widgets first
- If similar widget exists → extend it instead of duplicating it
- Never duplicate UI logic

---

## 🧠 Core Widgets

Always prefer existing widgets:

- AppText
- AppButton
- AppAsset
- AppImage
- AppSVG
- AppFormField
- CustomSearch
- CustomSnackBar
- CustomLoading
- BounceIt
- CustomNavBar
- CustomBottomNavBar
- NavBarItem
- GovernorateDropdown
- SwitchOpen
- AppbarSubscriptionWidget
- BouncingSocialButton

---

# 🧰 Core Helpers

ALL helpers must be inside:

`lib/core/helpers/helpers.dart`

---
# AppText 

AppText(text, style: font14w500.copyWith(color: Colors.grey)),

### Never:

- create new helper files
- duplicate helper logic
- rewrite existing helper logic
- place helper logic inside UI files

---

### Use helpers for:

- image picking
- file picking
- sharing
- timers
- url launching
- whatsapp
- phone calls
- emails
- pdf handling
- file handling
- permissions
- reusable formatting logic
- date formatting
- duration formatting
- time formatting

---

# ⚙️ Core Utils

Use ONLY from:

`lib/core/utils`

Available:

- app_bloc_observer.dart
- app_date_time.dart
- easy_loading.dart
- safe_print.dart
- spacing.dart
- url_launcher_util.dart
- validators.dart

---

### Utils Rules

- NEVER rewrite utils
- NEVER duplicate formatting logic

---

# 🧱 Clean Architecture

Must follow:

presentation → domain → data

---

### Rules

- UI must NEVER access repositories directly
- Cubits call UseCases ONLY
- Business logic only in domain layer
- No Flutter imports in domain layer

---

# 🧠 State Management

Use ONLY:

- Cubit
- Bloc

Allowed:

- BlocBuilder
- BlocListener
- BlocConsumer

Forbidden:

- setState for logic
- business logic in UI

---

# 🧠 Cubit Rules

Move logic to Cubit when it contains:

- API calls
- validation logic
- filtering
- calculations
- state changes
- feature logic

Cubits must call UseCases only.

---

# 🧭 Navigation

Use GoRouter ONLY:

- context.push()
- context.go()
- context.pop()

Forbidden:

- Navigator
- MaterialPageRoute

---

# 🧱 Screen Structure

Each screen must have:

## Screen File

Contains ONLY:

- Scaffold

Example:

`login_screen.dart`

---

## Body File

Contains:

- full UI

Example:

`login_screen_body.dart`

---

# 📂 File Splitting (CRITICAL)

Maximum:

- 120 lines per file

If exceeded:

1. Return folder structure FIRST
2. Then generate files one by one

---

# 🧩 Large UI Rules

If UI becomes large:

Create widgets folder and split into:

- header
- form
- section
- card
- list
- dialog

---

# 🧩 Widget Rules

Forbidden:

- private widgets in same file
- `_WidgetName`

Every widget must be in separate file.

---

# 🚫 Widget Logic Separation (VERY IMPORTANT)

Never place functions inside widget files except `build()`.

Forbidden inside widgets:

- formatting functions
- parsing functions
- calculation functions
- async functions
- helper methods
- mapper functions
- reusable methods
- API calls
- validation logic
- transformation logic

---

### Forbidden Examples

```dart
String _formatDate() {}
String _formatTime() {}
String _formatDuration() {}