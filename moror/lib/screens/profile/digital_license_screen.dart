import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/sovereign_badge.dart';

class DigitalLicenseScreen extends StatefulWidget {
  const DigitalLicenseScreen({super.key});

  @override
  State<DigitalLicenseScreen> createState() => _DigitalLicenseScreenState();
}

class _DigitalLicenseScreenState extends State<DigitalLicenseScreen> {
  bool _showBackFace = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    final String fullName = user?.fullName ?? 'مواطن سوداني';
    final String nationalId = user?.nationalId ?? '11111111111';
    final String licenseNumber = user?.driverLicenseNumber.isNotEmpty == true
        ? user!.driverLicenseNumber
        : 'رخصة مؤقتة';
    final String state = user?.state ?? 'الخرطوم';
    final String? profileImageUrl = user?.profileImageUrl;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الرخصة الرقمية'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SovereignBadge(
                title: 'الإدارة العامة للمرور',
                subtitle: 'وثيقة رسمية معتمدة إلكترونياً',
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => setState(() => _showBackFace = !_showBackFace),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: _showBackFace
                      ? _buildLicenseBack(licenseNumber, nationalId)
                      : _buildLicenseFront(fullName, nationalId, licenseNumber, state, profileImageUrl),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('اضغط على البطاقة للوجه الآخر', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('حالة الرخصة: سارية وموثقة', style: AppTypography.titleSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('تاريخ الانتهاء: 2028/11/15', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseFront(String fullName, String nationalId, String licenseNumber, String state, String? profileImageUrl) {
    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.6),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('جمهورية السودان', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('رخصة قيادة وطنية', style: TextStyle(color: AppColors.primary, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.wifi, color: AppColors.primary, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 75,
                height: 95,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  image: profileImageUrl != null ? DecorationImage(image: NetworkImage(profileImageUrl), fit: BoxFit.cover) : null,
                ),
                child: profileImageUrl == null ? const Icon(Icons.person, color: Colors.white54, size: 40) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('الاسم:', fullName),
                    const SizedBox(height: 8),
                    _buildInfoRow('الرقم الوطني:', nationalId),
                    const SizedBox(height: 8),
                    _buildInfoRow('رقم الرخصة:', licenseNumber),
                    const SizedBox(height: 8),
                    _buildInfoRow('الولاية:', state),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseBack(String licenseNumber, String nationalId) {
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      height: 195,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.6),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تعليمات:', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                const Text('1. يجب حمل هذه الرخصة أثناء القيادة.', style: TextStyle(color: Colors.white70, fontSize: 10)),
                const Text('2. يعاقب القانون على تزوير أو إساءة استخدامها.', style: TextStyle(color: Colors.white70, fontSize: 10)),
                const Spacer(),
                Text(licenseNumber, style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: QrImageView(data: 'SUDAN_LICENSE:$nationalId:$licenseNumber', version: QrVersions.auto, size: 80, padding: EdgeInsets.zero),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
