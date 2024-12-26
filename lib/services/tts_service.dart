import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Inicializa el servicio de texto a voz
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _flutterTts.setLanguage('es-ES');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.9);
      _isInitialized = true;
    }
  }

  /// Convierte texto a voz
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    await _flutterTts.speak(text);
  }

  /// Detiene la reproducción
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
