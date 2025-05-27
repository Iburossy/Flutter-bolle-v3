import 'package:equatable/equatable.dart';

/// Model class representing a signup request to the API
class SignupRequestModel extends Equatable {
  final String fullName;
  final String? email;
  final String? phone;
  final String password;
  final String confirmPassword;

  /// Create a signup request with either email or phone number
  /// At least one of email or phone must be provided
  const SignupRequestModel({
    required this.fullName,
    this.email,
    this.phone,
    required this.password,
    required this.confirmPassword,
  }) : assert(email != null || phone != null, 'Either email or phone must be provided');

  /// Factory constructor for creating a signup request with email
  factory SignupRequestModel.withEmail({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return SignupRequestModel(
      fullName: fullName,
      email: email,
      phone: '000000000', // S'assurer que le téléphone est '000000000' pour les inscriptions par email
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  /// Factory constructor for creating a signup request with phone number
  factory SignupRequestModel.withPhoneNumber({
    required String fullName,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) {
    return SignupRequestModel(
      fullName: fullName,
      phone: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  /// Converts this SignupRequestModel to a JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'fullName': fullName,
      'password': password,
      'confirmPassword': confirmPassword,
    };

    // Add either email or phone, or both if available
    if (email != null && email!.isNotEmpty) {
      data['email'] = email;
    }
    
    if (phone != null && phone!.isNotEmpty) {
      // Formater le numéro de téléphone avec le préfixe du pays pour le Sénégal
      String formattedPhone = phone!;
      
      // Supprimer les espaces et les tirets
      formattedPhone = formattedPhone.replaceAll(RegExp(r'[\s-]'), '');
      
      // Vérifier si le numéro commence déjà par +221 ou 221
      if (!formattedPhone.startsWith('+221') && !formattedPhone.startsWith('221')) {
        // Si le numéro commence par un 7, ajouter le préfixe +221
        if (formattedPhone.startsWith('7')) {
          formattedPhone = '+221$formattedPhone';
        }
      } else if (formattedPhone.startsWith('221') && !formattedPhone.startsWith('+221')) {
        // Si le numéro commence par 221 sans +, ajouter le +
        formattedPhone = '+$formattedPhone';
      }
      
      data['phone'] = formattedPhone;
      print('Sending formatted phone number: $formattedPhone');
    }

    return data;
  }

  @override
  List<Object?> get props => [fullName, email, phone, password, confirmPassword];
}
