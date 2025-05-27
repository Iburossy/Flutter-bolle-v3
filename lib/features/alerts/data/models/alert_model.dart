import 'package:equatable/equatable.dart';

/// Model class representing an alert in the application
class AlertModel extends Equatable {
  final String id;
  final String category;
  final String title;
  final String description;
  final bool isAnonymous;
  final String priority;
  final String status;
  final Map<String, dynamic>? location;
  final List<String>? images;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AlertModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.isAnonymous,
    required this.priority,
    required this.status,
    this.location,
    this.images,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates an AlertModel from a JSON map
  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['_id'] ?? json['id'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      location: json['location'] is Map<String, dynamic> ? json['location'] as Map<String, dynamic> : null,
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : null,
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  /// Converts this AlertModel to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'category': category,
      'title': title,
      'description': description,
      'isAnonymous': isAnonymous,
      'priority': priority,
      'status': status,
      'userId': userId,
    };

    if (id.isNotEmpty) {
      data['id'] = id;
    }
    
    if (location != null) {
      data['location'] = location;
    }
    
    if (images != null) {
      data['images'] = images;
    }

    return data;
  }

  @override
  List<Object?> get props => [
    id, 
    category, 
    title, 
    description, 
    isAnonymous, 
    priority, 
    status, 
    location, 
    images, 
    userId, 
    createdAt, 
    updatedAt
  ];
}
