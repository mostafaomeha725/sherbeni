# 03 — Dependency Injection (get_it) و Error Handling (dartz)

## Failures الموحّدة

```dart
// core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'حدث خطأ في البيانات المحفوظة']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```

الـ Cubit يستقبل `Either<Failure, T>` ويحوّله لـ State بـ `.fold()`:

```dart
Future<void> login(String email, String password) async {
  emit(LoginLoading());
  final result = await loginUseCase(email: email, password: password);
  result.fold(
    (failure) => emit(LoginError(failure.message)),
    (user) => emit(LoginSuccess(user)),
  );
}
```

---

## get_it — التنظيم

```
lib/
└── core/
    └── di/
        ├── injection_container.dart      // التجميع الرئيسي
        └── features/
            └── auth_injection.dart        // كل feature بملفه
```

## الشكل القياسي لتسجيل feature

```dart
// core/di/features/auth_injection.dart
import 'package:get_it/get_it.dart';
import '../../../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/use_cases/login_use_case.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';

void initAuthInjection(GetIt sl) {
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
}
```

```dart
// core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'features/auth_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  initAuthInjection(sl);
  // initHomeInjection(sl);
}
```

## القواعد (حرفية، بدون استثناء)

| النوع | طريقة التسجيل |
|---|---|
| `Cubit` | `registerFactory` (نسخة جديدة كل مرة) |
| `UseCase` | `registerLazySingleton` |
| `Repository` | `registerLazySingleton` |
| `DataSource` | `registerLazySingleton` |

الوصول للـ Cubit في الـ UI:

```dart
BlocProvider(
  create: (_) => sl<AuthCubit>(),
  child: const LoginScreenBody(),
)
```

ممنوع استدعاء `sl<...>()` داخل أي `build()` مباشرة بدون `BlocProvider`.

## 🔎 Self-check سريع لهذا الملف

```
[ ] كل الأخطاء تمر بـ Either/Failure
[ ] Cubit مسجّل كـ Factory في get_it
[ ] UseCase/Repository/DataSource مسجّلين كـ LazySingleton
[ ] لا sl<...>() مباشر داخل build() بدون BlocProvider
[ ] كل feature له ملف injection خاص تحت core/di/features/
```
