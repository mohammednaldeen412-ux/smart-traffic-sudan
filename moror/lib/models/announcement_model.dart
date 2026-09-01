import 'package:cloud_firestore/cloud_firestore.dart';

enum AnnouncementCategory {
  general,
  emergency,
  trafficUpdate,
  lawUpdate,
}

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final AnnouncementCategory category;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final bool isPinned;
  final String authorId;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.category = AnnouncementCategory.general,
    this.imageUrl,
    DateTime? createdAt,
    this.expiryDate,
    this.isPinned = false,
    required this.authorId,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category.name,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
        'isPinned': isPinned,
        'authorId': authorId,
      };

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) => AnnouncementModel(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        category: _parseCategory(json['category']),
        imageUrl: json['imageUrl'] as String?,
        createdAt: _parseDateTime(json['createdAt']),
        expiryDate: json['expiryDate'] != null ? _parseDateTime(json['expiryDate']) : null,
        isPinned: json['isPinned'] as bool? ?? false,
        authorId: json['authorId'] as String? ?? 'system',
      );

  static AnnouncementCategory _parseCategory(dynamic category) {
    if (category == 'emergency') return AnnouncementCategory.emergency;
    if (category == 'trafficUpdate') return AnnouncementCategory.trafficUpdate;
    if (category == 'lawUpdate') return AnnouncementCategory.lawUpdate;
    return AnnouncementCategory.general;
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }
}
