import '../model/onboarding_model.dart';

abstract class OnboardingRepository {
  Future<List<OnboardingModel>> getOnboardingSlides();
  Future<bool> setOnboardingCompleted();
  Future<bool> isOnboardingCompleted();
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  @override
  Future<List<OnboardingModel>> getOnboardingSlides() async {
    // Simulates or returns repository data for the onboarding slider screens
    return [
      const OnboardingModel(
        id: 1,
        type: OnboardingType.reduce,
        imagePath: 'assets/images/onboarding_reduce.png',
        category: 'REDUCE',
        title: 'Lighter habits,',
        highlightedTitle: 'greener future.',
        buttonText: 'Next',
        showLogo: false,
      ),
      const OnboardingModel(
        id: 2,
        type: OnboardingType.recycle,
        imagePath: 'assets/images/onboarding_recycle.png',
        category: 'RECYCLE',
        title: 'Sort smart,',
        highlightedTitle: 'build again.',
        buttonText: 'Next',
        showLogo: false,
      ),
      const OnboardingModel(
        id: 3,
        type: OnboardingType.reuse,
        imagePath: 'assets/images/onboarding_reuse.png',
        category: 'REUSE',
        title: 'Give products a',
        highlightedTitle: 'second chance',
        buttonText: 'Next',
        showLogo: false,
      ),
      const OnboardingModel(
        id: 4,
        type: OnboardingType.plantingGreen,
        imagePath: 'assets/images/onboarding_planting.png',
        title: 'Planting Green,',
        highlightedTitle: 'Growing Life',
        buttonText: 'Get Started',
        showLogo: true,
      ),
    ];
  }

  @override
  Future<bool> setOnboardingCompleted() async {
    return true;
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return false;
  }
}
