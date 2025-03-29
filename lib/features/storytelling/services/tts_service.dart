// lib/features/storytelling/services/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts flutterTts = FlutterTts();
  bool isReading = false;
  Function? onCompletionCallback;

  Future<void> initialize() async {
    await flutterTts.setLanguage('vi-VN');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      if (onCompletionCallback != null) {
        onCompletionCallback!();
      }
    });
  }

  Future<void> setLanguage(String language) async {
    await flutterTts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    await flutterTts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    await flutterTts.setPitch(pitch);
  }

  Future<void> setVolume(double volume) async {
    await flutterTts.setVolume(volume);
  }

  Future<void> speak(String text) async {
    isReading = true;
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    isReading = false;
    await flutterTts.stop();
  }

  void setCompletionCallback(Function callback) {
    onCompletionCallback = callback;
  }

  void dispose() {
    flutterTts.stop();
  }
}