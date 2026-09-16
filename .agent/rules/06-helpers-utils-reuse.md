# 06 — Helpers, Utils، وإعادة الاستخدام الفعلية

## Helpers

الموقع: `lib/core/helpers/helpers.dart`

استخدمه لـ: image picking, file picking, sharing, timers, url launching, whatsapp, phone calls, emails, permissions, file handling, pdf handling, date/duration/time formatting.

- ممنوع إنشاء ملف helper جديد بدون داعي.
- منطق helper جديد فعليًا → يُضاف داخل `helpers.dart` أو ملف جديد تحت `core/helpers/` لو الملف الحالي كبير جدًا — أبدًا داخل ملف UI.

## Utils

الموقع: `lib/core/utils/`

```
app_bloc_observer.dart, app_date_time.dart, easy_loading.dart,
safe_print.dart, spacing.dart, url_launcher_util.dart, validators.dart
```

- ممنوع تكرار validation موجود في `validators.dart` — استخدمه أو وسّعه.
- ممنوع كتابة date/time formatting جديد لو `app_date_time.dart` كافٍ.

---

## ⚙️ إجراء البحث الفعلي قبل إنشاء أي كود جديد (إلزامي، ليس اختياريًا)

قبل إنشاء widget/helper/util جديد، نفّذ **فعليًا** (واذكر النتيجة في "الخطوة A" من البروتوكول):

1. ابحث عن اسم قريب من الحاجة المطلوبة في:
   - `lib/core/widgets/`
   - `lib/core/helpers/helpers.dart`
   - `lib/core/utils/`
   - widgets موجودة فعلاً داخل الفيتشر الحالي
2. تطابق جزئي → وسّع الموجود (parameter اختياري) بدل نسخة جديدة.
3. لا تطابق → أنشئ في المكان الصحيح (عام → `core/widgets`, خاص بالفيتشر → `feature/presentation/widgets`).
4. اذكر دايمًا: بحثت عن إيه، وفين، ولماذا قررت الإنشاء أو إعادة الاستخدام — هذا جزء من "الخطوة A" في `00-master.md`، ليس تفصيل اختياري.

> "ابحث ولم أجد شيء" بدون ذكر المسارات الفعلية اللي فُتحت = لم يتم البحث فعليًا، وهذا يُعتبر مخالفة للبروتوكول.

## 🔎 Self-check سريع لهذا الملف

```
[ ] تم ذكر مسارات البحث الفعلية في الخطوة A قبل إنشاء أي كود
[ ] لا تكرار لمنطق موجود في helpers.dart
[ ] لا تكرار لمنطق موجود في validators.dart / app_date_time.dart
[ ] أي helper/util جديد فعلي تم وضعه في المكان الصحيح، لا داخل widget/UI file
```
