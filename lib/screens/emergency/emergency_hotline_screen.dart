import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/app_background.dart';
import '../../core/localization/app_strings.dart';

class EmergencyHotlineScreen extends StatefulWidget {
  const EmergencyHotlineScreen({super.key});

  @override
  State<EmergencyHotlineScreen> createState() => _EmergencyHotlineScreenState();
}

class _EmergencyHotlineScreenState extends State<EmergencyHotlineScreen> {
  bool _isSubmitting = false;

  Future<void> _submitReport(String urgencyLevel, String description) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // الحصول على الإحداثيات الحقيقية
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          throw Exception(context.tr('location_error'));
        }
      }
      
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      // حفظ البلاغ الفعلي في قاعدة البيانات ليقوم السيرفر بالتقاطه
      await FirebaseFirestore.instance.collection('emergencies').add({
        'userId': user?.uid ?? 'unknown',
        'urgencyLevel': urgencyLevel,
        'description': description,
        'location': GeoPoint(position.latitude, position.longitude), 
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: (Theme.of(context).brightness == Brightness.dark ? AppColors.card : AppColors.lightCard),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.goldPrimary),
          ),
          title: Row(
            children: [
              Icon(
                urgencyLevel == 'urgent' ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: urgencyLevel == 'urgent' ? AppColors.success : AppColors.goldPrimary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(context.tr('report_received')),
            ],
          ),
          content: Text(
            urgencyLevel == 'urgent' 
                ? context.tr('urgent_report_msg')
                : context.tr('cold_report_msg'),
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(context.tr('ok_btn'), style: const TextStyle(color: AppColors.goldPrimary)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('error_prefix')} $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showColdReportSheet() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: GlassCard(
          blur: 20,
          opacity: 0.3,
          tintColor: Colors.black,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('cold_report'),
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: context.tr('describe_case_hint'),
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    Navigator.pop(context);
                    _submitReport('cold', controller.text.trim());
                  },
                  child: Text(context.tr('send_report'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = GlassColors.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.tr('emergency_and_reports'), style: TextStyle(color: c.text)),
        iconTheme: IconThemeData(color: c.text),
      ),
      body: AppBackground(
        role: AppRole.citizen,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting)
                  const Center(child: CircularProgressIndicator(color: AppColors.error))
                else ...[
                  // زر الحالة المستعجلة (Urgent SOS)
                  GestureDetector(
                    onTap: () => _submitReport('urgent', context.tr('urgent_emergency_sent')),
                    child: GlassCard(
                      blur: 25,
                      opacity: c.isDark ? 0.25 : 0.8,
                      tintColor: Colors.redAccent,
                      child: Column(
                        children: [
                          const Icon(Icons.sos_rounded, color: Colors.white, size: 80),
                          const SizedBox(height: 16),
                          Text(
                            context.tr('urgent_emergency'),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('urgent_emergency_desc'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // زر الحالة الباردة (Cold Report)
                  GestureDetector(
                    onTap: _showColdReportSheet,
                    child: GlassCard(
                      blur: 15,
                      opacity: c.isDark ? 0.15 : 0.6,
                      tintColor: Colors.amber.shade700,
                      child: Column(
                        children: [
                          const Icon(Icons.traffic_rounded, color: Colors.white, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('cold_report'),
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('cold_report_desc'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
