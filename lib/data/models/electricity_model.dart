class ElectricityModel {
  final String id;
  final String routerId;
  final bool powerOn;
  final bool generatorOn;
  final double? voltage;
  final String? status;
  final DateTime timestamp;

  ElectricityModel({
    required this.id, required this.routerId, this.powerOn = true,
    this.generatorOn = false, this.voltage, this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ElectricityModel.fromMap(String id, Map<String, dynamic> map) => ElectricityModel(
    id: id, routerId: map['routerId'] ?? '',
    powerOn: map['powerOn'] ?? true, generatorOn: map['generatorOn'] ?? false,
    voltage: (map['voltage'] as num?)?.toDouble(), status: map['status'],
    timestamp: (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'routerId': routerId, 'powerOn': powerOn, 'generatorOn': generatorOn,
    'voltage': voltage, 'status': status, 'timestamp': timestamp,
  };
}
