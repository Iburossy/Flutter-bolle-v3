import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        backgroundColor: const Color(0xFF006837),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo et titre
            Center(
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF006837),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Center(
                      child: Text(
                        'Yollë',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // À propos de l'application
            _buildSectionTitle('À propos de Yollë'),
            _buildParagraph(
              'Yollë est une application citoyenne conçue pour faciliter la communication entre les citoyens et les services publics au Sénégal. Elle permet de signaler des problèmes, d\'accéder à des services essentiels et de contribuer à l\'amélioration de la vie communautaire.',
            ),
            const SizedBox(height: 24),
            
            // Fonctionnalités principales
            _buildSectionTitle('Fonctionnalités principales'),
            _buildFeatureItem(
              Icons.warning_amber_rounded,
              'Signalement d\'alertes',
              'Signalez facilement des problèmes urbains (déchets, pannes, accidents, etc.) directement aux services concernés.',
            ),
            _buildFeatureItem(
              Icons.location_on,
              'Géolocalisation précise',
              'Localisez automatiquement les problèmes signalés ou sélectionnez manuellement l\'emplacement sur une carte interactive.',
            ),
            _buildFeatureItem(
              Icons.phone,
              'Annuaire des services',
              'Accédez rapidement aux numéros d\'urgence et des services administratifs essentiels.',
            ),
            _buildFeatureItem(
              Icons.photo_camera,
              'Preuves multimédias',
              'Joignez des photos, vidéos ou enregistrements audio à vos signalements pour plus d\'efficacité.',
            ),
            const SizedBox(height: 24),
            
            // Notre mission
            _buildSectionTitle('Notre mission'),
            _buildParagraph(
              'Notre mission est de créer un pont entre les citoyens et les services publics pour faciliter la résolution des problèmes quotidiens et améliorer la qualité de vie dans les communautés sénégalaises.',
            ),
            _buildParagraph(
              'Nous croyons en la force de l\'engagement citoyen et en la capacité des technologies numériques à transformer positivement la société.',
            ),
            const SizedBox(height: 24),
            
            // Contact
            _buildSectionTitle('Contact'),
            _buildContactItem(Icons.email, 'Email', 'contact@yolle.sn'),
            _buildContactItem(Icons.phone, 'Téléphone', '+221 XX XXX XX XX'),
            _buildContactItem(Icons.language, 'Site web', 'www.yolle.sn'),
            
            const SizedBox(height: 32),
            
            // Copyright
            const Center(
              child: Text(
                '© 2025 Yollë - Tous droits réservés',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF006837),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF006837),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF006837),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
