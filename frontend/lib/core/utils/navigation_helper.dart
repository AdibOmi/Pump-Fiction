import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

class NavigationHelper {
  /// Safely navigate back or to dashboard if no previous route exists
  static void safeBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // If can't pop, navigate to dashboard to avoid black screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  /// Navigate to dashboard, replacing the current route
  static void goToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }

  /// Navigate to dashboard and remove all previous routes
  static void goToDashboardAndClearStack(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
      (route) => false,
    );
  }
}
