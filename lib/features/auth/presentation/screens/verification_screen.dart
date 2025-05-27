import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_service.dart';
import '../widgets/auth_form_button.dart';
import 'login_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String userId;
  final String contactInfo; // Email ou téléphone utilisé pour l'inscription
  final bool isEmail;
  final String registeredEmail; // Email utilisé lors de l'inscription (réel ou temporaire)

  const VerificationScreen({
    Key? key,
    required this.userId,
    required this.contactInfo,
    required this.isEmail,
    required this.registeredEmail,
  }) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  bool _isLoading = false;
  String? _errorMessage;
  late final ApiService _apiService;
  
  @override
  void initState() {
    super.initState();
    _apiService = ApiService(client: http.Client());
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _verificationCode {
    return _codeControllers.map((controller) => controller.text).join();
  }

  void _verifyCode() async {
    if (_verificationCode.length != 6) {
      setState(() {
        _errorMessage = 'Veuillez entrer le code complet à 6 caractères';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> requestBody = {
        'email': widget.registeredEmail, // Toujours envoyer l'email enregistré (réel ou temporaire)
        'emailCode': _verificationCode,
        'smsCode': _verificationCode, // Le backend attend les deux codes et vérifie s'ils sont identiques
      };

      if (widget.isEmail) {
        // Pour une inscription par email, le backend attend un champ 'phone'.
        // Nous utilisons une valeur de remplacement cohérente.
        requestBody['phone'] = '000000000'; 
      } else {
        // Pour une inscription par téléphone, 'widget.contactInfo' contient le vrai numéro.
        requestBody['phone'] = widget.contactInfo;
      }

      final response = await _apiService.post(
        ApiConfig.verifyAccountEndpoint,
        body: requestBody,
      );
      
      print('Verification request sent with: $requestBody');

      if (response['success'] == true) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte vérifié avec succès!')),
        );
        
        // Rediriger vers la page de connexion
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response['message'] ?? 'Erreur de vérification';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    }
  }

  void _resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.post(
        ApiConfig.resendVerificationCodesEndpoint,
        body: {
          'userId': widget.userId,
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code de vérification renvoyé avec succès')),
        );
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Erreur lors du renvoi du code';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3), // Couleur de fond beige clair
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF357E78)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Icon(
                Icons.verified_user_outlined,
                size: 80,
                color: Color(0xFF357E78),
              ),
              const SizedBox(height: 24),
              const Text(
                'Vérification du compte',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isEmail
                    ? 'Nous avons envoyé un code à ${widget.contactInfo}'
                    : 'Nous avons envoyé un SMS avec un code au ${widget.contactInfo}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Le code contient des chiffres et des lettres',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => _buildCodeInput(index),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              AuthFormButton(
                text: 'Vérifier',
                onPressed: _verifyCode,
                isLoading: _isLoading,
                backgroundColor: const Color(0xFF357E78),
                textColor: Colors.white,
              ),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Vous n\'avez pas reçu de code? ',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Renvoyer',
                        style: const TextStyle(
                          color: Color(0xFF003A70),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _isLoading ? null : _resendCode,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInput(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.text,
        textAlign: TextAlign.center,
        maxLength: 1,
        textCapitalization: TextCapitalization.none,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF357E78), width: 1.5),
          ),
        ),
        inputFormatters: [
          // Accepter les chiffres et les lettres (a-z, A-Z, 0-9)
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        ],
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Passer au champ suivant
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              // Dernier champ, masquer le clavier
              FocusScope.of(context).unfocus();
            }
          } else if (value.isEmpty && index > 0) {
            // Revenir au champ précédent si on efface
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
