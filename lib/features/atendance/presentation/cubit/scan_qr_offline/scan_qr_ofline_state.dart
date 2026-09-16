part of 'scan_qr_ofline_cubit.dart';

@immutable
abstract class ScanQrOflineState {}

class ScanQrOflineInitial extends ScanQrOflineState {}

class ScanQrOflineLoading extends ScanQrOflineState {}

class ScanQrOflineSuccess extends ScanQrOflineState {
  final String message;
  final Map<String, dynamic> stats;
  final bool isSync; // Flag to indicate if this is a sync operation

  ScanQrOflineSuccess({
    required this.message,
    required this.stats,
    this.isSync = false,
  });
}

class ScanQrOflineFailure extends ScanQrOflineState {
  final String errorMessage;

  ScanQrOflineFailure(this.errorMessage);
}

class ScanQrOflineDuplicate extends ScanQrOflineState {
  final String message;

  ScanQrOflineDuplicate({required this.message});
}
