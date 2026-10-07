import '../model/splash_model.dart';

abstract class SplashRepository {
  Future<SplashModel> getSplashData();
  Future<bool> checkInitialRoute();
}

class SplashRepositoryImpl implements SplashRepository {
  @override
  Future<SplashModel> getSplashData() async {
    return const SplashModel();
  }

  @override
  Future<bool> checkInitialRoute() async {
    // Check if user is logged in or if onboarding should be displayed
    return true;
  }
}
