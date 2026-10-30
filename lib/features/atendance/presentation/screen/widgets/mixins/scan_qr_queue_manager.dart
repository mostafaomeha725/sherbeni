import 'dart:collection';

class ScanQrQueueManager {
  final Set<String> _processingCodes = {};
  final Queue<String> _scanQueue = Queue<String>();
  bool _isProcessingQueue = false;
  final Map<String, DateTime> _scannedCodesMap = {};

  bool get isProcessingQueue => _isProcessingQueue;
  String? currentScannedCode;

  void cleanUpOldEntries(DateTime now, int maxSeconds) {
    _scannedCodesMap.removeWhere(
      (key, time) => now.difference(time).inSeconds >= maxSeconds,
    );
  }

  bool canAdd(String code) {
    if (_processingCodes.contains(code) || _scanQueue.contains(code)) {
      return false;
    }
    if (_scannedCodesMap.containsKey(code)) {
      return false;
    }
    return true;
  }

  void addToQueue(String code) {
    _scanQueue.add(code);
  }

  String? getNextToProcess() {
    if (_isProcessingQueue || _scanQueue.isEmpty) return null;

    _isProcessingQueue = true;
    final codeToProcess = _scanQueue.removeFirst();
    currentScannedCode = codeToProcess;
    _processingCodes.add(codeToProcess);
    
    return codeToProcess;
  }

  void finishProcessingCurrent() {
    if (currentScannedCode != null) {
      _processingCodes.remove(currentScannedCode!);
      _scannedCodesMap[currentScannedCode!] = DateTime.now();
      currentScannedCode = null;
    }
    _isProcessingQueue = false;
  }

  void removeProcessingCode(String? code) {
    if (code != null) {
      _processingCodes.remove(code);
    }
  }
}
