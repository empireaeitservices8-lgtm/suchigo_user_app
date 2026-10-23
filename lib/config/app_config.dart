import 'package:flutter/material.dart';
import 'package:suchigo_user_app/utils/enums.dart';

class AppConfig {
  static const appName = "SuchiGo";
  static const bundleId = "com.suchigo.suchigo_app";
  static const designWidth = 375;
  static const designHeight = 812;

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  GlobalKey bottomNavigationKey = GlobalKey();
  static bool isDebugMode = true;

  static EnumBuildEnvironment server = EnumBuildEnvironment.dg;
}
