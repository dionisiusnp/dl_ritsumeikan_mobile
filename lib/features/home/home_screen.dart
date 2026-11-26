import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/recommendation.dart';
import '../../providers/recommendation_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.arrival});

  final DateTime arrival;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(recommendationProvider(arrival));
    final timeFmt = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('BikePark AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Change arrival time',
            onPressed: () => context.go('/onboarding'),
          ),
        ],
      ),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e, onRetry: () => ref.invalidate(recommendationProvider(arrival))),
        data: (data) => _ResultView(data: data, arrival: arrival, timeFmt: timeFmt),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.data,
    required this.arrival,
    required this.timeFmt,
  });

  final RecommendationResult data;
  final DateTime arrival;
  final DateFormat timeFmt;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // No-op — user should go back and re-submit to change time
      },
      child: CustomScrollView(
        slivers: [
          if (data.isStale || data.dataSource != 'model')
            SliverToBoxAdapter(child: _DataBanner(dataSource: data.dataSource, isStale: data.isStale)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Arrival at ${timeFmt.format(arrival)}',
                style: const TextStyle(fontSize: 13, color: Colors.black45),
              ),
            ),
          ),
          if (data.allFull || data.recommendedZoneId == null)
            const SliverToBoxAdapter(child: _AllFullBanner())
          else ...[
            SliverToBoxAdapter(child: _RecommendCard(data: data)),
          ],
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'All Zones',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: data.zones.length,
            itemBuilder: (ctx, i) => _ZoneCard(
              zone: data.zones[i],
              isRecommended: data.zones[i].id == data.recommendedZoneId,
              arrival: arrival,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _DataBanner extends StatelessWidget {
  const _DataBanner({required this.dataSource, required this.isStale});
  final String dataSource;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final isDemo = dataSource != 'model';
    return Container(
      color: isDemo ? const Color(0xFFFFF3E0) : const Color(0xFFFFF8E1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            isDemo ? Icons.info_outline_rounded : Icons.access_time_rounded,
            size: 18,
            color: const Color(0xFFF57C00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isDemo
                  ? '⚠️ Demo data — ML model not active'
                  : '⚠️ Stale data — predictions may be outdated',
              style: const TextStyle(fontSize: 13, color: Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllFullBanner extends StatelessWidget {
  const _AllFullBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE57373)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'All zones predicted full.\nConsider alternative transport or a different arrival time.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendCard extends StatelessWidget {
  const _RecommendCard({required this.data});
  final RecommendationResult data;

  @override
  Widget build(BuildContext context) {
    final rec = data.zones.where((z) => z.id == data.recommendedZoneId).firstOrNull;
    if (rec == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF66BB6A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.recommend_rounded, color: Color(0xFF388E3C), size: 20),
              const SizedBox(width: 6),
              const Text(
                'Recommended',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF388E3C)),
              ),
              if (rec.walkMeters != null) ...[
                const Spacer(),
                Text(
                  '${rec.walkMeters}m walk',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Zone ${rec.code} — ${rec.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          _OccupancyBar(ratio: rec.ratio, level: rec.level),
          const SizedBox(height: 6),
          Text(
            '${rec.predictedFree} of ${rec.capacity} spaces free',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({required this.zone, required this.isRecommended, required this.arrival});
  final ZonePrediction zone;
  final bool isRecommended;
  final DateTime arrival;

  @override
  Widget build(BuildContext context) {
    final color = riskColor(zone.level);
    final label = riskLabel(zone.level);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/zones/${zone.id}', extra: arrival),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    zone.code,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zone.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    _OccupancyBar(ratio: zone.ratio, level: zone.level),
                    const SizedBox(height: 4),
                    Text(
                      '${zone.predictedFree} / ${zone.capacity} free',
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                    ),
                  ),
                  if (isRecommended) ...[
                    const SizedBox(height: 4),
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFF388E3C)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OccupancyBar extends StatelessWidget {
  const _OccupancyBar({required this.ratio, required this.level});
  final double ratio;
  final String level;

  @override
  Widget build(BuildContext context) {
    final filled = (1 - ratio).clamp(0.0, 1.0);
    final color = riskColor(level);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: filled,
        minHeight: 6,
        backgroundColor: Colors.black12,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isNetwork = error is NetworkException;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 56,
              color: Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              isNetwork
                  ? 'No connection\nCheck your network and try again.'
                  : 'Failed to load predictions.\nThe server may be unavailable.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
