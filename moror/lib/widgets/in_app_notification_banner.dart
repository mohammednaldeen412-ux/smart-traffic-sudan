import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/notification_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// Banner إشعار داخلي يظهر فوق المحتوى عند استقبال FCM في المقدمة
class InAppNotificationListener extends StatefulWidget {
  final Widget child;

  const InAppNotificationListener({super.key, required this.child});

  @override
  State<InAppNotificationListener> createState() =>
      _InAppNotificationListenerState();
}

class _InAppNotificationListenerState
    extends State<InAppNotificationListener>
    with SingleTickerProviderStateMixin {
  StreamSubscription<InAppNotification>? _sub;
  InAppNotification? _current;
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sub = context
          .read<NotificationService>()
          .inAppNotifications
          .listen(_showBanner);
    });
  }

  void _showBanner(InAppNotification notif) {
    _dismissTimer?.cancel();
    setState(() => _current = notif);
    _animController.forward(from: 0);
    _dismissTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() {
    _animController.reverse().then((_) {
      if (mounted) setState(() => _current = null);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'violation':
        return AppColors.error;
      case 'payment':
        return AppColors.success;
      case 'announcement':
        return AppColors.goldPrimary;
      default:
        return AppColors.goldPrimary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'violation':
        return Icons.warning_amber_rounded;
      case 'payment':
        return Icons.check_circle_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_current != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: _slideAnim,
              child: GestureDetector(
                onTap: _dismiss,
                onHorizontalDragEnd: (_) => _dismiss(),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _typeColor(_current!.type)
                            .withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _typeColor(_current!.type)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _typeIcon(_current!.type),
                            color: _typeColor(_current!.type),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _current!.title,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_current!.body.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  _current!.body,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
