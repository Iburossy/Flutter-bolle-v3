import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../injection_container.dart';
import '../../data/models/signup_request_model.dart';
import '../../domain/usecases/signup_user_usecase.dart';
import '../widgets/custom_auth_textfield.dart';
import '../widgets/auth_form_button.dart';
import 'login_screen.dart';
import 'verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  
  // Track which signup method is selected (email or phone)
  bool _useEmailSignup = false;

  // image signup
  final String _headerImagePath = 'assets/images/signup_header.png';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signupUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Create signup request model based on selected method
      final SignupRequestModel signupRequest;
      String? tempEmail; // Déclarer tempEmail ici pour qu'il soit accessible dans tout le scope de la méthode
      
      if (_useEmailSignup) {
        signupRequest = SignupRequestModel.withEmail(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
      } else {
        // Contournement pour le problème de backend qui vérifie toujours l'email
        // Générer un email temporaire unique basé sur le numéro de téléphone
        final phoneNumber = _phoneNumberController.text.replaceAll(RegExp(r'[\s-]'), '');
        tempEmail = 'phone_$phoneNumber@tempmail.bolle.sn';
        print('Génération d\'un email temporaire pour l\'inscription par téléphone: $tempEmail');
        
        signupRequest = SignupRequestModel(
          fullName: _fullNameController.text,
          phone: _phoneNumberController.text,
          email: tempEmail, // Ajout d'un email temporaire
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
      }
      
      // Get the use case from the service locator
      final signupUseCase = sl<SignupUserUseCase>();
      
      // Execute the use case
      final result = await signupUseCase(signupRequest);
      
      // Handle the result
      result.fold(
        (failure) {
          // Handle failure
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${failure.message}')),
          );
        },
        (authResponse) {
          // Handle success
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inscription réussie: ${authResponse.message}')),
          );
          
          // Extraire l'ID utilisateur de la réponse
          final userId = authResponse.user.id;
          
          // Déterminer le contact utilisé (email ou téléphone)
          final contactInfo = _useEmailSignup ? _emailController.text : _phoneNumberController.text;
          
          // Rediriger vers la page de vérification
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => VerificationScreen(
                userId: userId,
                contactInfo: contactInfo,
                isEmail: _useEmailSignup,
                // Transmettre l'email réel ou temporaire utilisé lors de l'inscription
                registeredEmail: _useEmailSignup ? _emailController.text : (tempEmail ?? ''),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 249, 249), // Couleur de fond blanc
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.05),
                // Header Image (Placeholder - replace with your actual image)
                // Image.asset(
                //   _headerImagePath, 
                //   height: screenHeight * 0.20, 
                //   fit: BoxFit.contain,
                // ),
                Container(
                  height: screenHeight * 0.20,
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_add_alt_1_rounded, size: 70, color: Color(0xFF357E78)), // Placeholder icon
                  // child: Image.asset(_headerImagePath, fit: BoxFit.contain), // Use this once you have the image
                ),
                SizedBox(height: screenHeight * 0.02),
                const Text(
                  'Créer un compte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                CustomAuthTextField(
                  controller: _fullNameController,
                  hintText: 'Nom complet / Full Name',
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom complet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                
                // Toggle between email and phone number signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _useEmailSignup = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_useEmailSignup ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            border: Border.all(
                              color: !_useEmailSignup ? Theme.of(context).primaryColor : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Téléphone',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_useEmailSignup ? Theme.of(context).primaryColor : Colors.grey.shade700,
                              fontWeight: !_useEmailSignup ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _useEmailSignup = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _useEmailSignup ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            border: Border.all(
                              color: _useEmailSignup ? Theme.of(context).primaryColor : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Email',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _useEmailSignup ? Theme.of(context).primaryColor : Colors.grey.shade700,
                              fontWeight: _useEmailSignup ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16.0),
                
                // Show either email or phone number field based on selection
                _useEmailSignup
                  ? CustomAuthTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse email';
                        }
                        // Basic email validation
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Veuillez entrer une adresse email valide';
                        }
                        return null;
                      },
                    )
                  : CustomAuthTextField(
                      controller: _phoneNumberController,
                      hintText: 'Numéro de téléphone / Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        // Vérifier que le numéro commence par 7 et a 9 chiffres (format sénégalais)
                        final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');
                        if (!RegExp(r'^7[0-9]{8}$').hasMatch(cleanedValue) && 
                            !RegExp(r'^\+?221-?7[0-9]{8}$').hasMatch(cleanedValue)) {
                          return 'Format invalide. Exemple: 77 123 45 67';
                        }
                        return null;
                      },
                    ),
                const SizedBox(height: 16.0),
                const SizedBox(height: 16.0),
                CustomAuthTextField(
                  controller: _passwordController,
                  hintText: 'Mot de passe / Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                CustomAuthTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirmer le mot de passe / Confirm Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                AuthFormButton(
                  text: 'Créer un compte',
                  onPressed: _signupUser,
                  isLoading: _isLoading,
                  backgroundColor: const Color.fromARGB(255, 53, 126, 120), // Vert sarcelle
                  textColor: Colors.white,
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Vous avez déjà un compte? ',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Se connecter',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 53, 126, 120), // vert sarcelle
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate back to LoginScreen or pop if it's on the stack
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
