import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: message.isProcessing
            ? _buildProcessingIndicator()
            : _buildMessageText(),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Procesando...',
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageText() {
    return Text(
      message.message,
      style: TextStyle(
        color: message.isUser ? Colors.white : Colors.black,
        fontSize: 16,
      ),
    );
  }
}
