import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SuccessCheckmarkAnimation extends StatefulWidget {
  final double size;
  final VoidCallback? onComplete;

  const SuccessCheckmarkAnimation({
    super.key,
    this.size = 100.0,
    this.onComplete,
  });

  @override
  State<SuccessCheckmarkAnimation> createState() => _SuccessCheckmarkAnimationState();
}

class _SuccessCheckmarkAnimationState extends State<SuccessCheckmarkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeInOutBack),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.goldPrimary : AppColors.goldDark;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SuccessCheckmarkPainter(
              circleProgress: _circleAnimation.value,
              checkmarkProgress: _checkmarkAnimation.value,
              color: primaryColor,
            ),
          );
        },
      ),
    );
  }
}

class _SuccessCheckmarkPainter extends CustomPainter {
  final double circleProgress;
  final double checkmarkProgress;
  final Color color;

  _SuccessCheckmarkPainter({
    required this.circleProgress,
    required this.checkmarkProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // 1. رسم دائرة الظل الخلفية
    if (circleProgress > 0) {
      canvas.drawCircle(center, radius * circleProgress, paint);
    }

    // 2. رسم الدائرة الأساسية الخارجية
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    if (circleProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        -pi / 2,
        2 * pi * circleProgress,
        false,
        circlePaint,
      );
    }

    // 3. رسم علامة الصح المتحركة (Checkmark)
    if (checkmarkProgress > 0) {
      final checkmarkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      // النقطة الأولى: بداية الصح (اليسار)
      final startPoint = Offset(size.width * 0.28, size.height * 0.52);
      // النقطة الثانية: زاوية الصح (الأسفل)
      final midPoint = Offset(size.width * 0.44, size.height * 0.68);
      // النقطة الثالثة: نهاية الصح (اليمين الأعلى)
      final endPoint = Offset(size.width * 0.72, size.height * 0.36);

      path.moveTo(startPoint.dx, startPoint.dy);

      // حساب المسار بناءً على تقدم الأنيميشن
      if (checkmarkProgress < 0.4) {
        // رسم الجزء الأول فقط (اليسار إلى الأسفل)
        double t = checkmarkProgress / 0.4;
        double currentX = lerpDouble(startPoint.dx, midPoint.dx, t);
        double currentY = lerpDouble(startPoint.dy, midPoint.dy, t);
        path.lineTo(currentX, currentY);
      } else {
        // رسم الجزء الأول كاملاً ثم التمدد نحو الأعلى
        path.lineTo(midPoint.dx, midPoint.dy);
        double t = (checkmarkProgress - 0.4) / 0.6;
        double currentX = lerpDouble(midPoint.dx, endPoint.dx, t);
        double currentY = lerpDouble(midPoint.dy, endPoint.dy, t);
        path.lineTo(currentX, currentY);
      }

      canvas.drawPath(path, checkmarkPaint);
    }
  }

  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(covariant _SuccessCheckmarkPainter oldDelegate) {
    return oldDelegate.circleProgress != circleProgress ||
        oldDelegate.checkmarkProgress != checkmarkProgress ||
        oldDelegate.color != color;
  }
}
