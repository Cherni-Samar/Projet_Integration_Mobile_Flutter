import 'package:flutter_tts/flutter_tts.dart';

class VocalService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    try {
      await _tts.setLanguage("fr-FR");
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      print("✅ Moteur TTS Initialisé");
    } catch (e) {
      print("❌ Erreur Initialisation TTS: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      print("🗣️ Vocal service: $text");
      var result = await _tts.speak(text);
      if (result == 1) print("🔊 Lecture en cours...");
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
