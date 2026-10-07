import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/home_model.dart';
import '../repo/home_repo.dart';

class HomeViewModel extends ViewModel {
  final HomeRepository _repository;

  int _selectedTabIndex = 0;
  String _selectedCategoryId = 'hazardous';
  HomeDashboardModel _dashboardData = const HomeDashboardModel();

  HomeViewModel({HomeRepository? repository})
      : _repository = repository ?? HomeRepositoryImpl() {
    fetchDashboardData();
  }

  int get selectedTabIndex => _selectedTabIndex;
  String get selectedCategoryId => _selectedCategoryId;
  HomeDashboardModel get dashboardData => _dashboardData;

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void fetchDashboardData() async {
    isLoading = true;
    try {
      _dashboardData = await _repository.getDashboardData();
    } catch (e) {
      _dashboardData = const HomeDashboardModel();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onBookNowPressed() {
    // Handle Booking action
  }
}
