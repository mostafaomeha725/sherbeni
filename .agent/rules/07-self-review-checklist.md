# 07 — Self-Review Checklist النهائية (تُكتب فعليًا في كل رد كود)

> هذا الملف يُستخدم في "الخطوة C" من `00-master.md`. لا تكتب هذه القائمة فاضية أو تلخّصها بجملة عامة — كل بند لازم ✅ أو ❌ مع سبب لو ❌.

```
### ✅ مراجعة ما بعد الكتابة

[ ] لا Text/ElevatedButton/TextButton/OutlinedButton مباشرة
[ ] لا Image.asset/Image.network خارج core widgets
[ ] لا TextFormField مباشرة (استُخدم AppFormField)
[ ] لا Navigator أو MaterialPageRoute (استُخدم GoRouter)
[ ] لا business logic / API calls / validation / calculations داخل widget file
[ ] لا repository أو data source access من presentation
[ ] Cubit يستدعي UseCase فقط (لا repository مباشر)
[ ] UseCase شكله: كلاس + call() + يرجع Either<Failure, T>
[ ] domain خالٍ من أي import خاص بـ Flutter
[ ] كل الأخطاء تمر بـ Either/Failure، لا Exception خام فوق Repository
[ ] get_it: Cubit = Factory, باقي الطبقات = LazySingleton
[ ] Screen file = Scaffold فقط، Body file = التركيب الكامل
[ ] لا private widgets (_WidgetName)
[ ] لا method غير build() داخل أي widget file
[ ] حجم الملف ~150 سطر أو مبرر بوضوح لو تجاوز
[ ] تم ذكر مسارات البحث الفعلية عن إعادة الاستخدام في الخطوة A
```

## ماذا تفعل لو بند ❌

1. **لا ترسل الرد بهذا الشكل.**
2. رجع للكود وصحّح المخالفة المحددة.
3. أعد كتابة الـ checklist كاملة من جديد بعد التصحيح، بحيث تظهر للمستخدم نسخة نهائية كلها ✅ (أو ❌ مع تبرير واضح ومقصود لو كان الاستثناء مذكور صريح في الملفات 01-06، مثل استثناء setState المحلي).

## مبدأ عام

الـ checklist دي مش للـ "أرشفة" في آخر الرد — هي خطوة فحص فعلية. لو وجدت نفسك تكتبها سريعًا كلها ✅ بدون رجوع حقيقي للكود اللي كتبته، هذا يعني إنك بتتجاهل الإجراء، وهو نفس المشكلة اللي البروتوكول ده معمول عشان يحلها.
