class MaintenanceModel {
  final String id;
  final String routerId;
  final String type;
  final String title;
  final String description;
  final String status;
  final String? performedBy;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  MaintenanceModel({
    required this.id, required this.routerId, required this.type,
    required this.title, required this.description, this.status = 'scheduled',
    this.performedBy, DateTime? createdAt, this.completedAt, this.notes,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MaintenanceModel.fromMap(String id, Map<String, dynamic> map) => MaintenanceModel(
    id: id, routerId: map['routerId'] ?? '', type: map['type'] ?? '',
    title: map['title'] ?? '', description: map['description'] ?? '',
    status: map['status'] ?? 'scheduled', performedBy: map['performedBy'],
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    completedAt: (map['completedAt'] as dynamic)?.toDate(),
    notes: map['notes'],
  );

  Map<String, dynamic> toMap() => {
    'routerId': routerId, 'type': type, 'title': title,
    'description': description, 'status': status, 'performedBy': performedBy,
    'createdAt': createdAt, 'completedAt': completedAt, 'notes': notes,
  };
}
