import 'dart:async';

import '../models/message_model.dart';
import '../models/conversation_context_model.dart';
import 'intent_classifier_service.dart';
import 'chatbot_data_service.dart';

/// Service gérant la logique du chatbot et les réponses aux questions
class ChatbotService {
  /// Service de classification des intentions
  final IntentClassifierService _intentClassifier = IntentClassifierService();
  
  /// Service pour accéder aux données dynamiques
  final ChatbotDataService _dataService = ChatbotDataService();
  
  /// Contexte de la conversation actuelle
  final ConversationContext _context = ConversationContext();
  
  /// Indique si le service a été initialisé avec les données utilisateur
  bool _isInitialized = false;
  
  /// Initialiser le chatbot avec les données utilisateur
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Charger les informations utilisateur
    try {
      // Récupérer le profil utilisateur
      final userProfile = await _dataService.getUserProfile();
      if (userProfile != null) {
        _context.userId = userProfile.id;
        _context.userName = userProfile.fullName;
      }
      
      // Charger l'historique des conversations
      final conversationHistory = await _dataService.getConversationHistory();
      if (conversationHistory.isNotEmpty) {
        // Analyser l'historique pour déterminer les sujets récents
        final List<String> recentTopics = [];
        for (final message in conversationHistory) {
          if (message['content'] != null && message['role'] == 'user') {
            final analysis = _intentClassifier.classifyIntent(message['content']);
            if (analysis.intent != IntentClassifierService.INTENT_UNKNOWN &&
                !recentTopics.contains(analysis.intent)) {
              recentTopics.add(analysis.intent);
              if (recentTopics.length >= 3) break; // Limiter à 3 sujets récents
            }
          }
        }
        _context.recentTopics = recentTopics;
        
        // Restaurer le dernier sujet de conversation s'il existe
        if (conversationHistory.length >= 2) {
          final lastBotMessage = conversationHistory.lastWhere(
              (msg) => msg['role'] == 'assistant',
              orElse: () => {});
          if (lastBotMessage.isNotEmpty) {
            final analysis = _intentClassifier.classifyIntent(lastBotMessage['content'] ?? '');
            if (analysis.intent != IntentClassifierService.INTENT_UNKNOWN) {
              _context.currentTopic = analysis.intent;
            }
          }
        }
      }
      
      // Charger les préférences utilisateur
      final preferences = await _dataService.getChatbotPreferences();
      _context.useUserName = preferences['useUserName'] ?? true;
      _context.suggestionsEnabled = preferences['suggestionsEnabled'] ?? true;
      _context.showAlertUpdates = preferences['showAlertUpdates'] ?? true;
      _context.preferredTopics = List<String>.from(preferences['preferredTopics'] ?? []);
      
      // Charger les centres d'intérêt basés sur l'historique des alertes
      final interests = await _dataService.getUserInterests();
      _context.userInterests = interests;
      
      _isInitialized = true;
    } catch (e) {
      // En cas d'erreur, initialiser quand même pour ne pas bloquer l'utilisation
      _isInitialized = true;
    }
  }
  
  /// Map des questions fréquentes et leurs réponses
  final Map<String, String> _faqResponses = {
    // Questions sur les alertes
    'quels types de problèmes puis-je signaler': 
      'Vous pouvez signaler plusieurs types de problèmes comme : '
      'les problèmes d\'hygiène (déchets, insalubrité), '
      'les problèmes de sécurité (vandalisme, danger public), '
      'les infractions douanières, '
      'et d\'autres problèmes urbains selon les services disponibles.',
    
    'quel est le statut de mon alerte': 
      'Pour connaître le statut de votre alerte, consultez l\'onglet "Historique" '
      'où vous trouverez toutes vos alertes avec leur statut actuel (en attente, en cours, résolue).',
    
    'qui va traiter mon alerte': 
      'Votre alerte sera traitée par le service que vous avez sélectionné lors de son envoi. '
      'Par exemple, une alerte d\'hygiène sera traitée par le service d\'hygiène municipal.',
    
    'quels types d\'alerte ont été signalés dans ma zone': 
      'Pour voir les alertes dans votre zone, consultez la carte dans l\'onglet "Accueil". '
      'Vous y verrez les alertes publiques signalées à proximité.',
    
    'quel service gère ce type de problème': 
      'Cela dépend du problème. Les problèmes d\'hygiène sont gérés par le service d\'hygiène, '
      'les problèmes de sécurité par la police ou la gendarmerie, etc. '
      'L\'application vous suggérera le service approprié lors de la création d\'une alerte.',
    
    // Questions sur les services
    'quels services sont disponibles': 
      'Les services disponibles incluent : Service d\'hygiène, Police nationale, '
      'Gendarmerie, Douanes, et d\'autres services municipaux selon votre localité.',
    
    'compétences du service d\'hygiène': 
      'Le service d\'hygiène traite les problèmes de propreté urbaine, déchets, '
      'insalubrité, nuisibles, et questions sanitaires dans les espaces publics.',
    
    'compétences de la police': 
      'La Police nationale s\'occupe de la sécurité publique, lutte contre la criminalité, '
      'maintien de l\'ordre, et protection des personnes et des biens.',
    
    'compétences de la gendarmerie': 
      'La Gendarmerie assure la sécurité dans les zones rurales et périurbaines, '
      'contrôle routier, et intervient sur des missions de police judiciaire.',
    
    'compétences des douanes': 
      'Les Douanes contrôlent les marchandises, luttent contre la contrebande, '
      'et veillent au respect des réglementations commerciales.',
    
    'comment contacter un service': 
      'Les coordonnées de contact (téléphone, email) sont disponibles '
      'dans la fiche détaillée de chaque service. Accédez-y en cliquant '
      'sur le service concerné dans la liste des services.',
    
    'heures d\'ouverture': 
      'Les heures d\'ouverture varient selon les services. '
      'Consultez la fiche détaillée du service pour connaître ses horaires.',
    
    // Questions sur l'application
    'géolocalisation': 
      'L\'application utilise votre position GPS pour localiser précisément les alertes '
      'que vous signalez et pour vous montrer les alertes à proximité. '
      'Cette information est uniquement utilisée pour le bon fonctionnement du service.',
    
    'permissions': 
      'L\'application demande des permissions pour accéder à votre position (pour localiser les alertes), '
      'à votre appareil photo (pour prendre des photos/vidéos comme preuves), '
      'et au stockage (pour sélectionner des fichiers existants).',
    
    'anonyme': 
      'Non, les alertes ne sont pas anonymes pour les services qui les traitent, '
      'car ils peuvent avoir besoin de vous contacter pour plus d\'informations. '
      'Cependant, votre identité n\'est pas visible publiquement pour les autres utilisateurs.',
    
    // Questions sur le suivi
    'alerte résolue': 
      'Une alerte est considérée comme résolue lorsque le service concerné '
      'a traité le problème et marqué l\'alerte comme "résolue". '
      'Vous recevrez une notification quand cela se produit.',
    
    'temps de traitement': 
      'Le temps de traitement varie selon le type de problème et la charge de travail du service. '
      'Généralement, les alertes sont traitées dans un délai de 3 à 10 jours ouvrables.',
    
    'problème persiste': 
      'Si un problème persiste après résolution, vous pouvez ajouter un commentaire '
      'à l\'alerte existante ou créer une nouvelle alerte en précisant '
      'que le problème a déjà été signalé mais persiste.',
    
    // Assistance
    'problème technique': 
      'Pour tout problème technique, contactez le support à support@yolle.sn '
      'ou utilisez le formulaire de contact dans les paramètres de l\'application.',
    
    'signaler un bug': 
      'Pour signaler un bug, allez dans Paramètres > Aide > Signaler un problème, '
      'ou envoyez un email détaillant le problème à support@yolle.sn.',
    
    'plus d\'informations': 
      'Pour plus d\'informations sur les services, consultez le site officiel '
      'www.yolle.sn ou les pages des services municipaux concernés.',
    
    'confidentialité': 
      'Vos données personnelles sont protégées conformément à la législation en vigueur. '
      'Consultez notre politique de confidentialité complète dans Paramètres > Confidentialité.',
  };

  /// Liste des suggestions de questions fréquentes
  final List<String> _suggestions = [
    'Quels types de problèmes puis-je signaler ?',
    'Quel est le statut de mon alerte ?',
    'Qui va traiter mon alerte ?',
    'Quels services sont disponibles ?',
    'Comment fonctionne la géolocalisation ?',
    'Suis-je anonyme quand je lance une alerte ?',
    'Combien de temps pour traiter une alerte ?',
    'Comment contacter le support technique ?',
    // Nouvelles suggestions pour les nouvelles intentions
    'Combien d\'alertes y a-t-il aujourd\'hui ?',
    'Quelles sont les alertes fréquentes à Dakar ?',
    'Y a-t-il des zones avec beaucoup d\'accidents ?',
    'Est-ce qu\'il y a des problèmes d\'insécurité à Parcelles Assainies ?',
  ];

  /// Obtenir la liste des suggestions de questions
  List<String> getSuggestions() {
    return _suggestions;
  }

  /// Traiter une question de l'utilisateur et générer une réponse
  Future<ChatMessage> processUserMessage(String message) async {
    // Mettre à jour le contexte avec le nouveau message
    _context.updateAfterUserMessage(message);
    
    // Analyser l'intention et les entités
    final IntentAnalysisResult analysis = _intentClassifier.classifyIntent(message);
    final String intent = analysis.intent;
    final Map<String, dynamic> entities = analysis.entities;
    
    String response = '';
    late List<String> quickReplies;
    
    // Générer une réponse basée sur l'intention et les entités
    // Traiter l'intention selon son type
    switch (intent) {
      case IntentClassifierService.INTENT_GREETING:
        response = await _getGreetingResponse();
        quickReplies = await getGeneralSuggestions();
        break;
        
      case IntentClassifierService.INTENT_FAREWELL:
        response = 'Au revoir ! N\'hésitez pas à revenir si vous avez d\'autres questions.';
        break;
        
      case IntentClassifierService.INTENT_THANKS:
        response = 'Je vous en prie ! Comment puis-je vous aider davantage ?';
        break;
        
      case IntentClassifierService.INTENT_ALERT_INFO:
        response = _getAlertInfoResponse(entities);
        quickReplies = await _getAlertRelatedSuggestions();
        break;
        
      case IntentClassifierService.INTENT_ALERT_STATUS:
        response = await _getAlertStatusResponse(entities);
        quickReplies = await _getStatusRelatedSuggestions();
        break;
        
      case IntentClassifierService.INTENT_ALERT_CREATION:
        if (_context.isInGuidedFlow && _context.guidedFlowType == 'create_alert') {
          response = _continueCreateAlertFlow(message);
        } else {
          response = 'Voulez-vous que je vous guide pour créer une nouvelle alerte ?';
          quickReplies = ['Oui, créer une alerte', 'Non merci'];
          _context.startGuidedFlow('create_alert');
        }
        break;
        
      case IntentClassifierService.INTENT_SERVICE_INFO:
        response = _getServiceInfoResponse(entities);
        quickReplies = _getServiceRelatedSuggestions(entities['service_name']);
        break;
        
      case IntentClassifierService.INTENT_SERVICE_LIST:
        response = _faqResponses['quels services sont disponibles'] ?? 
                  'Plusieurs services sont disponibles dans l\'application, dont le service d\'hygiène, la police, la gendarmerie et les douanes.';
        quickReplies = [
          'Compétences du service d\'hygiène',
          'Comment contacter un service',
          'Heures d\'ouverture des services',
        ];
        break;
        
      case IntentClassifierService.INTENT_APP_USAGE:
        if (message.toLowerCase().contains('anonyme')) {
          response = _faqResponses['anonyme'] ?? 
                    'Non, les alertes ne sont pas anonymes pour les services, mais votre identité reste privée vis-à-vis des autres utilisateurs.';
        } else if (message.toLowerCase().contains('géolocalisation')) {
          response = _faqResponses['géolocalisation'] ?? 
                    'La géolocalisation permet de situer précisément les alertes que vous signalez et de vous montrer celles à proximité.';
        } else if (message.toLowerCase().contains('permission')) {
          response = _faqResponses['permissions'] ?? 
                    'L\'application demande des permissions pour accéder à votre position, votre appareil photo et au stockage.';
        } else {
          response = 'L\'application Yollë permet de signaler des problèmes urbains aux autorités compétentes. Que souhaitez-vous savoir sur son fonctionnement ?';
          quickReplies = [
            'Comment fonctionne la géolocalisation ?',
            'Suis-je anonyme quand je lance une alerte ?',
            'Pourquoi l\'app demande des permissions ?'
          ];
        }
        break;
        
      case IntentClassifierService.INTENT_HELP:
        response = 'Je suis là pour vous aider ! Voici quelques sujets sur lesquels je peux vous informer :';
        quickReplies = await getGeneralSuggestions();
        break;
      
      // Nouvelles intentions métier
      case IntentClassifierService.INTENT_ALERTES_DU_JOUR:
        response = await _getAlertesDuJourResponse();
        quickReplies = [
          'Quelles sont les alertes fréquentes ?',
          'Y a-t-il des zones dangereuses ?',
          'Comment créer une alerte ?'
        ];
        break;
        
      case IntentClassifierService.INTENT_ALERTES_FREQUENTES:
        response = await _getAlertesFrequentesResponse(entities);
        quickReplies = [
          'Zones avec beaucoup d\'accidents ?',
          'Combien d\'alertes aujourd\'hui ?',
          'Comment signaler un problème ?'
        ];
        break;
        
      case IntentClassifierService.INTENT_ZONES_ACCIDENTS:
        response = await _getZonesAccidentsResponse();
        quickReplies = [
          'Alertes les plus fréquentes ?',
          'Sécurité à Parcelles Assainies ?',
          'Créer une alerte'
        ];
        break;
        
      case IntentClassifierService.INTENT_INFO_SECURITE_EAU:
        response = await _getInfoSecuriteEauResponse(entities);
        quickReplies = [
          'Zones avec beaucoup d\'accidents ?',
          'Alertes fréquentes dans cette zone ?',
          'Voir l\'historique des alertes'
        ];
        break;

      case IntentClassifierService.INTENT_UNKNOWN:
      default:
        // Recherche dans la base de FAQ si aucune intention précise n'est détectée
        final lowerMessage = message.toLowerCase();
        String? matchedKey;
        
        // Recherche dans les FAQ
        for (final entry in _faqResponses.entries) {
          if (lowerMessage.contains(entry.key)) {
            if (matchedKey == null || entry.key.length > matchedKey.length) {
              matchedKey = entry.key;
              response = entry.value;
            }
          }
        }
        
        // Si toujours aucune correspondance
        if (matchedKey == null) {
          response = 'Je ne suis pas sûr de comprendre votre question. Pourriez-vous la reformuler ? Voici quelques sujets sur lesquels je peux vous aider :';
          quickReplies = await getGeneralSuggestions();
        } else {
          // Vérifier si nous avons déjà trouvé une réponse dans la boucle
          if (response.isEmpty) {
            response = 'Je ne trouve pas de réponse précise à votre question. Voici quelques sujets sur lesquels je peux vous aider :';
          }
          
          // Suggestions basées sur le sujet trouvé
          if (matchedKey.contains('problème') || matchedKey.contains('alerte')) {
            quickReplies = await _getAlertRelatedSuggestions();
          } else if (matchedKey.contains('service')) {
            quickReplies = _getServiceRelatedSuggestions(null);
          } else {
            quickReplies = await _getContextualSuggestions(_context.currentTopic);
          }
        }
    }
    
    return ChatMessage.bot(response, quickReplies: quickReplies);
  }
  
  /// Obtenir une réponse de salutation adaptée selon l'heure ou le contexte
  Future<String> _getGreetingResponse() async {
    String greeting;
    final hour = DateTime.now().hour;

    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bonjour';
    } else {
      greeting = 'Bonsoir';
    }

    if (_context.userName != null && _context.useUserName) {
      greeting += ' ${_context.userName}';
    }

    // Ajouter un message différent selon que c'est la première interaction ou non
    if (_context.isFirstInteraction) {
      greeting += ' ! Je suis Yollë, votre assistant. Je peux vous aider à signaler des problèmes, suivre vos alertes et vous fournir des informations sur les services municipaux. Comment puis-je vous aider aujourd\`hui ?';
      _context.isFirstInteraction = false;
    } else {
      greeting += ' ! Comment puis-je vous aider ?';
    }
    return greeting;
  }

  /// Obtenir une réponse sur les informations d'une alerte
  String _getAlertInfoResponse(Map<String, dynamic> entities) {
    if (entities.containsKey('location_area') || entities.containsKey('location_nearby')) {
      final location = entities['location_area'] ?? entities['location_nearby'];
      return 'Pour connaître les alertes signalées dans la zone "$location", consultez la carte sur l\'écran d\'accueil qui affiche les alertes publiques à proximité.';
    }
    
    return _faqResponses['quels types de problèmes puis-je signaler'] ?? 
           'Vous pouvez signaler différents types de problèmes comme les problèmes d\'hygiène (déchets, insalubrité), de sécurité, d\'infrastructure urbaine et autres selon les services disponibles dans votre localité.';
  }
  
  /// Obtenir une réponse concernant le statut d'une alerte
  Future<String> _getAlertStatusResponse(Map<String, dynamic> entities) async {
    // Récupérer les statistiques des alertes de l'utilisateur
    final alertStats = await _dataService.getUserAlertStats();
    
    // Si l'utilisateur n'a pas d'alertes
    if (alertStats['total'] == 0) {
      return "Vous n'avez pas encore soumis d'alertes. Pour créer une nouvelle alerte, accédez à l'onglet Services et sélectionnez un service compétent.";
    }
    
    // Si une alerte spécifique est mentionnée par ID
    if (entities.containsKey('alert_id')) {
      final alertId = entities['alert_id'];
      
      // Essayer de récupérer les détails de cette alerte spécifique
      try {
        final alertDetails = await _dataService.getAlertDetails(alertId);
        
        if (alertDetails != null) {
          String statusText;
          switch (alertDetails.status) {
            case 'pending':
              statusText = 'en attente de traitement';
              break;
            case 'in_progress':
              statusText = 'en cours de traitement';
              break;
            case 'resolved':
              statusText = 'résolue';
              break;
            default:
              statusText = alertDetails.status;
          }
          
          return "Votre alerte n°$alertId concernant \"${alertDetails.title}\" est actuellement $statusText. ${alertDetails.status == 'resolved' ? 'Le problème a été traité avec succès.' : 'Vous pouvez consulter plus de détails dans l\'onglet Historique.'}";
        }
      } catch (e) {
        // En cas d'erreur, retour à la réponse générique
      }
      
      return 'Pour connaître le statut précis de l\'alerte n°$alertId, consultez l\'onglet "Historique" où vous trouverez toutes vos alertes avec leur statut actuel et les dernières mises à jour.';
    }
    
    // Si une date est mentionnée
    if (entities.containsKey('alert_date')) {
      final alertDate = entities['alert_date'];
      return 'Pour connaître le statut de l\'alerte envoyée le $alertDate, consultez l\'onglet "Historique" dans le menu principal où vous trouverez toutes vos alertes classées par date.';
    }
    
    // Réponse avec statistiques générales
    final pendingCount = alertStats['pending'] ?? 0;
    final inProgressCount = alertStats['inProgress'] ?? 0;
    final resolvedCount = alertStats['resolved'] ?? 0;
    final totalCount = alertStats['total'] ?? 0;
    
    return "Vous avez soumis un total de $totalCount alerte${totalCount > 1 ? 's' : ''}. "
           "Parmi elles, $pendingCount ${pendingCount > 1 ? 'sont en attente' : 'est en attente'}, "
           "$inProgressCount ${inProgressCount > 1 ? 'sont en cours de traitement' : 'est en cours de traitement'}, et "
           "$resolvedCount ${resolvedCount > 1 ? 'ont été résolues' : 'a été résolue'}. "
           "Consultez l'onglet Historique pour plus de détails sur chaque alerte.";
  }
  
  /// Obtenir une réponse concernant un service spécifique
  String _getServiceInfoResponse(Map<String, dynamic> entities) {
    if (entities.containsKey('service_name')) {
      final serviceName = entities['service_name'];
      _context.lastMentionedService = serviceName;
      
      switch (serviceName) {
        case 'hygiène':
        case 'hygiene':
          return _faqResponses['compétences du service d\'hygiène'] ?? 
                'Le service d\'hygiène traite les problèmes de propreté urbaine, déchets, insalubrité, nuisibles et questions sanitaires dans les espaces publics.';
          
        case 'police':
          return _faqResponses['compétences de la police'] ?? 
                'La Police nationale s\'occupe de la sécurité publique, lutte contre la criminalité, maintien de l\'ordre et protection des personnes et des biens.';
          
        case 'gendarmerie':
          return _faqResponses['compétences de la gendarmerie'] ?? 
                'La Gendarmerie assure la sécurité dans les zones rurales et périurbaines, effectue des contrôles routiers et intervient sur des missions de police judiciaire.';
          
        case 'douane':
          return _faqResponses['compétences des douanes'] ?? 
                'Les Douanes contrôlent les marchandises, luttent contre la contrebande et veillent au respect des réglementations commerciales.';
          
        default:
          return 'Pour obtenir des informations détaillées sur le service de $serviceName, consultez la fiche du service dans la liste des services disponibles.';
      }
    } else if (_context.lastMentionedService != null) {
      return _getServiceInfoResponse({'service_name': _context.lastMentionedService});
    }
    
    return 'Plusieurs services sont disponibles dans l\'application. De quel service souhaitez-vous connaître les compétences ?';
  }
  
  /// Continuer le processus de création d'alerte guidé
  String _continueCreateAlertFlow(String message) {
    if (_context.currentGuidedStep == 0) {
      // Première étape - Confirmation de création d'alerte
      if (message.toLowerCase().contains('oui')) {
        _context.nextGuidedStep();
        return 'Quel type de problème souhaitez-vous signaler ? (ex: déchet, voirie, éclairage, etc.)';
      } else {
        _context.resetGuidedFlow();
        return 'D\'accord, n\'hésitez pas à me demander si vous avez d\'autres questions.';
      }
    } else if (_context.currentGuidedStep == 1) {
      // Deuxième étape - Type de problème
      _context.setFlowData('problem_type', message);
      _context.nextGuidedStep();
      return 'Pourriez-vous me donner une brève description du problème ?';
    } else if (_context.currentGuidedStep == 2) {
      // Troisième étape - Description du problème
      _context.setFlowData('description', message);
      _context.nextGuidedStep();
      return 'Pour créer votre alerte avec les informations fournies, accédez au service concerné depuis l\'onglet Services, puis remplissez le formulaire d\'alerte. Souhaitez-vous que je vous aide à choisir le service approprié ?';
    } else if (_context.currentGuidedStep == 3) {
      // Quatrième étape - Choix du service
      if (message.toLowerCase().contains('oui')) {
        final problemType = _context.getFlowData('problem_type').toString().toLowerCase();
        String recommendedService = 'service d\'hygiène';
        
        if (problemType.contains('déchet') || problemType.contains('poubelle') || 
            problemType.contains('insecte') || problemType.contains('rat')) {
          recommendedService = 'service d\'hygiène';
        } else if (problemType.contains('route') || problemType.contains('trottoir') || 
                  problemType.contains('nid de poule')) {
          recommendedService = 'service de voirie';
        } else if (problemType.contains('vol') || problemType.contains('agression') || 
                  problemType.contains('sécurité')) {
          recommendedService = 'police';
        }
        
        _context.resetGuidedFlow();
        return 'D\'après votre description, je vous recommande de contacter le $recommendedService. Accédez à ce service depuis l\'onglet Services pour créer votre alerte.';
      } else {
        _context.resetGuidedFlow();
        return 'D\'accord. Vous pouvez créer votre alerte en accédant à l\'onglet Services, puis en sélectionnant le service approprié pour votre problème.';
      }
    }
    return 'D\'accord. Vous pouvez créer votre alerte en accédant à l\'onglet Services, puis en sélectionnant le service approprié pour votre problème.';
  }


  /// Obtenir une réponse sur les alertes du jour
  Future<String> _getAlertesDuJourResponse() async {
    try {
      final count = await _dataService.getTodaysAlertsCount();
      if (count == 0) {
        return "Bonne nouvelle ! Aucune alerte n'a été signalée aujourd'hui.";
      }
      return "Il y a eu $count alerte${count > 1 ? 's' : ''} signalée${count > 1 ? 's' : ''} aujourd'hui.";
    } catch (e) {
      return "Je n'ai pas pu récupérer le nombre d'alertes pour aujourd'hui, veuillez réessayer plus tard.";
    }
  }

  /// Obtenir une réponse sur les alertes fréquentes
  Future<String> _getAlertesFrequentesResponse(Map<String, dynamic> entities) async {
    final location = entities['location_area'] as String?;
    try {
      final frequentAlerts = await _dataService.getFrequentAlerts(location: location);
      if (frequentAlerts.isEmpty) {
        return "Il n'y a pas de type d'alerte particulièrement fréquent ${location != null ? 'à ' + location : 'en ce moment'}.";
      }
      return "Les alertes les plus fréquentes ${location != null ? 'à ' + location : ''} concernent : ${frequentAlerts.join(', ')}.";
    } catch (e) {
      return "Je n'ai pas pu récupérer les informations sur les alertes fréquentes.";
    }
  }

  /// Obtenir une réponse sur les zones avec des accidents
  Future<String> _getZonesAccidentsResponse() async {
    try {
      final zones = await _dataService.getAccidentZones();
      if (zones.isEmpty) {
        return "Aucune zone à risque d'accident n'a été identifiée récemment.";
      }
      return "Les zones avec une concentration d'alertes liées à des accidents sont : ${zones.join(', ')}. Soyez prudent dans ces secteurs.";
    } catch (e) {
      return "Je n'ai pas pu récupérer les informations sur les zones à risque.";
    }
  }

  /// Obtenir une réponse sur la sécurité ou les problèmes d'eau
  Future<String> _getInfoSecuriteEauResponse(Map<String, dynamic> entities) async {
    final location = entities['location_area'] as String?;
    if (location == null) {
      return "De quelle zone souhaitez-vous connaître les informations de sécurité ou sur l'eau ?";
    }
    try {
      final info = await _dataService.getSecurityAndWaterInfo(location);
      return info; // Supposons que le service retourne une chaîne formatée
    } catch (e) {
      return "Je n'ai pas pu récupérer les informations pour $location.";
    }
  }

  
  /// Obtenir des suggestions liées aux alertes
  Future<List<String>> _getAlertRelatedSuggestions() async {
    return [
      'Quels types de problèmes puis-je signaler ?',
      'Qui va traiter mon alerte ?',
      'Combien de temps faut-il pour traiter une alerte ?',
      'Comment ajouter des preuves à mon alerte ?',
    ];
  }
  
  /// Obtenir des suggestions liées au statut des alertes
  Future<List<String>> _getStatusRelatedSuggestions() async {
    try {
      // Récupérer les statistiques des alertes
      final alertStats = await _dataService.getUserAlertStats();
      
      List<String> suggestions = [
        'Comment savoir si mon alerte est résolue ?',
      ];
      
      // Ajouter des suggestions contextuelles
      if (alertStats['pending'] > 0) {
        suggestions.add('Pourquoi mon alerte est-elle en attente ?');
      }
      if (alertStats['inProgress'] > 0) {
        suggestions.add('Qui s\'occupe de mon alerte actuellement ?');
      }
      if (alertStats['resolved'] > 0) {
        suggestions.add('Que faire si le problème persiste malgré la résolution ?');
      }
      
      // Compléter avec des suggestions génériques si besoin
      if (suggestions.length < 3) {
        suggestions.addAll([
          'Combien de temps faut-il pour traiter une alerte ?',
          'Qui contacter pour plus d\'informations ?',
        ]);
      }
      
      return suggestions;
    } catch (e) {
      // En cas d'erreur, renvoyer les suggestions par défaut
      return [
        'Comment savoir si mon alerte est résolue ?',
        'Pourquoi mon alerte est-elle en attente ?',
        'Que faire si le problème persiste ?',
        'Qui contacter pour plus d\'informations ?',
      ];
    }
  }
  
  /// Obtenir des suggestions liées à un service
  List<String> _getServiceRelatedSuggestions(String? serviceName) {
    if (serviceName != null) {
      return [
        'Comment contacter ce service ?',
        'Quels problèmes traite ce service ?',
        'Horaires d\'ouverture de ce service',
      ];
    }
    
    return [
      'Quels services sont disponibles ?',
      'Compétences du service d\'hygiène',
      'Compétences de la police',
      'Comment contacter un service ?',
    ];
  }
  
  /// Obtenir des suggestions contextuelles selon le sujet actuel
  Future<List<String>> _getContextualSuggestions(String? topic) async {
    if (topic == null) {
      return await getGeneralSuggestions();
    }
    
    switch (topic) {
      case 'alerts':
        return await _getAlertRelatedSuggestions();
      case 'services':
        return _getServiceRelatedSuggestions(null);
      case 'profile':
        return [
          'Comment modifier mon profil ?',
          'Comment changer ma photo ?',
          'Comment supprimer mon compte ?',
        ];
      case 'app_usage':
        return [
          'Comment fonctionne la géolocalisation ?',
          'Pourquoi l\'app demande des permissions ?',
          'Suis-je anonyme quand je lance une alerte ?',
        ];
      default:
        return await getGeneralSuggestions();
    }
  }
  
  /// Générer des suggestions générales pour l'utilisateur
  /// Cette méthode est exposée pour être utilisée par le ChatbotProvider
  Future<List<String>> getGeneralSuggestions() async {
    // S'assurer que le service est initialisé
    await initialize();
    
    List<String> suggestions = [
      'Quels types de problèmes puis-je signaler ?',
      'Comment fonctionne l\'application ?',
      'Comment créer une alerte ?',
    ];
    
    // Ajouter des suggestions basées sur le contexte utilisateur
    try {
      final alertStats = await _dataService.getUserAlertStats();
      if (alertStats['total'] > 0) {
        if (alertStats['inProgress'] > 0) {
          suggestions.add('Statut de mes alertes en cours');
        } else if (alertStats['pending'] > 0) {
          suggestions.add('Pourquoi mon alerte est en attente ?');
        } else {
          suggestions.add('Voir mon historique d\'alertes');
        }
      }
    } catch (e) {
      // En cas d'erreur, utilise les suggestions par défaut
    }
    
    return suggestions;
  }

  /// Générer un message de bienvenue initial
  Future<ChatMessage> getWelcomeMessage() async {
    // S'assurer que le service est initialisé
    await initialize();
    
    // Déterminer le message de salutation en fonction de l'heure
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }
    
    String welcomeMessage;
    if (_context.userName != null) {
      welcomeMessage = '$greeting ${_context.userName} ! Je suis le chatbot de l\'application Yollë, comment puis-je vous aider aujourd\'hui ?';
    } else {
      welcomeMessage = '$greeting ! Je suis le chatbot de l\'application Yollë, comment puis-je vous aider aujourd\'hui ?';
    }
    
    // Récupérer les suggestions générales avec personnalisation
    final List<String> quickReplies = await getGeneralSuggestions();
    
    return ChatMessage.bot(
      welcomeMessage,
      quickReplies: quickReplies,
    );
  }
}
