import 'package:flutter/material.dart';

class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isProcessing;
  final bool isListening;
  final Function(String) onSubmitted;
  final VoidCallback onMicPressed;
  final VoidCallback onMicReleased;

  const InputBar({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.isListening,
    required this.onSubmitted,
    required this.onMicPressed,
    required this.onMicReleased,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isProcessing,
              decoration: InputDecoration(
                hintText: isProcessing
                    ? 'Esperando respuesta...'
                    : 'Escribe un comando...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isProcessing ? Colors.grey[200] : Colors.white,
                prefixIcon: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : null,
              ),
              onSubmitted: isProcessing ? null : onSubmitted,
              readOnly: isProcessing,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTapDown: isProcessing ? null : (_) => onMicPressed(),
            onTapUp: isProcessing ? null : (_) => onMicReleased(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isProcessing
                    ? Colors.grey
                    : (isListening ? Colors.red : Colors.blue),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
