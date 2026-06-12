class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String? routerId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  NotificationModel({
    required this.id, required this.userId, required this.title,
    required this.body, this.type = 'info', this.isRead = false,
    this.routerId, this.data, DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) => NotificationModel(
    id: id, userId: map['userId'] ?? '', title: map['title'] ?? '',
    body: map['body'] ?? '', type: map['type'] ?? 'info',
    isRead: map['isRead'] ?? false, routerId: map['routerId'],
    data: map['data'] as Map<String, dynamic>?,
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'userId': userId, 'title': title, 'body': body, 'type': type,
    'isRead': isRead, 'routerId': routerId, 'data': data, 'createdAt': createdAt,
  };
}
