/// Modèle pour les contacts des services d'urgence et administratifs
class ServiceContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String description;
  final String iconName;
  final String category;

  ServiceContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.description,
    required this.iconName,
    required this.category,
  });

  // Convertir un Map en ServiceContactModel
  factory ServiceContactModel.fromJson(Map<String, dynamic> json) {
    return ServiceContactModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      description: json['description'] ?? '',
      iconName: json['iconName'] ?? 'phone',
      category: json['category'] ?? 'Autre',
    );
  }

  // Convertir un ServiceContactModel en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'description': description,
      'iconName': iconName,
      'category': category,
    };
  }
}
