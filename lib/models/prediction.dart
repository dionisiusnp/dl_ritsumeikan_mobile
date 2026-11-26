class Prediction {
  const Prediction({
    required this.id,
    required this.zoneId,
    required this.targetTime,
    required this.predictedFree,
    required this.ratio,
    required this.level,
    required this.dataSource,
    this.modelVersion,
    this.isStale = false,
  });

  final int id;
  final int zoneId;
  final DateTime targetTime;
  final int predictedFree;
  final double ratio;
  final String level;
  final String dataSource;
  final String? modelVersion;
  final bool isStale;

  factory Prediction.fromJson(Map<String, dynamic> j) => Prediction(
    id: j['id'] as int,
    zoneId: j['zone_id'] as int,
    targetTime: DateTime.parse(j['target_time'] as String),
    predictedFree: j['predicted_free'] as int,
    ratio: (j['ratio'] as num).toDouble(),
    level: j['level'] as String,
    dataSource: j['data_source'] as String? ?? 'unknown',
    modelVersion: j['model_version'] as String?,
    isStale: j['is_stale'] as bool? ?? false,
  );
}
