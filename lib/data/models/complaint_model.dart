class ComplaintModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolution;

  ComplaintModel({
    required this.id, required this.userId, required this.title,
    required this.description, this.status = 'open', this.priority = 'medium',
    this.assignedTo, DateTime? createdAt, this.resolvedAt, this.resolution,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ComplaintModel.fromMap(String id, Map<String, dynamic> map) => ComplaintModel(
    id: id, userId: map['userId'] ?? '', title: map['title'] ?? '',
    description: map['description'] ?? '', status: map['status'] ?? 'open',
    priority: map['priority'] ?? 'medium', assignedTo: map['assignedTo'],
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    resolvedAt: (map['resolvedAt'] as dynamic)?.toDate(),
    resolution: map['resolution'],
  );

  Map<String, dynamic> toMap() => {
    'userId': userId, 'title': title, 'description': description,
    'status': status, 'priority': priority, 'assignedTo': assignedTo,
    'createdAt': createdAt, 'resolvedAt': resolvedAt, 'resolution': resolution,
  };
}
