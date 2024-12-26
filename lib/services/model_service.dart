// ignore_for_file: constant_identifier_names, await_only_futures, avoid_print, unused_local_variable

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

class ModelService {
  // Singleton pattern
  static final ModelService _instance = ModelService._internal();
  factory ModelService() => _instance;
  ModelService._internal();

  static const String MODEL_URL =
      'https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf';

  static const int MAX_TOKENS = 512;
  static const int VOCAB_SIZE = 32000;

  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _isDownloading = false;

  // Stream controller para el progreso
  final _progressController = StreamController<double>.broadcast();
  final _loadingController = StreamController<String>.broadcast();

  Stream<double> get progressStream => _progressController.stream;
  Stream<String> get loadingStream => _loadingController.stream;

  // Agregar getter para el estado de inicialización
  bool get isInitialized => _isInitialized;

  // Implementación básica de tokenización
  List<int> _simpleTokenize(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .expand((word) => word.codeUnits)
        .map((e) => e % VOCAB_SIZE)
        .toList();
  }

  Future<void> initializeModel() async {
    if (_isInitialized) return;
    if (_isDownloading) {
      _loadingController.add('Ya se está descargando el modelo...');
      return;
    }

    try {
      _loadingController.add('Iniciando carga del modelo...');
      _isDownloading = true;

      final modelFile = await _getModelFile();
      if (await modelFile.exists()) {
        _loadingController.add('Cargando modelo existente...');
        await _initializeInterpreter(modelFile);
        _loadingController.add('Modelo cargado exitosamente');
        return;
      }

      _loadingController.add('Descargando nuevo modelo...');
      await _downloadModel(modelFile);
      _loadingController.add('Inicializando modelo...');
      await _initializeInterpreter(modelFile);
      _loadingController.add('¡Modelo listo!');
    } catch (e) {
      _loadingController.add('Error al inicializar el modelo: $e');
      _isInitialized = false;
      rethrow;
    } finally {
      _isDownloading = false;
    }
  }

  Future<void> _initializeInterpreter(File modelFile) async {
    try {
      // Configurar opciones básicas
      final options = InterpreterOptions()..threads = 2;

      _interpreter = await Interpreter.fromFile(modelFile, options: options);
      _isInitialized = true;
      print('Intérprete inicializado correctamente');
    } catch (e) {
      print('Error al inicializar intérprete: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<File> _getModelFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/llama2_chat.gguf');
  }

  Future<void> _downloadModel(File modelFile) async {
    try {
      final response = await http.Client().send(
        http.Request('GET', Uri.parse(MODEL_URL))
      );

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;

      final fileStream = modelFile.openWrite();
      await response.stream.map((chunk) {
        receivedBytes += chunk.length;
        // Calcular y emitir el progreso
        final progress = (receivedBytes / totalBytes) * 100;
        _progressController.add(progress);
        return chunk;
      }).pipe(fileStream);

      await fileStream.flush();
      await fileStream.close();
    } catch (e) {
      print('Error en la descarga: $e');
      rethrow;
    }
  }

  Future<String> processText(String text) async {
    if (!_isInitialized) {
      try {
        await initializeModel();
      } catch (e) {
        return 'Error al inicializar el modelo: $e';
      }
    }

    try {
      final prompt = '''[INST] $text [/INST]''';

      var inputTensor = _interpreter!.getInputTensor(0);
      var outputTensor = _interpreter!.getOutputTensor(0);

      // Tokenizar usando nuestra implementación simple
      var tokens = _simpleTokenize(prompt);

      var input = List.filled(1, List.filled(MAX_TOKENS, 0), growable: false);
      for (var i = 0; i < tokens.length && i < MAX_TOKENS; i++) {
        input[0][i] = tokens[i];
      }

      var output = List.generate(
        1,
        (i) => List.filled(VOCAB_SIZE, 0.0),
        growable: false,
      );

      _interpreter?.run(input, output);

      return _decodeOutput(output[0]);
    } catch (e) {
      print('Error en procesamiento: $e');
      return 'Lo siento, ocurrió un error al procesar el texto';
    }
  }

  String _decodeOutput(List<double> logits) {
    var indices = List.generate(logits.length, (i) => i)
      ..sort((a, b) => logits[b].compareTo(logits[a]));

    // Convertir los índices más probables a caracteres
    return indices
        .take(50) // Tomar los 50 tokens más probables
        .map((i) => String.fromCharCode(i % 128)) // Convertir a ASCII
        .join();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
    _loadingController.close();
  }
}
