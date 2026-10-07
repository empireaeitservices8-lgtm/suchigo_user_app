import 'package:flutter/material.dart';
import '../../model/onboarding_model.dart';

class OnboardingSliderItem extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingSliderItem({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        model.imagePath,
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}


