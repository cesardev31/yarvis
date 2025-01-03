import 'package:flutter/material.dart';
import 'package:yarvis/screens/chat_screen.dart';
import '../services/model_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _loadingMessage = 'Iniciando...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final modelService = ModelService();

    setState(() {
      _loadingMessage = 'Verificando conexión con la API...';
    });

    try {
      final testResponse = await modelService.processText("Hello, Gemini API!");
      if (testResponse.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        }
      } else {
        setState(() {
          _loadingMessage = 'Error: No se recibió respuesta válida de la API.';
        });
      }
    } catch (e) {
      setState(() {
        _loadingMessage = 'Error al conectar con la API: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _loadingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
