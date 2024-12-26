class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isProcessing;

  ChatMessage({
    required this.sender,
    required this.message,
    this.isProcessing = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == 'usuario';
}
