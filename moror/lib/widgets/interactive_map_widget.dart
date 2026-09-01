import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class InteractiveMapWidget extends StatefulWidget {
  final String locationName;
  final double latitude;
  final double longitude;

  const InteractiveMapWidget({
    super.key,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF090D16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // خلفية خطوط الطرق والمربعات التكتيكية الداكنة
            CustomPaint(
              size: Size.infinite,
              painter: _MapGridPainter(),
            ),

            // نقطة الرادار النابضة في المنتصف
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // حلقة النبض الخارجية
                      Container(
                        width: 60 * _pulseAnimation.value,
                        height: 60 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldPrimary.withValues(
                            alpha: (1 - _pulseController.value) * 0.4,
                          ),
                          border: Border.all(
                            color: AppColors.goldPrimary.withValues(
                              alpha: (1 - _pulseController.value),
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // الحلقة الوسطى
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldPrimary.withValues(alpha: 0.25),
                          border: Border.all(color: AppColors.goldPrimary, width: 2),
                        ),
                      ),
                      // المركز
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldPrimary,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // شريط علوي لإحداثيات الموقع
            Positioned(
              top: 12,
              right: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xDD0D111A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.gps_fixed_rounded,
                      color: AppColors.goldPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.locationName,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.goldPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // أزرار التحكم بالمحاكاة
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCC0D111A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.satellite_alt_rounded, size: 14, color: AppColors.goldPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'نظام التتبع الجغرافي للمرور',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1B2436)
      ..strokeWidth = 0.8;

    final roadPaint = Paint()
      ..color = const Color(0xFF28364F)
      ..strokeWidth = 4;

    final riverPaint = Paint()
      ..color = const Color(0xFF142E47)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    // رسم شبكة الخطوط
    const double step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // محاكاة مسار النيل وشوارع الخرطوم الرئيسية
    final path = Path();
    path.moveTo(size.width * 0.2, 0);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.4,
      size.width * 0.65,
      size.height * 0.6,
      size.width * 0.8,
      size.height,
    );
    canvas.drawPath(path, riverPaint);

    // شوارع رئيسية
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
