# 04 — هيكل الشاشة وفصل المنطق عن الـ Widgets

## Screen vs Body (الفصل محدد بدقة، لا اجتهاد)

**Screen File** — يحتوي **فقط** على `Scaffold` + `BlocProvider` لو محتاج. لا UI تفصيلي هنا.

```dart
// presentation/screens/login_screen.dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: const Scaffold(body: LoginScreenBody()),
    );
  }
}
```

**Body File** — تركيب الـ UI الكامل، لكنه **هو نفسه widget composition بس**. أي قسم كبير (header, form, list) يُستدعى كـ widget منفصل من ملف منفصل.

```dart
// presentation/widgets/login_screen_body.dart
class LoginScreenBody extends StatelessWidget {
  const LoginScreenBody({super.key});
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [LoginHeader(), LoginForm(), LoginSocialButtons()],
      ),
    );
  }
}
```

> **القاعدة الفاصلة:** قسم أكتر من ~20-25 سطر كود → ملف خاص تحت `widgets/`. أقل من ذلك (صف بسيط من أزرار) → يجوز inline داخل الـ Body.

## ⛔ ممنوع تمامًا داخل أي ملف widget

```dart
String formatDate() {}
String formatTime() {}
Future<void> submit() {}
Future<void> loadData() {}
void validate() {}
List<User> filterUsers() {}
```

أي method غير `build()` داخل widget file = مخالفة. الوجهة الصحيحة:

| نوع المنطق | الوجهة |
|---|---|
| API call, state change, filtering, sorting, mapping | **Cubit** |
| منطق domain خالص | **UseCase** |
| image/file picking, sharing, url launching | **Helper** |
| date/time formatting, validation عامة | **Utils** |

## ⛔ Private widgets ممنوعة

ممنوع `_WidgetName` كحل تقسيم. كل widget كلاس **public** في ملف مستقل.

## قاعدة حجم الملف (مرنة، الهدف 150 سطر)

استثناءات بدون كسر القاعدة:
- ملفات `*_state.dart` بعدد states كبير وبسيطة (extends Equatable فقط).
- ملفات بها كثير imports/enums قبل الكلاس الفعلي.

لو تجاوز الملف 150 سطر فعليًا بمنطق UI/Logic (مش imports/enums):
1. قف عن الكتابة.
2. افصل لقطع منطقية (header/form/section/card/list/dialog/item).
3. أعد التوليد بالهيكل الجديد.

## 🔎 Self-check سريع لهذا الملف

```
[ ] Screen file فيه Scaffold فقط
[ ] Body file فيه composition فقط، الأقسام الكبيرة منفصلة
[ ] لا method غير build() داخل أي widget file
[ ] لا private widgets (_WidgetName)
[ ] حجم الملف ~150 سطر أو مبرر بوضوح لو تجاوز
```
