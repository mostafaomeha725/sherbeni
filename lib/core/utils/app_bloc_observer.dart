import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/utils/safe_print.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver();
  final Set<BlocBase> _aliveBlocs = {};

  @override
  void onCreate(BlocBase bloc) {
    _aliveBlocs.add(bloc);
    log('${bloc.arrangedString} was created');
    log('Current Alive Cubits (onCreate) : ${_aliveBlocs.arrangedString}');
    log('Current Alive Cubits Numbers (onCreate) : = ${_aliveBlocs.length}');
    super.onCreate(bloc);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) {
      safePrint("APP CUBIT ${change.toString()} end##");
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    safePrint("APP CUBIT transition ${transition.toString()} end##");
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    safePrint('APP CUBIT onError => ${error.toString()}');
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    _aliveBlocs.remove(bloc);
    log('${bloc.arrangedString} was closed');
    log('Current Alive Cubits (onClose) : ${_aliveBlocs.arrangedString}');
    log('Current Alive Cubits Numbers (onClose) : ${_aliveBlocs.length}');
    safePrint(
      'APP CUBIT onClose isClosed => ${bloc.toString()} ${bloc.isClosed.toString()}',
    );
    super.onClose(bloc);
  }
}

extension BlocBaseExtension on BlocBase {
  String get arrangedString => '$runtimeType($hashCode)';
}

extension BlocBaseIterableExtension on Iterable<BlocBase> {
  String get arrangedString => '${map((bloc) => bloc.arrangedString)}';
}

extension BlocBaseNumberExtension on Iterable<BlocBase> {
  int get getCubitsCount => length;
}
