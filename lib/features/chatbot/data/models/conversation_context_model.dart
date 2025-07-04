/// Modèle pour stocker le contexte d'une conversation avec le chatbot
class ConversationContext {
  /// Sujet principal de la conversation actuelle
  String? currentTopic;
  
  /// Dernier service mentionné dans la conversation
  String? lastMentionedService;
  
  /// Dernière alerte mentionnée dans la conversation
  String? lastMentionedAlertId;
  
  /// Nombre de messages échangés dans la conversation actuelle
  int messageCount = 0;
  
  /// Indique si l'utilisateur est engagé dans une conversation guidée (wizard)
  bool isInGuidedFlow = false;
  
  /// Étape actuelle dans un flux guidé (si applicable)
  int? currentGuidedStep;
  
  /// Type de flux guidé actuel (si applicable)
  /// Exemples: 'create_alert', 'check_status', etc.
  String? guidedFlowType;
  
  /// Données temporaires collectées durant un flux guidé
  Map<String, dynamic> tempFlowData = {};
  
  /// Identifiant de l'utilisateur (pour les réponses personnalisées)
  String? userId;
  
  /// Nom de l'utilisateur (pour les réponses personnalisées)
  String? userName;
  
  /// Sujets récemment abordés dans les conversations précédentes
  List<String> recentTopics = [];
  
  /// Indique si le nom de l'utilisateur doit être utilisé dans les réponses
  bool useUserName = true;
  
  /// Indique si des suggestions doivent être proposées après chaque réponse
  bool suggestionsEnabled = true;
  
  /// Indique si le chatbot doit notifier les mises à jour d'alertes
  bool showAlertUpdates = true;
  
  /// Sujets préférés de l'utilisateur (définis manuellement)
  List<String> preferredTopics = [];
  
  /// Centres d'intérêt de l'utilisateur (basés sur ses alertes)
  List<String> userInterests = [];
  
  /// Indique si c'est la première interaction de la session
  bool isFirstInteraction = true;
  
  /// Constructeur par défaut
  ConversationContext({
    this.currentTopic,
    this.lastMentionedService,
    this.lastMentionedAlertId,
    this.userId,
    this.userName,
    this.messageCount = 0,
    this.isInGuidedFlow = false,
    this.currentGuidedStep,
    this.guidedFlowType,
  });
  
  /// Mise à jour du contexte après chaque message utilisateur
  void updateAfterUserMessage(String message) {
    messageCount++;
    
    // Analyse basique du message pour détecter les changements de sujet
    message = message.toLowerCase();
    
    if (message.contains('alerte') || message.contains('signaler')) {
      currentTopic = 'alerts';
    } else if (message.contains('service') || message.contains('compétence')) {
      currentTopic = 'services';
    } else if (message.contains('profil') || message.contains('compte')) {
      currentTopic = 'profile';
    } else if (message.contains('application') || message.contains('fonctionne')) {
      currentTopic = 'app_usage';
    }
    
    // Réinitialisation du flux guidé si l'utilisateur semble vouloir changer de sujet
    if (message.contains('annuler') || message.contains('quitter') || 
        message.contains('stop')) {
      resetGuidedFlow();
    }
  }
  
  /// Démarrer un nouveau flux guidé
  void startGuidedFlow(String flowType) {
    isInGuidedFlow = true;
    guidedFlowType = flowType;
    currentGuidedStep = 0;
    tempFlowData = {};
  }
  
  /// Passer à l'étape suivante dans un flux guidé
  void nextGuidedStep() {
    if (isInGuidedFlow && currentGuidedStep != null) {
      currentGuidedStep = currentGuidedStep! + 1;
    }
  }
  
  /// Réinitialiser/quitter un flux guidé
  void resetGuidedFlow() {
    isInGuidedFlow = false;
    guidedFlowType = null;
    currentGuidedStep = null;
    tempFlowData = {};
  }
  
  /// Stocker une donnée dans le flux guidé actuel
  void setFlowData(String key, dynamic value) {
    tempFlowData[key] = value;
  }
  
  /// Récupérer une donnée du flux guidé actuel
  dynamic getFlowData(String key) {
    return tempFlowData[key];
  }
}
