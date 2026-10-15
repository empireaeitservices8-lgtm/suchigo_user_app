import 'package:suchigo_user_app/config/app_config.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import 'package:suchigo_user_app/widgets/custom_toast.dart';
import '../model/waste_details_model.dart';
import '../repo/waste_details_repo.dart';

class WasteDetailsViewModel extends ViewModel {
  final WasteDetailsRepository _repository;

  WastePropertyType _propertyType = WastePropertyType.residential;
  List<WasteCategoryDetailModel> _categories = [];
  List<SubWasteRateModel> _subWasteRates = [];
  String? _selectedCategoryId;
  int _bottomNavIndex = 0;

  String? _errorMessage;

  WasteDetailsViewModel({
    WasteDetailsRepository? repository,
    String? initialCategoryId,
  })  : _repository = repository ?? WasteDetailsRepositoryImpl(),
        _selectedCategoryId = null {
    loadData();
  }

  WastePropertyType get propertyType => _propertyType;
  List<WasteCategoryDetailModel> get categories => _categories;
  List<SubWasteRateModel> get subWasteRates => _subWasteRates;
  String? get selectedCategoryId => _selectedCategoryId;
  int get bottomNavIndex => _bottomNavIndex;
  String? get errorMessage => _errorMessage;
  bool get canContinue =>
      _selectedCategoryId != null &&
      _categories.any((c) => c.id == _selectedCategoryId && c.isEnabled);

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
    if (categoryId == 'e_waste') {
      final ctx = AppConfig.navKey.currentContext;
      if (ctx != null) {
        CustomToast.showDisabledAlert(
          ctx,
          message: 'E-Waste collection is currently disabled.',
        );
      }
      return;
    }

    try {
      final cat = _categories.firstWhere((c) => c.id == categoryId);
      if (!cat.isEnabled) {
        final ctx = AppConfig.navKey.currentContext;
        if (ctx != null) {
          CustomToast.showDisabledAlert(
            ctx,
            message: '${cat.title} service is currently disabled.',
          );
        }
        return;
      }
    } catch (_) {}

    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null;
      _subWasteRates = [];
    } else {
      _selectedCategoryId = categoryId;
      loadSubWasteRates(categoryId: categoryId);
    }
    notifyListeners();
  }

  void loadData() async {
    isLoading = true;
    _errorMessage = null;
    try {
      _categories = await _repository.getWasteCategories(_propertyType);
      if (_selectedCategoryId != null) {
        await loadSubWasteRates(categoryId: _selectedCategoryId);
      } else {
        _subWasteRates = [];
      }
    } catch (e) {
      _categories = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubWasteRates({String? categoryId}) async {
    isLoading = true;
    notifyListeners();
    try {
      _subWasteRates = await _repository.getSubWasteRates(
        categoryId: categoryId,
        onError: (error) {
          _errorMessage = error.message;
        },
      );
    } catch (e) {
      _subWasteRates = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
