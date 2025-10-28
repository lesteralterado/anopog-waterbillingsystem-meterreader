import 'package:flutter/material.dart';
import '../presentation/meter_reading_entry/meter_reading_entry.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/reading_history/reading_history.dart';
import '../presentation/billing_receipt_generation/billing_receipt_generation.dart';
import '../presentation/user_profile_settings/user_profile_settings.dart';
import '../presentation/purok_selection_dashboard/purok_selection_dashboard.dart';
import '../presentation/meter_reading_list/meter_reading_list.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String meterReadingEntry = '/meter-reading-entry';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String readingHistory = '/reading-history';
  static const String billingReceiptGeneration = '/billing-receipt-generation';
  static const String userProfileSettings = '/user-profile-settings';
  static const String purokSelectionDashboard = '/purok-selection-dashboard';
  static const String meterReadingList = '/meter-reading-list';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    meterReadingEntry: (context) => const MeterReadingEntry(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    readingHistory: (context) => const ReadingHistory(),
    billingReceiptGeneration: (context) => const BillingReceiptGeneration(),
    userProfileSettings: (context) => const UserProfileSettings(),
    purokSelectionDashboard: (context) => const PurokSelectionDashboard(),
    meterReadingList: (context) => const MeterReadingList(),
    // TODO: Add your other routes here
  };
}
