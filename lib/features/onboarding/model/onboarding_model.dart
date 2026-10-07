enum OnboardingType {
  reduce,
  recycle,
  reuse,
  plantingGreen,
}

class OnboardingModel {
  final int id;
  final OnboardingType type;
  final String imagePath;
  final String? category;
  final String title;
  final String? highlightedTitle;
  final String? subtitle;
  final String buttonText;
  final bool showLogo;

  const OnboardingModel({
    required this.id,
    required this.type,
    required this.imagePath,
    this.category,
    required this.title,
    this.highlightedTitle,
    this.subtitle,
    this.buttonText = 'Next',
    this.showLogo = false,
  });
}
