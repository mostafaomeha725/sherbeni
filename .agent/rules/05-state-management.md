# 05 — State Management (Cubit/Bloc فقط)

## مسموح

```
Cubit, BlocBuilder, BlocListener, BlocConsumer
```

## ممنوع

```
setState() لمنطق business logic أو shared state
API calls / validation / calculations داخل الـ UI مباشرة
```

> **استثناء `setState`:** مسموح **فقط** لحالة UI محلية بحتة لا تخرج عن حدود الـ widget نفسه (مثال: toggle لـ `obscureText` في حقل باسورد واحد محلي، أو animation محلي). أي حالة تؤثر على منطق أو تنتقل لأكثر من widget = Cubit، بدون استثناء.

## شكل State القياسي

```dart
// presentation/cubit/login_state.dart
abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
  @override
  List<Object?> get props => [message];
}
```

## شكل Cubit القياسي

```dart
// presentation/cubit/login_cubit.dart
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  LoginCubit(this.loginUseCase) : super(LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    final result = await loginUseCase(email: email, password: password);
    result.fold(
      (failure) => emit(LoginError(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }
}
```

## 🔎 Self-check سريع لهذا الملف

```
[ ] لا setState لمنطق غير محلي بحت
[ ] لا API calls/validation/calculations داخل UI
[ ] الـ State كلاسات منفصلة لكل حالة، extends Equatable
[ ] الـ Cubit بيستخدم .fold() على نتيجة UseCase، لا try/catch مباشر
```
