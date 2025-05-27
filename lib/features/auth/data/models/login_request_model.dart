import 'package:equatable/equatable.dart';

/// Model class representing a login request to the API
class LoginRequestModel extends Equatable {
  final String? email;
  final String? phone;
  final String password;

  /// Create a login request with either email or phone number
  /// At least one of email or phone must be provided
  const LoginRequestModel({
    this.email,
    this.phone,
    required this.password,
  }) : assert(email != null || phone != null, 'Either email or phone must be provided');

  /// Factory constructor for creating a login request with email
  factory LoginRequestModel.withEmail({
    required String email,
    required String password,
  }) {
    return LoginRequestModel(
      email: email,
      password: password,
    );
  }

  /// Factory constructor for creating a login request with phone number
  factory LoginRequestModel.withPhoneNumber({
    required String phoneNumber,
    required String password,
  }) {
    return LoginRequestModel(
      phone: phoneNumber,
      password: password,
    );
  }

  /// Converts this LoginRequestModel to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'password': password,
    };

    // Add either email or phone, or both if available
    if (email != null) {
      data['email'] = email;
    }
    if (phone != null) {
      data['phone'] = phone;
    }

    return data;
  }

  @override
  List<Object?> get props => [email, phone, password];
}
