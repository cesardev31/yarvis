// ignore_for_file: constant_identifier_names, await_only_futures, avoid_print, unused_local_variable

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;

class ModelService {
  // Singleton pattern
  static final ModelService _instance = ModelService._internal();
  factory ModelService() => _instance;
  ModelService._internal();

  // Cambiamos a un modelo TFLite compatible
  static const String MODEL_URL =
      'https://storage.googleapis.com/mediapipe-models/text/bert_qa/float32/1/bert_qa.tflite';

  //'https://storage.googleapis.com/download.tensorflow.org/models/tflite/bert_qa.tflite';
  // O alternativamente:

  static const int MAX_TOKENS = 384;
  static const int VOCAB_SIZE = 30522; // Tamaño del vocabulario BERT

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
      final options = InterpreterOptions()..threads = 2;
/*         ..addDelegate(
            GpuDelegateV2()); // Agregar aceleración GPU si está disponible */

      _interpreter = await Interpreter.fromFile(
        modelFile,
        options: options,
      );

      // Verificar que el modelo se cargó correctamente
      var inputTensors = _interpreter!.getInputTensors();
      var outputTensors = _interpreter!.getOutputTensors();

      print('Tensores de entrada: ${inputTensors.length}');
      print('Tensores de salida: ${outputTensors.length}');

      _isInitialized = true;
      _loadingController.add('Modelo inicializado correctamente');
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
      // Verificar espacio disponible (necesitamos ~500MB para estar seguros)
      final directory = await getApplicationDocumentsDirectory();
      final available = await _getAvailableSpace(directory);
      const requiredSpace = 500 * 1024 * 1024; // 500MB

      if (available < requiredSpace) {
        throw Exception('Se necesitan al menos 500MB de espacio libre');
      }

      _loadingController.add('Iniciando descarga del modelo...');

      final response =
          await http.Client().send(http.Request('GET', Uri.parse(MODEL_URL)));

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;

      await modelFile.parent.create(recursive: true);

      final fileStream = modelFile.openWrite();
      await response.stream.map((chunk) {
        receivedBytes += chunk.length;
        final progress = (receivedBytes / totalBytes) * 100;
        _progressController.add(progress);

        // Actualizar mensaje de progreso
        if (progress % 10 == 0) {
          // Cada 10%
          _loadingController
              .add('Descargando: ${progress.toStringAsFixed(1)}%');
        }

        return chunk;
      }).pipe(fileStream);

      await fileStream.flush();
      await fileStream.close();

      _loadingController.add('¡Descarga completada!');
    } catch (e) {
      _loadingController.add('Error: $e');
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
      var inputTensor = _interpreter!.getInputTensor(0);
      var outputTensor = _interpreter!.getOutputTensor(0);

      // Preparar entrada para BERT
      var input = List.filled(1, List.filled(MAX_TOKENS, 0), growable: false);
      var tokens = _simpleTokenize(text);

      for (var i = 0; i < tokens.length && i < MAX_TOKENS; i++) {
        input[0][i] = tokens[i];
      }

      // Preparar salida
      var outputShape = outputTensor.shape;
      var output = List.generate(
        outputShape[0],
        (i) => List.filled(outputShape[1], 0.0),
        growable: false,
      );

      // Ejecutar inferencia
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

  Future<int> _getAvailableSpace(Directory directory) async {
    try {
      if (Platform.isAndroid) {
        try {
          final df = await Process.run('df', [directory.path]);
          if (df.exitCode == 0) {
            final lines = df.stdout.toString().split('\n');
            if (lines.length > 1) {
              final values = lines[1].split(RegExp(r'\s+'));
              return int.parse(values[3]) * 1024; // Convertir KB a bytes
            }
          }
        } catch (e) {
          print('Error al ejecutar df: $e');
        }
      }

      // Método alternativo si el anterior falla o para iOS
      final stat = await directory.stat();
      final pathSize = await _getFolderSize(directory);
      // Estimación aproximada del espacio disponible
      return stat.size - pathSize;
    } catch (e) {
      print('Error al verificar espacio disponible: $e');
      // Retornar un valor bajo para forzar la verificación de espacio
      return 0;
    }
  }

  Future<int> _getFolderSize(Directory directory) async {
    int totalSize = 0;
    try {
      await for (final file in directory.list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    } catch (e) {
      print('Error al calcular tamaño de carpeta: $e');
    }
    return totalSize;
  }
}
