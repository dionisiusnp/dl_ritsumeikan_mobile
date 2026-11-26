class Zone {
  const Zone({
    required this.id,
    required this.code,
    required this.name,
    required this.capacity,
    required this.campusId,
  });

  final int id;
  final String code;
  final String name;
  final int capacity;
  final int campusId;

  factory Zone.fromJson(Map<String, dynamic> j) => Zone(
    id: j['id'] as int,
    code: j['code'] as String,
    name: j['name'] as String,
    capacity: j['capacity'] as int,
    campusId: j['campus_id'] as int,
  );
}
