import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final Color tintColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.15,
    this.padding = const EdgeInsets.all(20.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.tintColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius as BorderRadius,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: tintColor.withValues(alpha: opacity),
                borderRadius: borderRadius,
                border: Border.all(
                  color: tintColor.withValues(alpha: opacity * 1.5),
                  width: 1.0,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tintColor.withValues(alpha: opacity),
                    tintColor.withValues(alpha: opacity * 0.3),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
