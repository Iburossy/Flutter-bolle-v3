import '../models/service_contact_model.dart';

/// Service qui fournit les contacts des services d'urgence et administratifs
class ServiceDirectoryService {
  /// Liste des contacts des services d'urgence et administratifs au Sénégal
  List<ServiceContactModel> getServiceContacts() {
    return [
      // Services d'urgence
      ServiceContactModel(
        id: 'police',
        name: 'Police',
        phoneNumber: '17',
        description: 'Police nationale du Sénégal - Numéro d\'urgence',
        iconName: 'local_police',
        category: 'Urgence',
      ),
      ServiceContactModel(
        id: 'pompiers',
        name: 'Sapeurs Pompiers',
        phoneNumber: '18',
        description: 'Brigade Nationale des Sapeurs Pompiers - Urgences',
        iconName: 'fire_truck',
        category: 'Urgence',
      ),
      ServiceContactModel(
        id: 'samu',
        name: 'SAMU',
        phoneNumber: '1515',
        description: 'Service d\'Aide Médicale Urgente',
        iconName: 'medical_services',
        category: 'Urgence',
      ),
      ServiceContactModel(
        id: 'gendarmerie',
        name: 'Gendarmerie',
        phoneNumber: '800 00 20 20',
        description: 'Gendarmerie Nationale du Sénégal',
        iconName: 'security',
        category: 'Urgence',
      ),
      
      // Services administratifs
      ServiceContactModel(
        id: 'hygiene',
        name: 'Service d\'Hygiène',
        phoneNumber: '33 889 31 03',
        description: 'Service National d\'Hygiène',
        iconName: 'cleaning_services',
        category: 'Administration',
      ),
      ServiceContactModel(
        id: 'customs',
        name: 'Douanes',
        phoneNumber: '33 889 74 01',
        description: 'Direction Générale des Douanes',
        iconName: 'business_center',
        category: 'Administration',
      ),
      ServiceContactModel(
        id: 'mairie-dakar',
        name: 'Mairie de Dakar',
        phoneNumber: '33 849 09 09',
        description: 'Hôtel de Ville de Dakar',
        iconName: 'account_balance',
        category: 'Administration',
      ),
      
      // Services de santé
      ServiceContactModel(
        id: 'hopital-principal',
        name: 'Hôpital Principal',
        phoneNumber: '33 839 50 50',
        description: 'Hôpital Principal de Dakar',
        iconName: 'local_hospital',
        category: 'Santé',
      ),
      ServiceContactModel(
        id: 'hopital-fann',
        name: 'Hôpital de Fann',
        phoneNumber: '33 869 18 18',
        description: 'Centre Hospitalier National Universitaire de Fann',
        iconName: 'local_hospital',
        category: 'Santé',
      ),
    ];
  }

  /// Obtenir les contacts par catégorie
  List<ServiceContactModel> getContactsByCategory(String category) {
    return getServiceContacts()
        .where((contact) => contact.category == category)
        .toList();
  }

  /// Obtenir toutes les catégories disponibles
  List<String> getCategories() {
    return getServiceContacts()
        .map((contact) => contact.category)
        .toSet()
        .toList();
  }
}
