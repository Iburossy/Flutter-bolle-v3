import 'package:equatable/equatable.dart';

/// Modèle représentant un service disponible dans l'application
class AvailableServiceModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final String color; // Format hexadécimal: "#RRGGBB"
  final List<String> categories;
  final bool isActive;

  const AvailableServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.color,
    required this.categories,
    required this.isActive,
  });

  /// Crée un AvailableServiceModel à partir d'un objet JSON
  factory AvailableServiceModel.fromJson(Map<String, dynamic> json) {
    return AvailableServiceModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconPath: json['iconPath'] ?? '',
      color: json['color'] ?? '#357E78', // Couleur par défaut
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : [],
      isActive: json['isActive'] ?? true,
    );
  }

  /// Convertit le modèle en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'color': color,
      'categories': categories,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, name, description, iconPath, color, categories, isActive];
}
