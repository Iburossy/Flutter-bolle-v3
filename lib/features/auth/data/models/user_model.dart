import 'package:equatable/equatable.dart';

/// Model class representing a user in the application
class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? region;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.region,
    required this.createdAt,
  });

  /// Creates a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      region: json['region'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Converts this UserModel to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'fullName': fullName,
      'region': region,
      'createdAt': createdAt.toIso8601String(),
    };
    
    if (email != null) {
      data['email'] = email;
    }
    if (phone != null) {
      data['phone'] = phone;
    }
    
    return data;
  }

  @override
  List<Object?> get props => [id, fullName, email, phone, region, createdAt];
}
