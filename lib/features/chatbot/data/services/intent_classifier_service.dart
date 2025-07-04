/// Résultat de l'analyse d'intention
class IntentAnalysisResult {
  /// L'intention détectée
  final String intent;
  
  /// Les entités extraites du message
  final Map<String, dynamic> entities;
  
  /// Constructeur
  IntentAnalysisResult({
    required this.intent,
    required this.entities,
  });
}

/// Service pour classifier les intentions de l'utilisateur à partir de ses messages
class IntentClassifierService {
  /// Types d'intentions possibles
  static const String INTENT_GREETING = 'greeting';
  static const String INTENT_FAREWELL = 'farewell';
  static const String INTENT_THANKS = 'thanks';
  static const String INTENT_ALERT_INFO = 'alert_info';
  static const String INTENT_ALERT_STATUS = 'alert_status';
  static const String INTENT_ALERT_CREATION = 'alert_creation';
  static const String INTENT_SERVICE_INFO = 'service_info';
  static const String INTENT_SERVICE_LIST = 'service_list';
  static const String INTENT_SERVICE_CONTACT = 'service_contact';
  static const String INTENT_APP_USAGE = 'app_usage';
  static const String INTENT_LOCATION = 'location';
  static const String INTENT_PROFILE = 'profile';
  static const String INTENT_HELP = 'help';
  static const String INTENT_UNKNOWN = 'unknown';
  
  // Nouvelles intentions métier
  static const String INTENT_ALERTES_DU_JOUR = 'nombre_alertes_du_jour';
  static const String INTENT_ALERTES_FREQUENTES = 'alertes_frequentes';
  static const String INTENT_ZONES_ACCIDENTS = 'zones_accidents';
  static const String INTENT_INFO_SECURITE_EAU = 'info_securite_et_eau';

