// ignore_for_file: constant_identifier_names, avoid_print, unused_local_variable

import 'package:tflite_flutter/tflite_flutter.dart';

class LLMService {
  Interpreter? _interpreter;
  static const int MAX_LENGTH = 384;

  Future<void> initialize() async {
    try {
      print('Inicializando modelo BERT...');
      _interpreter = await Interpreter.fromAsset('assets/bert_qa/model.tflite');
      print('Modelo BERT cargado exitosamente');

      // Configurar opciones del intérprete
      final options = InterpreterOptions()..threads = 4;
      _interpreter?.allocateTensors();

      print('Configuración del modelo completada');
    } catch (e) {
      print('Error al inicializar BERT: $e');
    }
  }

  Future<String> processQuery(String query) async {
    try {
      if (_interpreter == null) {
        return "El modelo no está inicializado";
      }

      List<int> inputIds = tokenize(query);

      var inputShape = [1, MAX_LENGTH];
      var outputShape = [1, MAX_LENGTH];

      var inputs = [inputIds];
      var outputs = List.filled(outputShape[0] * outputShape[1], 0.0);

      _interpreter?.run(inputs, outputs);

      String response = postProcess(outputs);
      return response;
    } catch (e) {
      print('Error en el procesamiento: $e');
      return "Lo siento, hubo un error al procesar tu pregunta";
    }
  }

  List<int> tokenize(String text) {
    return text.split(' ').map((word) => word.hashCode % 1000).toList();
  }

  String postProcess(List<double> outputs) {
    return "Estoy procesando tu consulta...";
  }

  void dispose() {
    _interpreter?.close();
  }
}
