import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/auth/domain/entities/user_entity.dart';
import 'package:qrattendance/features/auth/domain/repositories/auth_repository.dart';
import 'package:qrattendance/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:qrattendance/features/auth/presentation/cubit/logout_cubit/logout_cubit.dart';
import 'package:qrattendance/features/auth/presentation/cubit/logout_cubit/logout_state.dart';

class FakeAuthRepository implements AuthRepository {
  Future<Either<Failure, void>> Function()? onLogout;
  int logoutCalls = 0;

  @override
  Future<Either<Failure, void>> logout() async {
    logoutCalls++;
    return onLogout?.call() ?? const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
    required String deviceId,
  }) async => throw UnimplementedError();
}

void main() {
  late FakeAuthRepository repository;
  late LogoutCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = LogoutCubit(LogoutUseCase(repository));
  });

  tearDown(() async => cubit.close());

  test('confirmed logout emits loading then success', () async {
    final states = <LogoutState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.logout();
    await cubit.logout();
    await Future<void>.delayed(Duration.zero);

    expect(states, [isA<LogoutLoading>(), isA<LogoutSuccess>()]);
    expect(repository.logoutCalls, 1);
    await subscription.cancel();
  });

  test('API failure emits failure and never emits success', () async {
    repository.onLogout = () async =>
        const Left(ServerFailure(message: 'Server logout failed'));
    final states = <LogoutState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.logout();
    await Future<void>.delayed(Duration.zero);

    expect(states, [isA<LogoutLoading>(), isA<LogoutFailure>()]);
    expect((states.last as LogoutFailure).message, 'Server logout failed');
    expect(states.whereType<LogoutSuccess>(), isEmpty);
    await subscription.cancel();
  });

  test(
    'duplicate taps while request is pending issue one repository call',
    () async {
      final response = Completer<Either<Failure, void>>();
      repository.onLogout = () => response.future;
      final states = <LogoutState>[];
      final subscription = cubit.stream.listen(states.add);

      final first = cubit.logout();
      await Future<void>.delayed(Duration.zero);
      await cubit.logout();
      response.complete(const Right(null));
      await first;
      await Future<void>.delayed(Duration.zero);

      expect(repository.logoutCalls, 1);
      expect(states.whereType<LogoutLoading>(), hasLength(1));
      expect(states.whereType<LogoutSuccess>(), hasLength(1));
      await subscription.cancel();
    },
  );
}
