# طريقة التركيب في Antigravity

1. خذ مجلد `.agents/rules` كامل (بكل ملفاته الـ 8) وضعه في **جذر مشروع Flutter** (نفس مكان `pubspec.yaml`)، بحيث يكون عندك:

```
your_flutter_project/
├── pubspec.yaml
├── lib/
└── .agents/
    └── rules/
        ├── 00-master.md
        ├── 01-stack-and-bans.md
        ├── 02-architecture-layers.md
        ├── 03-di-and-errors.md
        ├── 04-screen-and-widget-structure.md
        ├── 05-state-management.md
        ├── 06-helpers-utils-reuse.md
        └── 07-self-review-checklist.md
```

2. افتح المشروع في Antigravity. الـ IDE بيقرأ تلقائيًا الملفات تحت `.agents/rules/` كـ Workspace Rules.

3. ملف `00-master.md` هو نقطة الدخول — فيه `@./01-stack-and-bans.md` وما يليها، وده syntax الربط الرسمي في Antigravity اللي بيخليه يحمّل باقي الملفات تلقائيًا لما يحتاجهم.

## لو عايز تتأكد إن الربط شغال

اكتب في الـ Agent chat:

```
هل الـ rules متطبقة؟ اذكر لي القواعد الموجودة في 02-architecture-layers.md
```

لو الـ Agent قدر يلخّص محتوى ملف 02 بدون ما تلصقه له يدويًا، يبقى الربط شغال صحيح.

## ليه قسّمنا الملف الأصلي؟

- كل ملف موضوع واحد بس، وحجمه صغير جدًا (أقصى ملف 3,744 حرف من إجمالي حد 12,000 حرف لكل ملف في Antigravity) — يقلل فرصة إن قاعدة "تضيع" في وسط نص طويل.
- ملف `00-master.md` فيه **بروتوكول إلزام فعلي**: لازم الـ Agent يكتب فحص قبل الكتابة، وlabel لكل ملف وقت إنشائه، وchecklist معبّاة فعليًا (✅/❌) بعد الكتابة — مش مجرد نص توضيحي بيتقرا وينتسي.
- ده مش ضمان 100%، لكنه بيقلل احتمال الفوات بشكل كبير، وأهم من كل ده: بيخليك تلاحظ فورًا لو حاجة اتفوتت (لأنها هتظهر ❌ في الـ checklist) بدل ما تكتشفها بعد كده وانت بتراجع الكود يدويًا.
