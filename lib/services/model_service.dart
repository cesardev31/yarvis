// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ModelService {
  static final ModelService _instance = ModelService._internal();
  factory ModelService() => _instance;
  ModelService._internal();

  // API Key y URL de la API de Gemini
  static String get API_KEY =>
      dotenv.env['API_KEY'] ?? ''; // Reemplaza con tu clave de API
  static const String API_URL =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Stream controllers para progreso y mensajes
  final _loadingController = StreamController<String>.broadcast();
  Stream<String> get loadingStream => _loadingController.stream;

  // Método para procesar texto
  Future<String> processText(String text) async {
    _loadingController.add('Procesando texto...');

    try {
      final requestBody = {
        "contents": [
          {
            "parts": [
              {"text": text}
            ]
          }
        ]
      };

      final response = await http.post(
        Uri.parse('$API_URL?key=$API_KEY'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final generatedContent = jsonResponse['candidates']?[0]?['content']
                ?['parts']?[0]?['text'] ??
            'Sin respuesta';

        _loadingController.add('Texto procesado exitosamente');
        return generatedContent;
      } else {
        _loadingController.add(
            'Error en la solicitud: ${response.statusCode} ${response.body}');
        return 'Error al procesar el texto';
      }
    } catch (e) {
      _loadingController.add('Error: $e');
      return 'Ocurrió un error al procesar el texto';
    }
  }

  void dispose() {
    _loadingController.close();
  }
}
