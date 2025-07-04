/// Modèle de données pour un service
class ServiceModel {
  /// Identifiant unique du service
  final String id;
  
  /// Nom du service
  final String name;
  
  /// Description du service
  final String? description;
  
  /// URL de l'image du service
  final String? imageUrl;
  
  /// Adresse du service
  final String? address;
  
  /// Numéro de téléphone du service
  final String? phone;
  
  /// Email du service
  final String? email;
  
  /// Site web du service
  final String? website;
  
  /// Heures d'ouverture du service
  final String? openingHours;
  
  /// Types de problèmes traités par le service
  final List<String>? problemTypes;
  
  /// Constructeur
  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.openingHours,
    this.problemTypes,
  });
  
  /// Créer un modèle de service à partir de JSON
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      openingHours: json['openingHours'],
      problemTypes: json['problemTypes'] != null
          ? List<String>.from(json['problemTypes'])
          : null,
    );
  }
  
  /// Convertir le modèle en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (openingHours != null) 'openingHours': openingHours,
      if (problemTypes != null) 'problemTypes': problemTypes,
    };
  }
}
