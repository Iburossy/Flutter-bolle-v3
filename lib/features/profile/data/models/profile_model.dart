import 'package:equatable/equatable.dart';

/// Modèle représentant le profil d'un utilisateur
class ProfileModel extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String region;
  final LocationModel? currentLocation;
  final AddressModel? address;
  final String idType;
  final String? idNumber;
  final ProfilePictureModel? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.region,
    this.currentLocation,
    this.address,
    required this.idType,
    this.idNumber,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée un ProfileModel à partir d'un JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Ajouter un log pour déboguer la structure du JSON
    print('ProfileModel.fromJson: $json');
    
    // Gérer le cas où l'adresse est un objet vide ({})
    final address = json['address'];
    AddressModel? addressModel;
    if (address != null && address is Map<String, dynamic> && address.isNotEmpty) {
      addressModel = AddressModel.fromJson(address);
    }
    
    // Gérer le document d'identité
    final idDocument = json['idDocument'];
    String? idNumber;
    if (idDocument != null && idDocument is Map<String, dynamic>) {
      idNumber = idDocument['number'];
    }
    
    return ProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'citizen',
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      region: json['region'] ?? 'Dakar',
      currentLocation: json['currentLocation'] != null
          ? LocationModel.fromJson(json['currentLocation'])
          : null,
      address: addressModel,
      idType: json['idType'] ?? 'Carte d\'identité nationale',
      idNumber: idNumber,
      profilePicture: json['profilePicture'] != null
          ? ProfilePictureModel.fromJson(json['profilePicture'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convertit ce ProfileModel en JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'fullName': fullName,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'region': region,
      'idType': idType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (email != null) {
      data['email'] = email;
    }
    if (phone != null) {
      data['phone'] = phone;
    }
    if (currentLocation != null) {
      data['currentLocation'] = currentLocation!.toJson();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (idNumber != null) {
      data['idNumber'] = idNumber;
    }
    if (profilePicture != null) {
      data['profilePicture'] = profilePicture!.toJson();
    }

    return data;
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        role,
        isVerified,
        isActive,
        region,
        currentLocation,
        address,
        idType,
        idNumber,
        profilePicture,
        createdAt,
        updatedAt,
      ];
}

/// Modèle représentant la localisation d'un utilisateur
class LocationModel extends Equatable {
  final String type;
  final List<double> coordinates;
  final DateTime updatedAt;

  const LocationModel({
    required this.type,
    required this.coordinates,
    required this.updatedAt,
  });

  /// Crée un LocationModel à partir d'un JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [-17.4676, 14.7167], // Coordonnées par défaut pour Dakar
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convertit ce LocationModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [type, coordinates, updatedAt];
}

/// Modèle représentant l'adresse d'un utilisateur
class AddressModel extends Equatable {
  final String? street;
  final String? city;
  final String? postalCode;
  final String? neighborhood;

  const AddressModel({
    this.street,
    this.city,
    this.postalCode,
    this.neighborhood,
  });

  /// Crée un AddressModel à partir d'un JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street'],
      city: json['city'],
      postalCode: json['postalCode'],
      neighborhood: json['neighborhood'],
    );
  }

  /// Convertit cet AddressModel en JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (street != null) {
      data['street'] = street;
    }
    if (city != null) {
      data['city'] = city;
    }
    if (postalCode != null) {
      data['postalCode'] = postalCode;
    }
    if (neighborhood != null) {
      data['neighborhood'] = neighborhood;
    }
    
    return data;
  }

  @override
  List<Object?> get props => [street, city, postalCode, neighborhood];
}

/// Modèle représentant la photo de profil d'un utilisateur
class ProfilePictureModel extends Equatable {
  final String? url;
  final String? publicId;
  final DateTime uploadedAt;

  const ProfilePictureModel({
    this.url,
    this.publicId,
    required this.uploadedAt,
  });

  /// Crée un ProfilePictureModel à partir d'un JSON
  factory ProfilePictureModel.fromJson(Map<String, dynamic> json) {
    return ProfilePictureModel(
      url: json['url'],
      publicId: json['publicId'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
    );
  }

  /// Convertit ce ProfilePictureModel en JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'uploadedAt': uploadedAt.toIso8601String(),
    };
    
    if (url != null) {
      data['url'] = url;
    }
    if (publicId != null) {
      data['publicId'] = publicId;
    }
    
    return data;
  }

  @override
  List<Object?> get props => [url, publicId, uploadedAt];
}
