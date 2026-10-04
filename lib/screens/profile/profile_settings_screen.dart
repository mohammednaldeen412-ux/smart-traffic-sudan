import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/theme_provider.dart';
import '../../core/services/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_background.dart';
import '../auth/login_screen.dart';
import 'driver_license_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final c = GlassColors.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final localeProv = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.tr('settings'), style: TextStyle(color: c.text, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: c.text),
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        role: AppRole.citizen,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              children: [
                // كرت الهوية الزجاجي
                GlassCard(
                  blur: 15,
                  opacity: c.isDark ? 0.15 : 0.6,
                  tintColor: c.isDark ? Colors.white : Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: c.text.withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: c.text, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.fullName ?? context.tr('citizen'),
                          style: TextStyle(color: c.text, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${context.tr('national_id')} ${user?.nationalId ?? ""}',
                          style: const TextStyle(color: AppColors.goldPrimary, fontSize: 14, fontFamily: 'monospace'),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF69F0AE).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.tr('citizen_account_tag'),
                            style: const TextStyle(color: Color(0xFF69F0AE), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // خيارات الإعدادات
                _buildGlassListTile(
                  context: context,
                  icon: Icons.card_membership_rounded,
                  title: context.tr('digital_license'),
                  subtitle: context.tr('vehicles_management'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DriverLicenseScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildGlassListTile(
                  context: context,
                  icon: Icons.language_rounded,
                  title: context.tr('app_language'),
                  subtitle: localeProv.isArabic ? context.tr('arabic_lang') : context.tr('english_lang'),
                  onTap: () {
                    localeProv.toggleLanguage();
                  },
                ),
                const SizedBox(height: 12),
                
                _buildGlassListTile(
                  context: context,
                  icon: themeProv.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  title: context.tr('dark_mode_title'),
                  subtitle: themeProv.isDark ? context.tr('dark_mode_active') : context.tr('dark_mode_inactive'),
                  onTap: () {
                    themeProv.toggleTheme();
                  },
                ),
                const SizedBox(height: 12),
                
                _buildGlassListTile(
                  context: context,
                  icon: Icons.notifications_active_rounded,
                  title: context.tr('notifications_title'),
                  subtitle: context.tr('notifications_subtitle'),
                  onTap: () {},
                ),
                const SizedBox(height: 32),

                // زر تسجيل الخروج
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    onPressed: () async {
                      await auth.logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(context.tr('logout'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final c = GlassColors.of(context);
    return GlassCard(
      blur: 10,
      opacity: c.isDark ? 0.1 : 0.6,
      tintColor: c.isDark ? Colors.white : Colors.black,
      onTap: onTap,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.text.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: c.text.withValues(alpha: 0.7)),
        ),
        title: Text(title, style: TextStyle(color: c.text, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: c.text.withValues(alpha: 0.6), fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: c.text.withValues(alpha: 0.3), size: 16),
      ),
    );
  }
}
