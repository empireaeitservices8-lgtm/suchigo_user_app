import 'package:flutter/material.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/onboarding_model.dart';
import '../repo/onboarding_repo.dart';

class OnboardingViewModel extends ViewModel {
  final OnboardingRepository _repository;
  final PageController pageController = PageController();

  int _currentIndex = 0;
  List<OnboardingModel> _slides = [];

  OnboardingViewModel({OnboardingRepository? repository})
      : _repository = repository ?? OnboardingRepositoryImpl() {
    loadSlides();
  }

  int get currentIndex => _currentIndex;
  List<OnboardingModel> get slides => _slides;
  int get totalSlides => _slides.length;
  bool get isLastSlide => _currentIndex == _slides.length - 1;

  void loadSlides() async {
    isLoading = true;
    try {
      _slides = await _repository.getOnboardingSlides();
    } catch (e) {
      _slides = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void nextPage({VoidCallback? onComplete}) {
    if (_currentIndex < _slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding(onComplete: onComplete);
    }
  }

  void skipToLast() {
    if (_slides.isNotEmpty) {
      pageController.animateToPage(
        _slides.length - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void completeOnboarding({VoidCallback? onComplete}) async {
    await _repository.setOnboardingCompleted();
    if (onComplete != null) {
      onComplete();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
