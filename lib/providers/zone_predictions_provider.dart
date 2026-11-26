import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/prediction.dart';

final zonePredictionsProvider = FutureProvider.family<List<Prediction>, int>(
  (ref, zoneId) async {
    final dio = ref.watch(dioProvider);
    final resp = await dio.get('/zones/$zoneId/predictions');
    final data = resp.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => Prediction.fromJson(e as Map<String, dynamic>))
        .toList();
  },
);
