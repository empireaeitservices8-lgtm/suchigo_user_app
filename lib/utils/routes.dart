import 'package:suchigo_user_app/features/auth/view/auth_screen.dart';
import 'package:suchigo_user_app/features/auth/view/complete_profile_screen.dart';
import 'package:suchigo_user_app/features/bills/view/bills_received_screen.dart';
import 'package:suchigo_user_app/features/booking_confirmed/model/booking_confirmed_model.dart';
import 'package:suchigo_user_app/features/booking_confirmed/view/booking_confirmed_screen.dart';
import 'package:suchigo_user_app/features/home/view/home_screen.dart';
import 'package:suchigo_user_app/features/map_location/view/map_screen.dart';
import 'package:suchigo_user_app/features/notifications/view/notification_screen.dart';
import 'package:suchigo_user_app/features/onboarding/view/onboarding_screen.dart';
import 'package:suchigo_user_app/features/orders/view/order_history_screen.dart';
import 'package:suchigo_user_app/features/schedule_pickup/view/schedule_pickup_screen.dart';
import 'package:suchigo_user_app/features/settings/view/about_app_screen.dart';
import 'package:suchigo_user_app/features/settings/view/help_support_screen.dart';
import 'package:suchigo_user_app/features/settings/view/privacy_security_screen.dart';
import 'package:suchigo_user_app/features/splashscreen/view/splashscreen.dart';
import 'package:suchigo_user_app/features/wallet/view/wallet_screen.dart';
import 'package:suchigo_user_app/features/waste_details/view/waste_details_screen.dart';
import 'package:suchigo_user_app/utils/connection_failed_screen.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext context)> appRoutes() => {
      SplashScreen.routeName: (context) => const SplashScreen(),
      OnboardingScreen.routeName: (context) => const OnboardingScreen(),
      AuthScreen.routeName: (context) => const AuthScreen(),
      HomeScreen.routeName: (context) => const HomeScreen(),
      NotificationScreen.routeName: (context) => const NotificationScreen(),
      WasteDetailsScreen.routeName: (context) => const WasteDetailsScreen(),
      SchedulePickupScreen.routeName: (context) => const SchedulePickupScreen(),
      MapScreen.routeName: (context) => const MapScreen(),
      BookingConfirmedScreen.routeName: (context) =>
          const BookingConfirmedScreen(),
      WalletScreen.routeName: (context) => const WalletScreen(),
      OrderHistoryScreen.routeName: (context) => const OrderHistoryScreen(),
      BillsReceivedScreen.routeName: (context) => const BillsReceivedScreen(),
      PrivacySecurityScreen.routeName: (context) =>
          const PrivacySecurityScreen(),
      HelpSupportScreen.routeName: (context) => const HelpSupportScreen(),
      AboutAppScreen.routeName: (context) => const AboutAppScreen(),
    };

Widget? _getScreen(RouteSettings settings) {
  switch (settings.name) {
    case CompleteProfileScreen.routeName:
      final args = settings.arguments is CompleteProfileScreenArgs
          ? settings.arguments as CompleteProfileScreenArgs
          : const CompleteProfileScreenArgs(phoneNumber: '', otp: '');
      return CompleteProfileScreen(
        phoneNumber: args.phoneNumber,
        otp: args.otp,
      );
    case ConnectionFailedScreen.routeName:
      ConnectionFailedScreenParams params =
          settings.arguments as ConnectionFailedScreenParams;
      return ConnectionFailedScreen(
        param: params,
      );
    case BookingConfirmedScreen.routeName:
      final bookingData = settings.arguments is BookingConfirmedModel
          ? settings.arguments as BookingConfirmedModel
          : null;
      return BookingConfirmedScreen(bookingData: bookingData);
    // case OwnerManageUserScreen.route:
    //   OwnerManageUserScreenParams params =
    //       settings.arguments as OwnerManageUserScreenParams;
    //   return OwnerManageUserScreen(
    //     params: params,
    //   );

    default:
      return null;
  }
}

RouteFactory onAppGenerateRoute() => (settings) {
      Widget? screen = _getScreen(settings);
      if (screen != null) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, c) {
            return FadeTransition(opacity: a, child: c);
          },
        );
      }
      return null;
    };
