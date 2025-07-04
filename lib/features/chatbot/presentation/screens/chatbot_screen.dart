import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/chatbot_provider.dart';
import '../widgets/chat_message_widget.dart';

/// Écran principal du chatbot
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  /// Contrôleur pour le champ de texte
  final TextEditingController _textController = TextEditingController();
  
  /// Contrôleur pour le défilement de la liste des messages
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatbotProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Assistant Yollë',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 53, 126, 120),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  /// Construit la liste des messages
  Widget _buildMessageList() {
    return Consumer<ChatbotProvider>(
      builder: (context, chatbotProvider, child) {
        final messages = chatbotProvider.messages;
        
        // Faire défiler automatiquement vers le bas lorsqu'un nouveau message est ajouté
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 16.0),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return ChatMessageWidget(
              message: messages[index],
              onSuggestionTap: (suggestion) {
                chatbotProvider.handleSuggestion(suggestion);
              },
            );
          },
        );
      },
    );
  }

  /// Construit la zone de saisie de texte
  Widget _buildInputArea() {
    return Consumer<ChatbotProvider>(
      builder: (context, chatbotProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Posez votre question...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (text) {
                    _sendMessage(chatbotProvider);
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 53, 126, 120),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    _sendMessage(chatbotProvider);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Envoie le message saisi par l'utilisateur
  void _sendMessage(ChatbotProvider chatbotProvider) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      chatbotProvider.sendMessage(text);
      _textController.clear();
    }
  }
}
