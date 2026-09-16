# 02 — Clean Architecture (الطبقات)

```
presentation → domain → data
```

## القواعد الصارمة

- UI لا يصل إطلاقًا لـ Repository أو Data Source.
- Cubit يستدعي **UseCase فقط**.
- UseCase يستدعي Repository (الـ abstract interface من domain).
- Repository Implementation (في data) يستدعي Data Source.
- طبقة Domain **بدون أي import خاص بـ Flutter** — Dart نقي 100%.
- كل الأخطاء تمر بـ `Either<Failure, T>` — لا exception خام يتسرب فوق Repository.

## شكل UseCase القياسي (إلزامي لكل use case، بدون استثناء)

```dart
// domain/use_cases/login_use_case.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
```

- كلاس مستقل، ملف خاص به.
- دايمًا `call()` واحدة فقط — يتصرف كـ function: `loginUseCase(email: ..., password: ...)`.
- يرجع دايمًا `Future<Either<Failure, T>>` (أو `Stream<...>` لو realtime).

## شكل Repository (Interface + Implementation)

```dart
// domain/repositories/auth_repository.dart  — Dart نقي
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
}
```

```dart
// data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.login(email, password);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NoInternetException {
      return const Left(NetworkFailure());
    }
  }
}
```

> الـ `try/catch` مسموح **فقط هنا**، في Repository Implementation، لتحويل Exception إلى Failure نظيفة. ممنوع try/catch بعد ذلك في Cubit أو UI.

## هيكل الفيتشر (ثابت دايمًا)

```
feature_name/
├── data/
│   ├── models/
│   ├── data_sources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── use_cases/
└── presentation/
    ├── cubit/
    ├── screens/
    └── widgets/
```

ممنوع تجميع كود الفيتشر في ملف واحد حتى لو الفيتشر صغير.

## 🔎 Self-check سريع لهذا الملف

```
[ ] الـ Cubit يستدعي UseCase فقط (لا repository مباشر)
[ ] UseCase شكله: كلاس + call() + يرجع Either<Failure, T>
[ ] domain خالي من أي import خاص بـ Flutter
[ ] لا Exception خام يتسرب لأعلى من Repository
[ ] هيكل الفيتشر الكامل (data/domain/presentation) موجود ولو الفيتشر صغير
```
