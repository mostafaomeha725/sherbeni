import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioHelper {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playSound(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  static Future<void> playSuccess() async {
    await playSound('sounds/success.mp3');
  }

  static Future<void> playError() async {
    await playSound('sounds/error.mp3');
  }

  static Future<void> playDuplicate() async {
    await playSound('sounds/duplicate.mp3');
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
