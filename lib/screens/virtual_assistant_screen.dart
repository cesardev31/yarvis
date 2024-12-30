import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/chat_message.dart';
import '../widgets/input_bar.dart';
import '../services/model_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';

class VirtualAssistantScreen extends StatefulWidget {
  const VirtualAssistantScreen({super.key});

  @override
  State<VirtualAssistantScreen> createState() => _VirtualAssistantScreenState();
}

class _VirtualAssistantScreenState extends State<VirtualAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ModelService _modelService = ModelService();
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await Future.wait([
        _speechService.initialize(),
        _ttsService.initialize(),
      ]);
    } catch (e) {
      print('Error al inicializar servicios: $e');
    }
  }

  void _addMessage(String text,
      {bool isUser = true, bool isProcessing = false}) {
    setState(() {
      _messages.add(ChatMessage(
        sender: isUser ? 'usuario' : 'sistema',
        message: text,
        isProcessing: isProcessing,
        isUser: isUser,
      ));
    });
  }

  Future<void> _processInput(String text) async {
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);
    _controller.clear();
    _addMessage(text);

    try {
      _addMessage('',
          isUser: false,
          isProcessing: true); // Mensaje en estado de procesamiento
      final response = await _modelService.processText(text);

      setState(() {
        _messages.removeLast(); // Elimina el mensaje de "procesando"
        _addMessage(response, isUser: false);
      });
    } catch (e) {
      _addMessage('Error al procesar tu mensaje.', isUser: false);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _startListening() async {
    await _speechService.startListening((text) {
      _processInput(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Virtual'),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final reversedIndex = _messages.length - 1 - index;
                return ChatMessageWidget(
                  message: _messages[reversedIndex],
                );
              },
            ),
          ),
          InputBar(
            controller: _controller,
            isProcessing: _isProcessing,
            isListening: _speechService.isListening,
            onSubmitted: _processInput,
            onMicPressed: _startListening,
            onMicReleased: _speechService.stopListening,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _ttsService.stop();
    super.dispose();
  }
}
