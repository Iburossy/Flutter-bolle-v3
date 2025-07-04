import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/chatbot_service.dart';

/// Provider pour gérer l'état du chatbot et la conversation
class ChatbotProvider extends ChangeNotifier {
  /// Service de chatbot pour traiter les messages
  final ChatbotService _chatbotService = ChatbotService();
  
  /// Liste des messages dans la conversation
  final List<ChatMessage> _messages = [];
  
  /// Obtenir la liste des messages (copie pour éviter les modifications directes)
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  
  /// Constructeur qui initialise le chatbot avec un message de bienvenue
  ChatbotProvider() {
    // Initialiser le chatbot avec un message de bienvenue de façon asynchrone
    _initChatbot();
  }
  
  /// Initialisation asynchrone du chatbot
  Future<void> _initChatbot() async {
    try {
      // Obtenir le message de bienvenue
      final welcomeMessage = await _chatbotService.getWelcomeMessage();
      _messages.add(welcomeMessage);
      notifyListeners();
    } catch (e) {
      // Fallback en cas d'erreur
      _messages.add(ChatMessage.bot(
        'Bonjour ! Je suis le chatbot de l\'application Yollë. Comment puis-je vous aider ?',
        quickReplies: [
          'Quels types de problèmes puis-je signaler ?',
          'Comment fonctionne l\'application ?',
          'Comment créer une alerte ?',
        ],
      ));
      notifyListeners();
    }
  }
  
  /// Ajouter un message utilisateur et obtenir une réponse du bot
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    // Ajouter le message de l'utilisateur
    final userMessage = ChatMessage.user(text);
    _messages.add(userMessage);
    notifyListeners();
    
    // Ajouter un message de chargement temporaire
    int loadingIndex = -1;
    
    // Effet de "typing" avec un léger délai
    Future.delayed(const Duration(milliseconds: 300), () {
      final loadingMessage = ChatMessage.loading();
      _messages.add(loadingMessage);
      loadingIndex = _messages.length - 1;
      notifyListeners();
      
      // Obtenir la réponse du bot de façon asynchrone
      _getBotResponse(text, loadingIndex);
    });
  }
  
  /// Obtenir la réponse du bot de façon asynchrone
  Future<void> _getBotResponse(String text, int loadingIndex) async {
    try {
      // Traiter le message et obtenir la réponse
      final botResponse = await _chatbotService.processUserMessage(text);
      
      // Si l'index de chargement est valide, remplacer le message de chargement
      if (loadingIndex >= 0 && loadingIndex < _messages.length) {
        _messages[loadingIndex] = botResponse;
      } else {
        // Sinon, ajouter simplement la réponse à la fin
        _messages.add(botResponse);
      }
    } catch (e) {
      // En cas d'erreur, afficher un message d'erreur
      final errorMessage = ChatMessage.bot(
        'Désolé, je rencontre des difficultés à traiter votre demande. Pourriez-vous reformuler votre question ?',
      );
      
      // Remplacer le message de chargement par l'erreur
      if (loadingIndex >= 0 && loadingIndex < _messages.length) {
        _messages[loadingIndex] = errorMessage;
      } else {
        _messages.add(errorMessage);
      }
    } finally {
      notifyListeners();
    }
  }
  
  /// Traiter une suggestion rapide sélectionnée par l'utilisateur
  void handleSuggestion(String suggestion) {
    sendMessage(suggestion);
  }
  
  /// Obtenir les suggestions initiales pour le chatbot
  Future<List<String>> getInitialSuggestions() async {
    try {
      return await _chatbotService.getGeneralSuggestions();
    } catch (e) {
      // En cas d'erreur, retourner des suggestions par défaut
      return [
        'Quels types de problèmes puis-je signaler ?',
        'Comment fonctionne l\'application ?',
        'Comment créer une alerte ?',
        'Quels services sont disponibles ?',
      ];
    }
  }
}
