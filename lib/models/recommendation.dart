class RecommendationResult {
  const RecommendationResult({
    required this.zones,
    this.recommendedZoneId,
    this.recommendedReason,
    this.allFull = false,
    this.isStale = false,
    this.dataSource = 'model',
    this.message,
  });

  final List<ZonePrediction> zones;
  final int? recommendedZoneId;
  final String? recommendedReason;
  final bool allFull;
  final bool isStale;
  final String dataSource;
  final String? message;

  factory RecommendationResult.fromJson(Map<String, dynamic> j) {
    final zones = (j['zones'] as List<dynamic>)
        .map((z) => ZonePrediction.fromJson(z as Map<String, dynamic>))
        .toList();

    final rec = j['recommended_zone'] as Map<String, dynamic>?;

    return RecommendationResult(
      zones: zones,
      recommendedZoneId: rec?['id'] as int?,
      recommendedReason: rec?['reason'] as String?,
      allFull: rec == null && zones.every((z) => z.level == 'high'),
      isStale: j['stale'] as bool? ?? false,
      dataSource: j['data_source'] as String? ?? 'model',
      message: j['message'] as String?,
    );
  }
}

class ZonePrediction {
  const ZonePrediction({
    required this.id,
    required this.code,
    required this.name,
    required this.capacity,
    required this.predictedFree,
    required this.ratio,
    required this.level,
    this.walkMeters,
  });

  final int id;
  final String code;
  final String name;
  final int capacity;
  final int predictedFree;
  final double ratio;
  final String level;
  final int? walkMeters;

  factory ZonePrediction.fromJson(Map<String, dynamic> j) => ZonePrediction(
    id: j['id'] as int,
    code: j['code'] as String,
    name: j['name'] as String,
    capacity: j['capacity'] as int,
    predictedFree: j['predicted_free'] as int,
    ratio: (j['ratio'] as num).toDouble(),
    level: j['level'] as String,
    walkMeters: j['walk_meters'] as int?,
  );
}
