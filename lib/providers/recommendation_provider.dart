import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../core/api_client.dart';
import '../models/recommendation.dart';

final _fmt = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

final recommendationProvider = FutureProvider.family<RecommendationResult, DateTime>(
  (ref, arrival) async {
    final dio = ref.watch(dioProvider);
    final timeStr = _fmt.format(arrival);

    try {
      final resp = await dio.get(
        '/predict/recommend',
        queryParameters: {'target_time': timeStr},
      );
      return RecommendationResult.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException();
      }
      rethrow;
    }
  },
);

class NetworkException implements Exception {
  const NetworkException();
  @override
  String toString() => 'No connection';
}
