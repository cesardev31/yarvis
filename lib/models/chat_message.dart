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
    required bool isUser,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => sender == 'usuario';
}
