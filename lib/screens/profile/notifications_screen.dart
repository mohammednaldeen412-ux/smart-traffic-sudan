import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isArabic ? 'سجل الإشعارات' : 'Notifications', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: AppBackground(
        role: AppRole.citizen,
        child: SafeArea(
          child: user == null
              ? Center(child: Text(isArabic ? 'يرجى تسجيل الدخول' : 'Please log in'))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('userId', isEqualTo: user.uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          isArabic ? 'لا توجد إشعارات حالياً.' : 'No notifications right now.',
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final title = data['title'] ?? 'إشعار';
                        final body = data['body'] ?? '';
                        final imageUrl = data['imageUrl'];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.goldPrimary,
                                child: Icon(Icons.notifications_rounded, color: Colors.white),
                              ),
                              title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(body, style: TextStyle(color: textColor.withValues(alpha: 0.8))),
                                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: Colors.transparent,
                                            contentPadding: EdgeInsets.zero,
                                            content: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
