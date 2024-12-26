// ignore_for_file: constant_identifier_names, await_only_futures, avoid_print, unused_local_variable

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ModelService {
  static const String MODEL_URL =
      'https://storage.googleapis.com/mediapipe-models/text_classifier/bert_classifier/float32/1/bert_classifier.tflite';

  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _isDownloading = false;

  Future<void> initializeModel() async {
    if (_isInitialized) return;
    if (_isDownloading) {
      print('Ya se está descargando el modelo...');
      return;
    }

    try {
      print('Iniciando carga del modelo...');
      _isDownloading = true;

      // Intentar cargar el modelo local primero
      final modelFile = await _getModelFile();
      if (await modelFile.exists()) {
        print('Usando modelo local existente');
        await _initializeInterpreter(modelFile);
        return;
      }

      // Si no existe, descargar
      print('Descargando nuevo modelo...');
      await _downloadModel(modelFile);
      await _initializeInterpreter(modelFile);
    } catch (e) {
      print('Error al inicializar el modelo: $e');
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
    return File('${appDir.path}/bert_model.tflite');
  }

  Future<void> _downloadModel(File modelFile) async {
    try {
      final response = await http.get(Uri.parse(MODEL_URL));
      if (response.statusCode != 200) {
        throw Exception('Error al descargar modelo: ${response.statusCode}');
      }
      await modelFile.writeAsBytes(response.bodyBytes);
      print('Modelo descargado correctamente');
    } catch (e) {
      print('Error al descargar modelo: $e');
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
      // Implementación simplificada para pruebas
      final input = [_tokenizeText(text)];
      var output = List.filled(1, List.filled(1, 0.0));

      _interpreter?.run(input, output);

      // Respuesta temporal mientras debuggeamos
      return "Procesado: $text\nSalida del modelo: ${output[0][0]}";
    } catch (e) {
      print('Error en procesamiento: $e');
      return 'Error al procesar el texto: $e';
    }
  }

  List<double> _tokenizeText(String text) {
    // Tokenización simplificada para pruebas
    return text
        .split(' ')
        .map((word) => word.length.toDouble())
        .take(512)
        .toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
