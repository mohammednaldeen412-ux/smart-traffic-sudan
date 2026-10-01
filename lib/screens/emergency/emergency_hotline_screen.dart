import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/glass_card.dart';

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
          throw Exception('يجب تفعيل خدمات الموقع الجغرافي للاستجابة السريعة.');
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
          backgroundColor: AppColors.card,
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
              const Text('تم استلام البلاغ'),
            ],
          ),
          content: Text(
            urgencyLevel == 'urgent' 
                ? 'تم استلام بلاغك الطارئ! تم إرسال إحداثيات موقعك فوراً لغرفة التحكم والنجدة في طريقها إليك.'
                : 'شكراً لتعاونك. تم تسجيل ملاحظتك المرورية وسيتم مراجعتها من قبل الإدارة.',
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('حسناً', style: TextStyle(color: AppColors.goldPrimary)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: AppColors.error),
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
              const Text(
                'إبلاغ عن حالة مرورية',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'وصف الحالة (مثال: زحام شديد، إشارة معطلة...)',
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
                  child: const Text('إرسال البلاغ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('الطوارئ والبلاغات', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // خلفية داكنة فخمة للطوارئ
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/citizen_header.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
              ),
            ),
          ),
          
          SafeArea(
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
                      onTap: () => _submitReport('urgent', 'حالة طوارئ مستعجلة (تم إرسال الموقع)'),
                      child: GlassCard(
                        blur: 25,
                        opacity: 0.25,
                        tintColor: Colors.redAccent,
                        child: const Column(
                          children: [
                            Icon(Icons.sos_rounded, color: Colors.redAccent, size: 80),
                            SizedBox(height: 16),
                            Text(
                              'طوارئ مستعجلة',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'حادث سير، إصابات، حرائق\nسيتم إرسال موقعك الجغرافي فوراً وتوجيه أقرب دورية',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 14),
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
                        opacity: 0.15,
                        tintColor: Colors.amber,
                        child: const Column(
                          children: [
                            Icon(Icons.traffic_rounded, color: Colors.amber, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'إبلاغ عن حالة مرورية',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'زحام خانق، إشارة معطلة، عائق في الطريق',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 14),
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
        ],
      ),
    );
  }
}
