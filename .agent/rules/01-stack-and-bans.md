# 01 — Stack الثابت والممنوعات

## الـ Stack (قرارات ثابتة، غير قابلة للتفاوض)

| الجزء | الأداة |
|---|---|
| State Management | `flutter_bloc` (Cubit فقط) |
| Dependency Injection | `get_it` |
| Error Handling | `dartz` (`Either<Failure, T>`) |
| Navigation | `go_router` |
| الحد الأقصى لطول الملف | 150 سطر (مرن — راجع 04) |

ممنوع: `Provider`, `Riverpod`, `GetX`, أي state management تاني.

---

## ⛔ ممنوع في أي Screen أو Feature Widget

```
Text
ElevatedButton
TextButton
OutlinedButton
Image.asset
Image.network
TextFormField
ScaffoldMessenger
Navigator.push / pop / pushReplacement / pushNamed / popUntil
MaterialPageRoute
```

> **استثناء وحيد:** الـ Core Widgets نفسها (`AppText`, `AppImage`...) لازم تستخدم هذه الـ widgets الأساسية **داخل تنفيذها هي فقط**. أي استخدام مباشر خارج `lib/core/widgets` = مخالفة.

## ✅ استخدم دايمًا بدلًا منها

**عامة (قابلة لإعادة الاستخدام في أي مشروع):**
```
AppText, AppButton, AppImage, AppAsset, AppSVG, AppFormField,
CustomSearch, CustomSnackBar, CustomLoading, BounceIt,
CustomNavBar, CustomBottomNavBar, NavBarItem, SwitchOpen,
BouncingSocialButton
```

**خاصة بهذا المشروع (لا تفترض وجودها في مشروع آخر):**
```
GovernorateDropdown
AppbarSubscriptionWidget
```

## Navigation

استخدم فقط: `context.push()`, `context.go()`, `context.pop()`.
Routes تُعرَّف مركزيًا في `lib/core/routing/app_router.dart`.

## 🔎 Self-check سريع لهذا الملف (اكتبه في الخطوة C)

```
[ ] لا Text/ElevatedButton/TextButton/OutlinedButton مباشرة
[ ] لا Image.asset/Image.network خارج core widgets
[ ] لا TextFormField (استُخدم AppFormField)
[ ] لا Navigator/MaterialPageRoute (استُخدم GoRouter فقط)
```
