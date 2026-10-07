import 'package:flutter/material.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/map_location_model.dart';
import '../repo/map_location_repo.dart';

class MapLocationViewModel extends ViewModel {
  final MapLocationRepository _repository;

  final TextEditingController searchController = TextEditingController();
  SelectedAddressModel? _selectedAddress;
  List<SelectedAddressModel> _searchResults = [];
  bool _isSearching = false;
  double _currentLat = 10.1132;
  double _currentLng = 76.2894;

  MapLocationViewModel({MapLocationRepository? repository})
      : _repository = repository ?? MapLocationRepositoryImpl() {
    searchController.addListener(_onSearchChanged);
    fetchAddressForCurrentLocation();
  }

  SelectedAddressModel? get selectedAddress => _selectedAddress;
  List<SelectedAddressModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;

  void _onSearchChanged() {
    final query = searchController.text.trim();
    if (query.isNotEmpty) {
      searchLocation(query);
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
      notifyListeners();
    }
  }

  void fetchAddressForCurrentLocation() async {
    isLoading = true;
    try {
      _selectedAddress = await _repository.getAddressFromCoordinates(
        _currentLat,
        _currentLng,
      );
    } catch (e) {
      _selectedAddress = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectSearchResult(SelectedAddressModel address) {
    _selectedAddress = address;
    _currentLat = address.latitude;
    _currentLng = address.longitude;
    _searchResults = [];
    _isSearching = false;
    searchController.clear();
    notifyListeners();
  }

  void updateLocationCoordinates(double lat, double lng) {
    _currentLat = lat;
    _currentLng = lng;
    fetchAddressForCurrentLocation();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
