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
import 'package:suchigo_user_app/features/orders/view/track_pickup_screen.dart';
import 'package:suchigo_user_app/features/schedule_pickup/view/schedule_pickup_screen.dart';
import 'package:suchigo_user_app/features/rewards/view/my_rewards_screen.dart';
import 'package:suchigo_user_app/features/profile/view/my_account_screen.dart';
import 'package:suchigo_user_app/features/settings/view/about_app_screen.dart';
import 'package:suchigo_user_app/features/settings/view/contact_us_screen.dart';
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
      HomeScreen.routeName: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final int initialIndex = args is int ? args : 0;
        return HomeScreen(initialTabIndex: initialIndex);
      },
      NotificationScreen.routeName: (context) => const NotificationScreen(),
      WasteDetailsScreen.routeName: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final String? initialCatId = args is String ? args : null;
        return WasteDetailsScreen(initialCategoryId: initialCatId);
      },
      SchedulePickupScreen.routeName: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        int? wasteType;
        String? wasteTypeName;
        int? subWasteType;
        if (args is Map) {
          wasteType = int.tryParse(args['wasteType']?.toString() ?? '') ??
              int.tryParse(args['waste_type']?.toString() ?? '');
          wasteTypeName = args['wasteTypeName']?.toString() ??
              args['waste_type_name']?.toString();
          subWasteType = int.tryParse(args['subWasteType']?.toString() ?? '') ??
              int.tryParse(args['sub_waste_type']?.toString() ?? '');
        } else if (args is int) {
          wasteType = args;
        }
        return SchedulePickupScreen(
          initialWasteType: wasteType,
          initialWasteTypeName: wasteTypeName,
          initialSubWasteType: subWasteType,
        );
      },
      MapScreen.routeName: (context) => const MapScreen(),
      BookingConfirmedScreen.routeName: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        BookingConfirmedModel? bookingData;
        if (args is BookingConfirmedModel) {
          bookingData = args;
        } else if (args is Map) {
          bookingData = BookingConfirmedModel.fromJson(args);
        } else if (args is int) {
          bookingData = BookingConfirmedModel(
            bookingId: args.toString(),
            orderId: args.toString(),
            pickupId: args,
          );
        } else if (args is String) {
          final clean = args.replaceAll('#', '').trim();
          bookingData = BookingConfirmedModel(
            bookingId: clean,
            orderId: clean,
          );
        }
        return BookingConfirmedScreen(bookingData: bookingData);
      },
      WalletScreen.routeName: (context) => const WalletScreen(),
      OrderHistoryScreen.routeName: (context) => const OrderHistoryScreen(),
      TrackPickupScreen.routeName: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is TrackPickupScreenArgs) {
          return TrackPickupScreen(
            pickupId: args.pickupId,
            orderId: args.orderId,
          );
        } else if (args is Map) {
          final int pickupId = int.tryParse(args['pickupId']?.toString() ?? '') ??
              int.tryParse(args['pickup_id']?.toString() ?? '') ??
              int.tryParse(args['id']?.toString() ?? '') ??
              140;
          final int? orderId = int.tryParse(args['orderId']?.toString() ?? '') ??
              int.tryParse(args['order_id']?.toString() ?? '') ??
              int.tryParse(args['order_number']?.toString() ?? '');
          return TrackPickupScreen(
            pickupId: pickupId,
            orderId: orderId,
          );
        } else if (args is int) {
          return TrackPickupScreen(pickupId: args);
        }
        return const TrackPickupScreen(pickupId: 140);
      },
      BillsReceivedScreen.routeName: (context) => const BillsReceivedScreen(),
      MyRewardsScreen.routeName: (context) => const MyRewardsScreen(),
      PrivacySecurityScreen.routeName: (context) =>
          const PrivacySecurityScreen(),
      HelpSupportScreen.routeName: (context) => const HelpSupportScreen(),
      ContactUsScreen.routeName: (context) => const ContactUsScreen(),
      MyAccountScreen.routeName: (context) => const MyAccountScreen(),
      AboutAppScreen.routeName: (context) => const AboutAppScreen(),
    };

Widget? _getScreen(RouteSettings settings) {
  switch (settings.name) {
    case HomeScreen.routeName:
      final args = settings.arguments;
      final int initialIndex = args is int ? args : 0;
      return HomeScreen(initialTabIndex: initialIndex);
    case WasteDetailsScreen.routeName:
      final args = settings.arguments;
      final String? initialCatId = args is String ? args : null;
      return WasteDetailsScreen(initialCategoryId: initialCatId);
    case CompleteProfileScreen.routeName:
      final args = settings.arguments is CompleteProfileScreenArgs
          ? settings.arguments as CompleteProfileScreenArgs
          : const CompleteProfileScreenArgs(phoneNumber: '', otp: '');
      return CompleteProfileScreen(
        phoneNumber: args.phoneNumber,
        otp: args.otp,
      );
    case ConnectionFailedScreen.routeName:
      final params = settings.arguments is ConnectionFailedScreenParams
          ? settings.arguments as ConnectionFailedScreenParams
          : ConnectionFailedScreenParams();
      return ConnectionFailedScreen(
        param: params,
      );
    case BookingConfirmedScreen.routeName:
      final args = settings.arguments;
      BookingConfirmedModel? bookingData;
      if (args is BookingConfirmedModel) {
        bookingData = args;
      } else if (args is Map) {
        bookingData = BookingConfirmedModel.fromJson(args);
      } else if (args is int) {
        bookingData = BookingConfirmedModel(
          bookingId: args.toString(),
          orderId: args.toString(),
          pickupId: args,
        );
      } else if (args is String) {
        final clean = args.replaceAll('#', '').trim();
        bookingData = BookingConfirmedModel(
          bookingId: clean,
          orderId: clean,
        );
      }
      return BookingConfirmedScreen(bookingData: bookingData);
    case TrackPickupScreen.routeName:
      final args = settings.arguments;
      if (args is TrackPickupScreenArgs) {
        return TrackPickupScreen(
          pickupId: args.pickupId,
          orderId: args.orderId,
        );
      } else if (args is Map) {
        final int pickupId = int.tryParse(args['pickupId']?.toString() ?? '') ??
            int.tryParse(args['pickup_id']?.toString() ?? '') ??
            int.tryParse(args['id']?.toString() ?? '') ??
            140;
        final int? orderId = int.tryParse(args['orderId']?.toString() ?? '') ??
            int.tryParse(args['order_id']?.toString() ?? '') ??
            int.tryParse(args['order_number']?.toString() ?? '');
        return TrackPickupScreen(
          pickupId: pickupId,
          orderId: orderId,
        );
      } else if (args is int) {
        return TrackPickupScreen(pickupId: args);
      }
      return const TrackPickupScreen(pickupId: 140);
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
