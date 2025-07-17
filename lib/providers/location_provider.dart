import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentPosition = await LocationService.getCurrentLocation();
      if (_currentPosition != null) {
        _currentAddress = await LocationService.getAddressFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}