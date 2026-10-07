import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/waste_details_model.dart';
import '../repo/waste_details_repo.dart';

class WasteDetailsViewModel extends ViewModel {
  final WasteDetailsRepository _repository;

  WastePropertyType _propertyType = WastePropertyType.residential;
  List<WasteCategoryDetailModel> _categories = [];
  List<SubWasteRateModel> _subWasteRates = [];
  String? _selectedCategoryId;
  int _bottomNavIndex = 0;

  WasteDetailsViewModel({
    WasteDetailsRepository? repository,
    String? initialCategoryId,
  })  : _repository = repository ?? WasteDetailsRepositoryImpl(),
        _selectedCategoryId = initialCategoryId {
    loadData();
  }

  WastePropertyType get propertyType => _propertyType;
  List<WasteCategoryDetailModel> get categories => _categories;
  List<SubWasteRateModel> get subWasteRates => _subWasteRates;
  String? get selectedCategoryId => _selectedCategoryId;
  int get bottomNavIndex => _bottomNavIndex;
  bool get canContinue => _selectedCategoryId != null;

  void setPropertyType(WastePropertyType type) {
    if (_propertyType != type) {
      _propertyType = type;
      loadData();
    }
  }

  void setBottomNavIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null;
    } else {
      _selectedCategoryId = categoryId;
      loadSubWasteRates(categoryId);
    }
    notifyListeners();
  }

  void loadData() async {
    isLoading = true;
    try {
      _categories = await _repository.getWasteCategories(_propertyType);
      _selectedCategoryId ??= 'sanitary';
      await loadSubWasteRates(_selectedCategoryId!);
    } catch (e) {
      _categories = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubWasteRates(String categoryId) async {
    try {
      _subWasteRates = await _repository.getSubWasteRates(categoryId);
    } catch (e) {
      _subWasteRates = [];
    }
    notifyListeners();
  }
}
