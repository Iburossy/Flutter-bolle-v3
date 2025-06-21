import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/location_service.dart';
import '../../../../injection_container.dart';

class LocationMapWidget extends StatefulWidget {
  final Function(Position position, String address)? onLocationSelected;
  final Position? initialPosition;
  final double height;
  final bool showControls;

  const LocationMapWidget({
    Key? key,
    this.onLocationSelected,
    this.initialPosition,
    this.height = 200,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  final LocationService _locationService = sl<LocationService>();
  final Completer<GoogleMapController> _controller = Completer();
  
  Position? _currentPosition;
  String _currentAddress = "Chargement de l'adresse...";
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    
    try {
      // Si une position initiale est fournie, l'utiliser
      if (widget.initialPosition != null) {
        _currentPosition = widget.initialPosition;
        _updateMarkerAndAddress(_currentPosition!);
      } else {
        // Sinon, récupérer la position actuelle
        final locationData = await _locationService.getCurrentLocationData();
        
        if (locationData['success']) {
          _currentPosition = locationData['position'];
          _currentAddress = locationData['address'];
          _updateMarker(_currentPosition!);
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de la carte: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateMarker(Position position) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: _currentAddress),
      ),
    );
  }

  Future<void> _updateMarkerAndAddress(Position position) async {
    _currentPosition = position;
    _currentAddress = await _locationService.getAddressFromPosition(position);
    _updateMarker(position);
    
    if (mounted) {
      setState(() {});
    }
    
    // Notifier le parent si nécessaire
    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(_currentPosition!, _currentAddress);
    }
  }

  Future<void> _goToCurrentLocation() async {
    final locationData = await _locationService.getCurrentLocationData();
    
    if (locationData['success']) {
      final GoogleMapController controller = await _controller.future;
      final position = locationData['position'] as Position;
      
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ));
      
      await _updateMarkerAndAddress(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentPosition == null) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  zoom: 15,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onTap: (LatLng latLng) async {
                  final position = Position(
                    latitude: latLng.latitude,
                    longitude: latLng.longitude,
                    timestamp: DateTime.now(),
                    accuracy: 0,
                    altitude: 0,
                    heading: 0,
                    speed: 0,
                    speedAccuracy: 0,
                    altitudeAccuracy: 0,
                    headingAccuracy: 0,
                  );
                  
                  await _updateMarkerAndAddress(position);
                },
              ),
              if (widget.showControls)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    onPressed: _goToCurrentLocation,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            _currentAddress,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
