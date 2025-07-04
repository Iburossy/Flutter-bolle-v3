// Modèle de message pour le chatbot

/// Énumération des types de messages possibles dans le chatbot
enum MessageType {
  /// Message envoyé par l'utilisateur
  user,
  
  /// Message envoyé par le bot
  bot,
  
  /// Message de type suggestion (boutons rapides)
  suggestion,
  
  /// Message de chargement (typing indicator)
  loading,
}

/// Modèle représentant un message dans la conversation du chatbot
class ChatMessage {
  /// Contenu textuel du message
  final String text;
  
  /// Type de message (utilisateur, bot, suggestion)
  final MessageType type;
  
  /// Horodatage du message
  final DateTime timestamp;
  
  /// Liste de suggestions/actions rapides associées au message (optionnel)
  final List<String>? quickReplies;

  /// Constructeur pour un nouveau message
  ChatMessage({
    required this.text,
    required this.type,
    List<String>? quickReplies,
    DateTime? timestamp,
  }) : 
    this.quickReplies = quickReplies,
    this.timestamp = timestamp ?? DateTime.now();
  
  /// Crée un message utilisateur
  factory ChatMessage.user(String text) {
    return ChatMessage(
      text: text,
      type: MessageType.user,
    );
  }
  
  /// Crée un message bot
  factory ChatMessage.bot(String text, {List<String>? quickReplies}) {
    return ChatMessage(
      text: text,
      type: MessageType.bot,
      quickReplies: quickReplies,
    );
  }
  
  /// Crée un message de chargement (typing indicator)
  factory ChatMessage.loading() {
    return ChatMessage(
      text: '...',
      type: MessageType.loading,
    );
  }
  
  /// Crée un message de suggestion
  factory ChatMessage.suggestion(String text) {
    return ChatMessage(
      text: text,
      type: MessageType.suggestion,
    );
  }
}
