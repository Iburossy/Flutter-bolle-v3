import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenDebugWidget extends StatefulWidget {
  const TokenDebugWidget({Key? key}) : super(key: key);

  @override
  State<TokenDebugWidget> createState() => _TokenDebugWidgetState();
}

class _TokenDebugWidgetState extends State<TokenDebugWidget> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _token = 'Chargement...';
  static const String _tokenKey = 'auth_token';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      setState(() {
        _token = token ?? 'Aucun token trouvé';
      });
      print('Token Debug: $_token');
    } catch (e) {
      setState(() {
        _token = 'Erreur: ${e.toString()}';
      });
      print('Token Debug Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Débogage Token',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Token: ${_token.length > 30 ? '${_token.substring(0, 30)}...' : _token}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadToken,
              child: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }
}
