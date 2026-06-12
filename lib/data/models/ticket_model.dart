class TicketModel {
  final String id;
  final String complaintId;
  final String title;
  final String description;
  final String status;
  final String type;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<String> logEntries;

  TicketModel({
    required this.id, required this.complaintId, required this.title,
    required this.description, this.status = 'open', this.type = 'technical',
    this.assignedTo, DateTime? createdAt, this.resolvedAt,
    this.logEntries = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory TicketModel.fromMap(String id, Map<String, dynamic> map) => TicketModel(
    id: id, complaintId: map['complaintId'] ?? '', title: map['title'] ?? '',
    description: map['description'] ?? '', status: map['status'] ?? 'open',
    type: map['type'] ?? 'technical', assignedTo: map['assignedTo'],
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    resolvedAt: (map['resolvedAt'] as dynamic)?.toDate(),
    logEntries: List<String>.from(map['logEntries'] ?? []),
  );

  Map<String, dynamic> toMap() => {
    'complaintId': complaintId, 'title': title, 'description': description,
    'status': status, 'type': type, 'assignedTo': assignedTo,
    'createdAt': createdAt, 'resolvedAt': resolvedAt, 'logEntries': logEntries,
  };
}
