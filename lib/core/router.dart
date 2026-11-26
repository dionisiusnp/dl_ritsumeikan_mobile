import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/zone_detail/zone_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (_, _) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, state) {
        final arrival = state.extra as DateTime;
        return HomeScreen(arrival: arrival);
      },
    ),
    GoRoute(
      path: '/zones/:id',
      builder: (_, state) {
        final zoneId = int.parse(state.pathParameters['id']!);
        final arrival = state.extra as DateTime;
        return ZoneDetailScreen(zoneId: zoneId, arrival: arrival);
      },
    ),
  ],
);
