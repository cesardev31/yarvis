import 'package:flutter/material.dart';
import 'package:yarvis/widgets/input_bar.dart';
import '../models/chat_message.dart';
import '../services/model_service.dart';
import '../widgets/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;
  final ModelService _modelService = ModelService();

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        message: text,
        isUser: true,
        isProcessing: false,
        sender: '',
      ));
    });

    _controller.clear();

    _processInput(text);
  }

  Future<void> _processInput(String text) async {
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);
    _controller.clear();
    _addMessage(text);

    try {
      _addMessage('', isUser: false, isProcessing: true);

      final response = await _modelService.processText(text);

      setState(() {
        _messages.removeLast();
        _addMessage(response, isUser: false);
      });
    } catch (e) {
      _addMessage('Error al procesar tu mensaje.', isUser: false);
    } finally {
      setState(() => _isProcessing = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return ChatMessageWidget(message: message);
              },
            ),
          ),
          // Barra de entrada
          InputBar(
            controller: _controller,
            isProcessing: _isProcessing,
            isListening: false,
            onSubmitted: _handleSubmitted,
            onMicPressed: () {},
            onMicReleased: () {},
          ),
        ],
      ),
    );
  }
}
