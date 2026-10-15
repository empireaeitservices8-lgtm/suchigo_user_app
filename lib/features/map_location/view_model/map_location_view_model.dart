import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import 'package:suchigo_user_app/widgets/custom_toast.dart';
import '../model/map_location_model.dart';
import '../repo/map_location_repo.dart';

class MapLocationViewModel extends ViewModel {
  final MapLocationRepository _repository;

  final TextEditingController searchController = TextEditingController();
  GoogleMapController? mapController;
  SelectedAddressModel? _selectedAddress;
  List<SelectedAddressModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLocating = false;
  bool _hasLocationPermission = false;
  double _currentLat = 10.00383;
  double _currentLng = 76.37574;
  int _zoom = 15;
  Timer? _debounceTimer;

  MapLocationViewModel({MapLocationRepository? repository})
      : _repository = repository ?? MapLocationRepositoryImpl() {
    searchController.addListener(_onSearchChanged);
    fetchAddressForCurrentLocation();
    checkInitialLocationPermission();
  }

  SelectedAddressModel? get selectedAddress => _selectedAddress;
  List<SelectedAddressModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isLocating => _isLocating;
  bool get hasLocationPermission => _hasLocationPermission;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;
  int get zoom => _zoom;

  String get staticMapUrl =>
      _repository.getStaticMapUrl(_currentLat, _currentLng, zoom: _zoom);

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onCameraMove(CameraPosition position) {
    _currentLat = position.target.latitude;
    _currentLng = position.target.longitude;
  }

  void onCameraIdle() {
    fetchAddressForCurrentLocation();
  }

  void animateTo(double lat, double lng, {double? zoomLevel}) {
    _currentLat = lat;
    _currentLng = lng;
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(lat, lng),
        zoomLevel ?? _zoom.toDouble(),
      ),
    );
    fetchAddressForCurrentLocation();
  }

  Future<void> checkInitialLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        _hasLocationPermission = true;
        notifyListeners();
        moveToCurrentLocation(showToastOnError: false);
      }
    } catch (_) {}
  }

  Future<void> moveToCurrentLocation({
    bool showToastOnError = true,
  }) async {
    if (_isLocating) return;

    _isLocating = true;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showToastOnError) {
          CustomToast.show(
            null,
            message: 'Please enable location services (GPS) to find your location.',
            icon: Icons.location_off_rounded,
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (showToastOnError) {
            CustomToast.show(
              null,
              message: 'Location permission is required to find your location.',
              icon: Icons.location_off_rounded,
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (showToastOnError) {
          CustomToast.show(
            null,
            message:
                'Location permissions are permanently denied. Please enable them in app settings.',
            icon: Icons.settings_outlined,
          );
        }
        return;
      }

      _hasLocationPermission = true;

      // 1. Immediately animate to last known position if available for instant response
      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          animateTo(position.latitude, position.longitude);
        }
      } catch (_) {}

      // 2. Fetch fresh high-accuracy position
      try {
        final accuratePosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        position = accuratePosition;
        animateTo(accuratePosition.latitude, accuratePosition.longitude);
      } catch (e) {
        if (position == null && showToastOnError) {
          CustomToast.show(
            null,
            message: 'Could not fetch current GPS location. Please try again.',
            icon: Icons.location_off_rounded,
          );
        }
      }
    } catch (e) {
      if (showToastOnError) {
        CustomToast.show(
          null,
          message: 'Unable to get location: $e',
          icon: Icons.error_outline_rounded,
        );
      }
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    _debounceTimer?.cancel();

    if (query.isNotEmpty) {
      _debounceTimer = Timer(const Duration(milliseconds: 350), () {
        searchLocation(query);
      });
    } else {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
    }
  }

  void searchLocation(String query) async {
    _isSearching = true;
    notifyListeners();
    try {
      _searchResults = await _repository.searchPlaces(query);
    } catch (e) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void fetchAddressForCurrentLocation() async {
    try {
      final address = await _repository.getAddressFromCoordinates(
        _currentLat,
        _currentLng,
      );
      _selectedAddress = address;
    } catch (e) {
      // Keep existing address if available
    } finally {
      notifyListeners();
    }
  }

  void selectSearchResult(SelectedAddressModel address) async {
    _searchResults = [];
    _isSearching = false;
    searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();

    if (address.placeId != null && address.placeId!.isNotEmpty) {
      try {
        final details = await _repository.getPlaceDetails(address.placeId!);
        _selectedAddress = details;
        animateTo(details.latitude, details.longitude);
      } catch (e) {
        _selectedAddress = address;
        animateTo(address.latitude, address.longitude);
      }
    } else {
      _selectedAddress = address;
      animateTo(address.latitude, address.longitude);
    }
  }

  void updateLocationCoordinates(double lat, double lng) {
    animateTo(lat, lng);
  }

  void updateCoordinatesOnly(double lat, double lng) {
    _currentLat = lat;
    _currentLng = lng;
    notifyListeners();
  }

  void zoomIn() {
    if (_zoom < 19) {
      _zoom++;
      mapController?.animateCamera(CameraUpdate.zoomIn());
      notifyListeners();
    }
  }

  void zoomOut() {
    if (_zoom > 10) {
      _zoom--;
      mapController?.animateCamera(CameraUpdate.zoomOut());
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    mapController?.dispose();
    super.dispose();
  }
}

