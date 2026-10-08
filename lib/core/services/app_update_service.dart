import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppUpdateInfo {
  final int latestVersionCode;
  final String latestVersionName;
  final String downloadUrl;
  final String releaseNotes;
  final bool isMandatory;

  AppUpdateInfo({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.isMandatory,
  });

  factory AppUpdateInfo.fromMap(Map<String, dynamic> data) {
    return AppUpdateInfo(
      latestVersionCode: (data['latestVersionCode'] as num?)?.toInt() ?? 1,
      latestVersionName: data['latestVersionName'] as String? ?? '1.0.1',
      downloadUrl: data['downloadUrl'] as String? ?? '',
      releaseNotes: data['releaseNotes'] as String? ?? 'تحديثات وتحسينات جديدة',
      isMandatory: data['isMandatory'] as bool? ?? false,
    );
  }
}

class AppUpdateService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // النسخة الحالية للتطبيق (مرورك)
  static const int currentVersionCode = 2;
  static const String currentVersionName = '1.0.1';

  AppUpdateInfo? _updateInfo;
  bool _hasChecked = false;

  AppUpdateInfo? get updateInfo => _updateInfo;
  bool get hasChecked => _hasChecked;

  /// فحص توفر تحديث جديد
  Future<AppUpdateInfo?> checkUpdateAvailability() async {
    try {
      final doc = await _firestore.collection('app_config').doc('version').get();
      if (!doc.exists || doc.data() == null) {
        await _initDefaultConfig();
        return null;
      }

      final data = doc.data()!;
      _updateInfo = AppUpdateInfo.fromMap(data);
      _hasChecked = true;
      notifyListeners();

      if (_updateInfo!.latestVersionCode > currentVersionCode) {
        return _updateInfo;
      }
      return null;
    } catch (e) {
      debugPrint('[AppUpdateService] Error checking update: ');
      return null;
    }
  }

  /// إنشاء إعدادات افتراضية في Firestore
  Future<void> _initDefaultConfig() async {
    try {
      await _firestore.collection('app_config').doc('version').set({
        'latestVersionCode': 2,
        'latestVersionName': '1.0.1',
        'downloadUrl': 'https://github.com',
        'releaseNotes': 'تم تحديث اسم التطبيق إلى مرورك وتطبيق الشعار خدمات المرور بين يديك مع تحسينات شاملة.',
        'isMandatory': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[AppUpdateService] Error creating default version doc: ');
    }
  }

  /// فحص وعرض نافذة التحديث إن وُجد
  Future<void> checkForUpdate(BuildContext context, {bool isManual = false}) async {
    final info = await checkUpdateAvailability();

    if (!context.mounted) return;

    if (info != null && info.latestVersionCode > currentVersionCode) {
      showUpdateDialog(context, info);
    } else if (isManual) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'أنت تستخدم أحدث إصدار من تطبيق مرورك (v$currentVersionName)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// عرض نافذة التحديث الأنيقة
  void showUpdateDialog(BuildContext context, AppUpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: !info.isMandatory,
      builder: (ctx) => PopScope(
        canPop: !info.isMandatory,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldPrimary, width: 2),
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppColors.goldPrimary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تحديث جديد متاح 🚀',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'الإصدار الجديد: v${info.latestVersionName}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ما الجديد في هذا التحديث:',
                      style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      info.releaseNotes,
                      style: AppTypography.bodySmall.copyWith(
                        color: (Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (info.downloadUrl.isNotEmpty) {
                      final uri = Uri.parse(info.downloadUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('تحميل وتحديث الآن', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (!info.isMandatory) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'تذكيري لاحقاً',
                    style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? AppColors.textMuted : AppColors.lightTextMuted)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
