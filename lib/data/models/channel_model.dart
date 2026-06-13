import 'package:cloud_firestore/cloud_firestore.dart';

/// قناة بث: تلفزيون أو إذاعة، تُعرض للمشتركين عبر روابط البث.
class ChannelModel {
  final String id;
  final String name;
  final String type; // 'tv' أو 'radio'
  final String category; // مثل: رياضة، أخبار، أطفال
  final String streamUrl;
  final String logoUrl;
  final bool isActive;
  final int order;
  final DateTime createdAt;

  ChannelModel({
    required this.id,
    required this.name,
    required this.type,
    this.category = '',
    required this.streamUrl,
    this.logoUrl = '',
    this.isActive = true,
    this.order = 0,
    required this.createdAt,
  });

  bool get isRadio => type == 'radio';

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'tv',
      category: map['category'] ?? '',
      streamUrl: map['streamUrl'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'category': category,
      'streamUrl': streamUrl,
      'logoUrl': logoUrl,
      'isActive': isActive,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ChannelModel copyWith({
    String? id,
    String? name,
    String? type,
    String? category,
    String? streamUrl,
    String? logoUrl,
    bool? isActive,
    int? order,
    DateTime? createdAt,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
