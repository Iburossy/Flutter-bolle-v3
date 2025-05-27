import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../injection_container.dart';
import '../../data/models/login_request_model.dart';
import '../../domain/usecases/login_user_usecase.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../widgets/custom_auth_textfield.dart';
import '../widgets/auth_form_button.dart';
import 'signup_screen.dart'; // To navigate to SignupScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  // Track which login method is selected (email or phone)
  bool _useEmailLogin = false;

  // image login
  final String _headerImagePath = 'assets/images/login_header.png';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Create login request model based on selected method
      final LoginRequestModel loginRequest;
      if (_useEmailLogin) {
        loginRequest = LoginRequestModel.withEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        loginRequest = LoginRequestModel.withPhoneNumber(
          phoneNumber: _phoneNumberController.text,
          password: _passwordController.text,
        );
      }
      
      // Get the use case from the service locator
      final loginUseCase = sl<LoginUserUseCase>();
      
      // Execute the use case
      final result = await loginUseCase(loginRequest);
      
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
            const SnackBar(
              content: Text('Connexion réussie'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Navigate to HomeScreen after successful login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3), // Couleur de fond beige clair
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
                //   height: screenHeight * 0.25, 
                //   fit: BoxFit.contain,
                // ),
                // Temporary placeholder for the header image section
                Container(
                  height: screenHeight * 0.25,
                  alignment: Alignment.center,
                  child: const Icon(Icons.security_rounded, size: 80, color: Color(0xFF003A70)), // Placeholder icon
                  // child: Image.asset(_headerImagePath, fit: BoxFit.contain), // Use this once you have the image
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                
                // Toggle between email and phone number login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _useEmailLogin = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_useEmailLogin ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            border: Border.all(
                              color: !_useEmailLogin ? Theme.of(context).primaryColor : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Téléphone',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_useEmailLogin ? Theme.of(context).primaryColor : Colors.grey.shade700,
                              fontWeight: !_useEmailLogin ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _useEmailLogin = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _useEmailLogin ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            border: Border.all(
                              color: _useEmailLogin ? Theme.of(context).primaryColor : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Email',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _useEmailLogin ? Theme.of(context).primaryColor : Colors.grey.shade700,
                              fontWeight: _useEmailLogin ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16.0),
                
                // Show either email or phone number field based on selection
                _useEmailLogin
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
                      hintText: 'Numéro de téléphone',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        // TODO: Add more specific phone number validation if needed
                        return null;
                      },
                    ),
                const SizedBox(height: 16.0),
                CustomAuthTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password logic
                      print('Forgot password pressed');
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                AuthFormButton(
                  text: 'Log In',
                  onPressed: _loginUser,
                  isLoading: _isLoading,
                  backgroundColor: const Color(0xFF003A70), // Bleu foncé
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Register',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50), // Vert
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignupScreen()),
                              );
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
