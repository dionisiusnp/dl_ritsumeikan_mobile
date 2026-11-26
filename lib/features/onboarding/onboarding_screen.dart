import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DateTime _arrival = _defaultArrival();

  static DateTime _defaultArrival() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _arrival,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_arrival),
    );
    if (time == null || !mounted) return;
    setState(() {
      _arrival = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('EEE, MMM d');
    final timeFmt = DateFormat('HH:mm');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'BikePark AI',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ritsumeikan University',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'When do you arrive?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll predict which parking zone will have space.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 32),
              _ArrivalCard(
                date: dateFmt.format(_arrival),
                time: timeFmt.format(_arrival),
                onTap: _pickDate,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/home', extra: _arrival),
                child: const Text('Check Availability'),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Predictions update every 30 minutes',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrivalCard extends StatelessWidget {
  const _ArrivalCard({
    required this.date,
    required this.time,
    required this.onTap,
  });

  final String date;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.edit_rounded, color: Colors.black38, size: 20),
          ],
        ),
      ),
    );
  }
}