  /// Modèles d'expressions pour chaque intention
  final Map<String, List<String>> _intentPatterns = {
    INTENT_GREETING: [
      'bonjour', 'salut', 'hey', 'hello', 'hi', 'coucou',
      'bonsoir', 'bon matin', 'bon après-midi',
    ],
    INTENT_FAREWELL: [
      'au revoir', 'bye', 'à bientôt', 'adieu', 'à plus tard',
      'à la prochaine', 'bonne journée',
    ],
    INTENT_THANKS: [
      'merci', 'thanks', 'je vous remercie', 'c\'est gentil',
      'parfait merci', 'super merci',
    ],
    INTENT_ALERT_INFO: [
      'type d\'alerte', 'type de problème', 'problème signaler',
      'types d\'alertes', 'quelles alertes', 'signaler quoi',
      'que puis-je signaler', 'puis-je signaler', 'alerte possible',
      'alertes quartier', 'alertes zone', 'alerte près',
    ],
    INTENT_ALERT_STATUS: [
      'statut de mon alerte', 'état de mon alerte', 'où en est mon alerte',
      'mon alerte est-elle traitée', 'alerte résolue', 'qui traite mon alerte',
      'suivi alerte', 'temps de traitement', 'délai traitement',
      'statut', 'attente depuis', 'pourquoi mon alerte',
      'savoir si alerte résolue', 'temps pour traiter',
    ],
    INTENT_ALERT_CREATION: [
      'créer une alerte', 'lancer une alerte', 'signaler un problème',
      'comment signaler', 'faire un signalement', 'envoyer une alerte',
      'nouvelle alerte', 'signaler incident', 'créer signalement',
      'envoyer preuve', 'ajouter photo', 'joindre vidéo',
    ],
    INTENT_SERVICE_INFO: [
      'compétence', 'service hygiène', 'service police', 'service gendarmerie',
      'service douane', 'que fait', 'rôle de', 'responsabilité de',
      'quel service gère', 'qui gère', 'service pour problème',
      'à qui signaler', 'service compétent',
    ],
    INTENT_SERVICE_LIST: [
      'quels services', 'services disponibles', 'liste des services',
      'tous les services', 'différents services', 'services dans l\'application',
    ],
    INTENT_SERVICE_CONTACT: [
      'contacter service', 'téléphone service', 'email service',
      'contact direct', 'numéro de', 'joindre service',
      'heure d\'ouverture', 'horaire service',
    ],
    INTENT_APP_USAGE: [
      'comment utiliser', 'fonctionne l\'application', 'géolocalisation',
      'permissions', 'pourquoi demande', 'naviguer', 'consulter historique',
      'fonctionnalité', 'comment faire', 'utilisation',
      'anonyme', 'suis-je anonyme', 'anonymat',
    ],
    INTENT_LOCATION: [
      'ma position', 'localisation', 'géolocalisation', 'gps',
      'coordonnées', 'emplacement', 'situer', 'où suis-je',
      'partager position', 'trouver sur carte',
    ],
    INTENT_PROFILE: [
      'mon profil', 'mon compte', 'mes informations', 'mes données',
      'modifier profil', 'changer photo', 'mettre à jour', 'adresse',
      'mot de passe', 'supprimer compte', 'informations personnelles',
    ],
    INTENT_HELP: [
      'aide', 'help', 'assistance', 'besoin d\'aide', 'sos',
      'problème technique', 'signaler bug', 'difficulté', 'comment faire',
      'guide', 'tutorial', 'mode d\'emploi',
    ],
    INTENT_ALERTES_DU_JOUR: [
      'quelles sont les alertes du jour',
      'combien d\'alertes aujourd\'hui', 'alertes ce matin', 'nombre d\'alertes aujourd\'hui',
      'alertes ce jour', 'alerte aujourd\'hui', 'signalements aujourd\'hui',
      'incidents du jour', 'alertes récentes', 'nouvelles alertes',
    ],
    INTENT_ALERTES_FREQUENTES: [
      'alertes les plus fréquentes', 'types d\'alertes', 'alertes fréquentes',
      'alertes souvent signalées', 'incidents fréquents', 'problèmes récurrents',
      'signalements réguliers', 'alertes communes', 'alertes dans ma zone',
      'alertes dans ma région', 'alertes à dakar', 'alertes à thiès', 'alertes à pikine',
    ],
    INTENT_ZONES_ACCIDENTS: [
      'où sont les zones à risque',
      'zones avec beaucoup d\'accidents', 'zones dangereuses', 'accidents de la route',
      'quartiers accidents', 'lieux dangereux', 'points noirs', 'endroits à risque',
      'zones à éviter', 'cartes des accidents', 'zones d\'accidents',
    ],
    INTENT_INFO_SECURITE_EAU: [
      'problèmes d\'insécurité', 'insécurité', 'quartier dangereux', 'vols',
      'problèmes d\'eau', 'coupures d\'eau', 'alertes de sécurité', 'risques',
      'sécurité', 'agressions', 'parcelles assainies', 'unité 12', 'coupures',
      'déménager', 'vivre à', 'sécurisé', 'eau potable', 'approvisionnement en eau',
    ],
  };

  /// Classifier l'intention d'un message utilisateur et extraire les entités
  IntentAnalysisResult classifyIntent(String message) {
    final lowerMessage = message.toLowerCase();
    String bestIntent = INTENT_UNKNOWN;
    int maxScore = 0;

    _intentPatterns.forEach((intentKey, patterns) {
      int currentScore = 0;
      for (final pattern in patterns) {
        if (lowerMessage.contains(pattern)) {
          // Augmente le score si le pattern est trouvé
          currentScore += pattern.split(' ').length; // Donne plus de poids aux expressions plus longues
        }
      }
      if (currentScore > maxScore) {
        maxScore = currentScore;
        bestIntent = intentKey;
      }
    });

    final String intent = bestIntent;
    
    // Extraire les entités selon l'intention
    final Map<String, dynamic> entities = _extractEntities(message, intent);
    
    return IntentAnalysisResult(
      intent: intent,
      entities: entities,
    );
  }

