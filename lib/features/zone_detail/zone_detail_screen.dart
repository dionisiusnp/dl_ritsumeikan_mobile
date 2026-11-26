import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/prediction.dart';
import '../../providers/zone_predictions_provider.dart';

class ZoneDetailScreen extends ConsumerWidget {
  const ZoneDetailScreen({super.key, required this.zoneId, required this.arrival});

  final int zoneId;
  final DateTime arrival;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictions = ref.watch(zonePredictionsProvider(zoneId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zone Forecast'),
      ),
      body: predictions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.black26),
              const SizedBox(height: 12),
              const Text('Could not load forecast', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(zonePredictionsProvider(zoneId)),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (list) => _ForecastView(predictions: list, arrival: arrival),
      ),
    );
  }
}

class _ForecastView extends StatelessWidget {
  const _ForecastView({required this.predictions, required this.arrival});

  final List<Prediction> predictions;
  final DateTime arrival;

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return const Center(
        child: Text('No predictions available yet.', style: TextStyle(color: Colors.black45)),
      );
    }

    final timeFmt = DateFormat('HH:mm');
    final grouped = _groupByDay(predictions);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _ArrivalHeader(arrival: arrival, predictions: predictions, timeFmt: timeFmt),
        ...grouped.entries.map((e) => _DaySection(
          date: e.key,
          predictions: e.value,
          arrival: arrival,
          timeFmt: timeFmt,
        )),
      ],
    );
  }

  Map<DateTime, List<Prediction>> _groupByDay(List<Prediction> preds) {
    final map = <DateTime, List<Prediction>>{};
    for (final p in preds) {
      final day = DateTime(p.targetTime.year, p.targetTime.month, p.targetTime.day);
      map.putIfAbsent(day, () => []).add(p);
    }
    return map;
  }
}

class _ArrivalHeader extends StatelessWidget {
  const _ArrivalHeader({required this.arrival, required this.predictions, required this.timeFmt});

  final DateTime arrival;
  final List<Prediction> predictions;
  final DateFormat timeFmt;

  Prediction? _nearest() {
    if (predictions.isEmpty) return null;
    return predictions.reduce(
      (a, b) => a.targetTime.difference(arrival).abs() < b.targetTime.difference(arrival).abs() ? a : b,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _nearest();
    if (p == null) return const SizedBox.shrink();

    final color = riskColor(p.level);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(80), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'At your arrival (${timeFmt.format(arrival)})',
            style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${p.predictedFree}',
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: color),
              ),
              const SizedBox(width: 8),
              const Text('spaces\nfree', style: TextStyle(fontSize: 14, height: 1.3, color: Colors.black54)),
              const Spacer(),
              _RiskBadge(level: p.level),
            ],
          ),
          if (p.dataSource != 'model')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '⚠️ Demo data (${p.dataSource})',
                style: const TextStyle(fontSize: 11, color: Color(0xFFF57C00)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.date,
    required this.predictions,
    required this.arrival,
    required this.timeFmt,
  });

  final DateTime date;
  final List<Prediction> predictions;
  final DateTime arrival;
  final DateFormat timeFmt;

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat('EEEE, MMM d');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            dayFmt.format(date),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black54),
          ),
        ),
        ...predictions.map((p) => _PredictionRow(
          prediction: p,
          isArrival: _isArrivalSlot(p),
          timeFmt: timeFmt,
        )),
      ],
    );
  }

  bool _isArrivalSlot(Prediction p) {
    return p.targetTime.difference(arrival).abs() < const Duration(minutes: 31);
  }
}

class _PredictionRow extends StatelessWidget {
  const _PredictionRow({
    required this.prediction,
    required this.isArrival,
    required this.timeFmt,
  });

  final Prediction prediction;
  final bool isArrival;
  final DateFormat timeFmt;

  @override
  Widget build(BuildContext context) {
    final color = riskColor(prediction.level);
    final p = prediction;

    return Container(
      decoration: isArrival
          ? BoxDecoration(color: color.withAlpha(13))
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              child: Text(
                timeFmt.format(p.targetTime),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isArrival ? FontWeight.w700 : FontWeight.normal,
                  color: isArrival ? color : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (1 - p.ratio).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 36,
              child: Text(
                '${p.predictedFree}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _RiskBadge(level: p.level, small: true),
          ],
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.level, this.small = false});
  final String level;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final color = riskColor(level);
    final label = riskLabel(level);
    final fontSize = small ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 7 : 10, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
