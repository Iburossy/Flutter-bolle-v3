import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/message_model.dart';

/// Widget pour afficher un message dans le chatbot
class ChatMessageWidget extends StatelessWidget {
  /// Le message à afficher
  final ChatMessage message;
  
  /// Callback pour gérer les clics sur les suggestions rapides
  final Function(String)? onSuggestionTap;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.user:
        return _buildUserMessage(context);
      case MessageType.bot:
        return _buildBotMessage(context);
      case MessageType.suggestion:
        return _buildSuggestionMessage(context);
      case MessageType.loading:
        return _buildLoadingMessage(context);
    }
  }

  /// Construit un message envoyé par l'utilisateur
  Widget _buildUserMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 53, 126, 120),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color.fromARGB(255, 53, 126, 120),
            child: Icon(
              Icons.person,
              size: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un message envoyé par le bot
  Widget _buildBotMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Image.asset(
              'assets/images/yolle logo.png',
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (message.quickReplies != null && message.quickReplies!.isNotEmpty)
                  _buildQuickReplies(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un message de suggestion/bouton rapide
  Widget _buildSuggestionMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          if (onSuggestionTap != null) {
            onSuggestionTap!(message.text);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: const Color.fromARGB(255, 53, 126, 120),
              width: 1.0,
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Color.fromARGB(255, 53, 126, 120),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Construit un message de chargement avec animation de points
  Widget _buildLoadingMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar du bot
          CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 53, 126, 120),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 18.0,
            ),
          ),
          const SizedBox(width: 8.0),
          // Bulle avec l'indicateur de chargement
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                _TypingDot(delay: 300),
                _TypingDot(delay: 600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit les boutons de réponse rapide
  Widget _buildQuickReplies(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: message.quickReplies!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                if (onSuggestionTap != null) {
                  onSuggestionTap!(message.quickReplies![index]);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  message.quickReplies![index],
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Formater l'heure du message
  String _formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }
}

/// Widget pour afficher un point d'animation dans l'indicateur de chargement
class _TypingDot extends StatefulWidget {
  /// Délai avant le début de l'animation en millisecondes
  final int delay;

  const _TypingDot({Key? key, required this.delay}) : super(key: key);

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Créer le contrôleur d'animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    
    // Créer une animation qui fait monter puis descendre le point
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
    ]).animate(_controller);

    // Démarrer l'animation après le délai spécifié
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          height: 8.0 + 4.0 * _animation.value,
          width: 8.0 + 4.0 * _animation.value,
          decoration: BoxDecoration(
            color: Color.fromARGB(
              255,
              53, 
              126,
              120 - (40 * _animation.value).toInt(),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