  /// Extraire des entités spécifiques d'un message selon l'intention
  Map<String, dynamic> _extractEntities(String message, String intent) {
    final Map<String, dynamic> entities = {};
    final lowerMessage = message.toLowerCase();
    
    // Extraction d'entités spécifiques selon l'intention
    switch (intent) {
      case INTENT_SERVICE_INFO:
        _extractServiceName(lowerMessage, entities);
        break;
      case INTENT_ALERT_STATUS:
        _extractAlertReference(lowerMessage, entities);
        break;
      case INTENT_ALERT_INFO:
        _extractAlertType(lowerMessage, entities);
        break;
      case INTENT_LOCATION:
        _extractLocation(lowerMessage, entities);
        break;

      // Extraire la localisation pour les nouvelles intentions
      case INTENT_ALERTES_FREQUENTES:
      case INTENT_INFO_SECURITE_EAU:
        _extractLocation(lowerMessage, entities);
        break;
    }
    
    return entities;
  }
  
  /// Extraire le nom d'un service mentionné
  void _extractServiceName(String message, Map<String, dynamic> entities) {
    final List<String> services = [
      'hygiène', 'hygiene', 'police', 'gendarmerie', 'douane', 'urbanisme',
      'voirie', 'environnement', 'eau', 'électricité', 'electricite', 'sécurité', 'securite',
    ];
    
    for (final service in services) {
      if (message.contains(service)) {
        entities['service_name'] = service;
        break;
      }
    }
  }
  
  /// Extraire une référence à une alerte
  void _extractAlertReference(String message, Map<String, dynamic> entities) {
    // Recherche de patterns comme "alerte du [date]" ou "alerte numéro [id]"
    final RegExp datePattern = RegExp(r'alerte (?:du|de|depuis) (\d{1,2}[/-]\d{1,2}[/-]\d{2,4})');
    final RegExp idPattern = RegExp(r'alerte (?:numéro|numero|id|identifiant) ([a-zA-Z0-9]+)');
    
    final dateMatch = datePattern.firstMatch(message);
    if (dateMatch != null && dateMatch.groupCount >= 1) {
      entities['alert_date'] = dateMatch.group(1);
    }
    
    final idMatch = idPattern.firstMatch(message);
    if (idMatch != null && idMatch.groupCount >= 1) {
      entities['alert_id'] = idMatch.group(1);
    }
  }
  
  /// Extraire un type d'alerte
  void _extractAlertType(String message, Map<String, dynamic> entities) {
    final List<String> alertTypes = [
      'déchet', 'dechet', 'poubelle', 'ordure',
      'eau', 'fuite', 'canalisation',
      'route', 'nid de poule', 'trottoir',
      'éclairage', 'eclairage', 'lampadaire',
      'bruit', 'nuisance sonore',
      'graffiti', 'tag', 'vandalisme',
      'animal', 'chien', 'rat', 'insecte',
    ];
    
    for (final type in alertTypes) {
      if (message.contains(type)) {
        entities['alert_type'] = type;
        break;
      }
    }
  }
  
  /// Extraire une localisation
  void _extractLocation(String message, Map<String, dynamic> entities) {
    // Recherche de patterns comme "dans le quartier [nom]" ou "près de [lieu]"
    final RegExp areaPattern = RegExp(r'(?:quartier|zone|secteur|région|region) ([a-zA-Z\s]+)');
    final RegExp nearbyPattern = RegExp(r'(?:près de|proche de|à côté de|a cote de) ([a-zA-Z\s]+)');
    
    final areaMatch = areaPattern.firstMatch(message);
    if (areaMatch != null && areaMatch.groupCount >= 1) {
      entities['location_area'] = areaMatch.group(1)?.trim();
    }
    
    final nearbyMatch = nearbyPattern.firstMatch(message);
    if (nearbyMatch != null && nearbyMatch.groupCount >= 1) {
      entities['location_nearby'] = nearbyMatch.group(1)?.trim();
    }
  }
}
