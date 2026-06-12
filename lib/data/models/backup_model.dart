class BackupModel {
  final String id;
  final String routerId;
  final String fileName;
  final int fileSize;
  final String status;
  final String? storageUrl;
  final DateTime createdAt;
  final String? createdBy;

  BackupModel({
    required this.id, required this.routerId, required this.fileName,
    this.fileSize = 0, this.status = 'pending', this.storageUrl,
    DateTime? createdAt, this.createdBy,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BackupModel.fromMap(String id, Map<String, dynamic> map) => BackupModel(
    id: id, routerId: map['routerId'] ?? '', fileName: map['fileName'] ?? '',
    fileSize: map['fileSize'] ?? 0, status: map['status'] ?? 'pending',
    storageUrl: map['storageUrl'],
    createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    createdBy: map['createdBy'],
  );

  Map<String, dynamic> toMap() => {
    'routerId': routerId, 'fileName': fileName, 'fileSize': fileSize,
    'status': status, 'storageUrl': storageUrl, 'createdAt': createdAt,
    'createdBy': createdBy,
  };
}
