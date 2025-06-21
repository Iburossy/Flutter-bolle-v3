import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

/// Service responsable de la gestion de la localisation
class LocationService {
  /// Clé API Google Maps
  final String apiKey;
  
  /// Constructeur
  LocationService({required this.apiKey});

  /// Vérifie si les services de localisation sont activés et demande les permissions nécessaires
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Les services de localisation ne sont pas activés, demander à l'utilisateur de les activer
      return false;
    }

    // Vérifier les permissions de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Les permissions sont refusées
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Les permissions sont refusées de façon permanente
      return false;
    }

    // Les permissions sont accordées
    return true;
  }

  /// Récupère la position actuelle de l'utilisateur
  Future<Position?> getCurrentPosition() async {
    try {
      // Vérifier les permissions
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Récupérer la position avec une précision élevée
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la position: $e');
      return null;
    }
  }

  /// Convertit une position en adresse lisible
  Future<String> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
      
      return 'Adresse inconnue';
    } catch (e) {
      debugPrint('Erreur lors de la conversion de la position en adresse: $e');
      return 'Erreur de géocodage';
    }
  }

  /// Récupère la position et l'adresse actuelles
  Future<Map<String, dynamic>> getCurrentLocationData() async {
    Position? position = await getCurrentPosition();
    
    if (position == null) {
      return {
        'success': false,
        'message': 'Impossible de récupérer la position',
      };
    }

    String address = await getAddressFromPosition(position);
    
    return {
      'success': true,
      'position': position,
      'address': address,
      'location': {
        'type': 'Point',
        'coordinates': [position.longitude, position.latitude],
        'address': address,
      }
    };
  }

  /// Calcule la distance entre deux positions (en mètres)
  double calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
  
  /// Convertit une adresse en coordonnées
  Future<Position?> getPositionFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la conversion de l\'adresse en position: $e');
      return null;
    }
  }
}
