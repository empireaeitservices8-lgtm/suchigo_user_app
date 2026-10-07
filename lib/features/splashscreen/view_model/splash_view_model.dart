import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/splash_model.dart';
import '../repo/splash_repo.dart';

class SplashViewModel extends ViewModel {
  final SplashRepository _repository;
  SplashModel _splashModel = const SplashModel();

  SplashViewModel({SplashRepository? repository})
      : _repository = repository ?? SplashRepositoryImpl() {
    initSplash();
  }

  SplashModel get splashModel => _splashModel;

  void initSplash() async {
    _splashModel = await _repository.getSplashData();
    notifyListeners();
  }
}
