import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_user_app/features/onboarding/view/onboarding_screen.dart';
import 'package:suchigo_user_app/features/onboarding/view/widgets/leaf_background.dart';
import 'package:suchigo_user_app/features/splashscreen/view_model/splash_view_model.dart';
import 'package:suchigo_user_app/providers/theme_provider.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/SplashScreen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SplashViewModel _splashViewModel;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _splashViewModel = SplashViewModel();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeProvider>().applySavedTheme(context);
    });

    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _splashViewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Soft Green Leaf Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: LeafBackgroundPainter(),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/splash_logo.png',
                  width: 260.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

