import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../auth/login_screen.dart';
import '../officer/officer_navigation_wrapper.dart';
import '../admin/admin_navigation_wrapper.dart';
import 'main_navigation_wrapper.dart';

class SmartRoleRouter extends StatelessWidget {
  const SmartRoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // شاشة تحميل مؤقتة لضمان جلب البيانات
    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    if (auth.isOfficer) {
      return const OfficerNavigationWrapper();
    }

    if (auth.currentUser?.isAdmin ?? false) {
      return const AdminNavigationWrapper();
    }

    return const MainNavigationWrapper();
  }
}
