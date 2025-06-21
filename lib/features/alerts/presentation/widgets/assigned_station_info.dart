import 'package:flutter/material.dart';

/// Widget pour afficher les informations du poste d'hygiène assigné à une alerte
class AssignedStationInfo extends StatelessWidget {
  final Map<String, dynamic>? stationData;

  const AssignedStationInfo({
    Key? key,
    required this.stationData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stationData == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_city, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Poste d\'hygiène assigné',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              context,
              'Nom:',
              stationData!['name'] ?? 'Non disponible',
              Icons.business,
            ),
            if (stationData!['location'] != null && stationData!['location']['address'] != null)
              _buildInfoRow(
                context,
                'Adresse:',
                stationData!['location']['address'],
                Icons.location_on,
              ),
            if (stationData!['contactInfo'] != null)
              _buildInfoRow(
                context,
                'Contact:',
                _formatContactInfo(stationData!['contactInfo']),
                Icons.phone,
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Implémenter la navigation vers la carte pour voir l'emplacement du poste
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir: voir sur la carte'),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Voir sur la carte'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatContactInfo(Map<String, dynamic> contactInfo) {
    final List<String> contacts = [];
    
    if (contactInfo['phone'] != null && contactInfo['phone'].toString().isNotEmpty) {
      contacts.add(contactInfo['phone']);
    }
    
    if (contactInfo['email'] != null && contactInfo['email'].toString().isNotEmpty) {
      contacts.add(contactInfo['email']);
    }
    
    return contacts.isEmpty ? 'Non disponible' : contacts.join(' • ');
  }
}
