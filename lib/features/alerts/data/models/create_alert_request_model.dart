import 'package:equatable/equatable.dart';

/// Model class representing a request to create an alert
class CreateAlertRequestModel extends Equatable {
  final String serviceId;
  final String category;
    final String? description;
  final List<double> coordinates; // [longitude, latitude]
  final String address;
  final bool isAnonymous;
  final List<Map<String, dynamic>>? proofs; // Optionnel car sera traité séparément

  /// Create a request to create an alert
  CreateAlertRequestModel({
    required this.serviceId,
    required this.category,
    this.description = '',
    required this.coordinates,
    required this.address,
    required this.isAnonymous,
    this.proofs,
  });

  /// Converts this CreateAlertRequestModel to a JSON map
  Map<String, dynamic> toJson() {
    // Format exactement comme attendu par le backend d'après alert.controller.js
    final Map<String, dynamic> data = {
      'serviceId': serviceId,
      'category': category,
      'description': description,
      'coordinates': coordinates,  // [longitude, latitude]
      'address': address,
      'isAnonymous': isAnonymous,
    };

    if (proofs != null && proofs!.isNotEmpty) {
      data['proofs'] = proofs;
    }

    // Ajouter un log pour déboguer
    print('CreateAlertRequestModel.toJson: $data');
    return data;
  }
  
  /// Creates a copy of this CreateAlertRequestModel with the given fields replaced with the new values
  CreateAlertRequestModel copyWith({
    String? serviceId,
    String? category,
    String? description,
    List<double>? coordinates,
    String? address,
    bool? isAnonymous,
    List<Map<String, dynamic>>? proofs,
  }) {
    return CreateAlertRequestModel(
      serviceId: serviceId ?? this.serviceId,
      category: category ?? this.category,
            description: description ?? this.description,
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      isAnonymous: isAnonymous ?? this.isAnonymous,
            proofs: proofs ?? this.proofs,
    );
  }

  @override
  List<Object?> get props => [
    serviceId,
    category,
    description,
    coordinates,
    address,
    isAnonymous,
    proofs,
  ];
}
