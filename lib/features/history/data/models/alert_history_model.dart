import 'package:flutter/foundation.dart';
import 'dart:ui';

class AlertHistoryModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String serviceIcon;
  final String serviceColor;
  final String category;
  final String description;
  final Map<String, dynamic> location;
  final List<Map<String, dynamic>> proofs;
  final bool isAnonymous;
  final String status;
  final List<Map<String, dynamic>> statusHistory;
  final List<Map<String, dynamic>> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlertHistoryModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
    required this.category,
    required this.description,
    required this.location,
    required this.proofs,
    required this.isAnonymous,
    required this.status,
    required this.statusHistory,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertHistoryModel.fromJson(Map<String, dynamic> json) {
    return AlertHistoryModel(
      id: json['_id'] ?? '',
      serviceId: json['service']['_id'] ?? '',
      serviceName: json['service']['name'] ?? 'Service',
      serviceIcon: json['service']['icon'] ?? 'assets/icons/default_service.png',
      serviceColor: json['service']['color'] ?? '#006837',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? {},
      proofs: List<Map<String, dynamic>>.from(json['proofs'] ?? []),
      isAnonymous: json['isAnonymous'] ?? false,
      status: json['status'] ?? 'pending',
      statusHistory: List<Map<String, dynamic>>.from(json['statusHistory'] ?? []),
      comments: List<Map<String, dynamic>>.from(json['comments'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  // Méthode pour obtenir une couleur à partir de la chaîne hexadécimale
  Color getServiceColor() {
    try {
      final hexColor = serviceColor.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return const Color(0xFF006837); // Couleur par défaut (vert)
    }
  }

  // Méthode pour obtenir une description du statut en français
  String getStatusDescription() {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours de traitement';
      case 'resolved':
        return 'Résolu';
      case 'rejected':
        return 'Rejeté';
      default:
        return 'Inconnu';
    }
  }
}
