import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  /// Inicializa el servicio de reconocimiento de voz
  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => print('Error de voz: $error'),
        onStatus: (status) => print('Estado de voz: $status'),
      );
    }
    return _isInitialized;
  }

  /// Comienza a escuchar la entrada de voz
  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) await initialize();

    await _speechToText.listen(
      localeId: 'es-ES',
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
    );
  }

  /// Detiene la escucha
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  /// Verifica si está escuchando activamente
  bool get isListening => _speechToText.isListening;
}
