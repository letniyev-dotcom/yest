import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../widgets/widgets.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lc = context.lc;
    final now = DateTime.now();
    final locale = 'ru_RU';

    final totalCal = prov.totalCaloriesToday;
    final goalCal = prov.profile.calorieGoal.toDouble();
    final calProgress = totalCal / goalCal;

    final totalProtein = prov.totalProteinToday;
    final totalFat = prov.totalFatToday;
    final totalCarbs = prov.totalCarbsToday;

    final waterMl = prov.totalWaterToday;
    final waterGoal = prov.profile.waterGoalMl;
    final waterProgress = waterMl / waterGoal;

    final latestSleep = prov.latestSleep;
    final sleepH = latestSleep?.durationHours ?? 0;

    String weekday = '';
    try {
      weekday = DateFormat('EEEE, d MMMM', 'ru').format(now);
    } catch (_) {
      weekday = DateFormat('EEEE, d MMMM').format(now);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          children: [
            const SizedBox(height: 56),
            // Header
            ScreenHeader(
              title: 'Привет, ${prov.profile.name} 👋',
              subtitle: weekday,
              action: LetoIconButton(
                icon: SolarIconsBold.bell,
                onTap: () {},
              ),
            ),

            // CALORIE RING
            LetoCard(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                children: [
                  RingChart(
                    progress: calProgress.clamp(0, 1),
                    size: 196,
                    strokeWidth: 14,
                    trackColor: lc.card2,
                    fillColor: lc.accent,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalCal.toInt().toString(),
                          style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: lc.text,
                              letterSpacing: -1.5,
                              height: 1),
                        ),
                        const SizedBox(height: 2),
                        Text('из $goalCal ккал',
                            style: TextStyle(
                                fontSize: 12,
                                color: lc.text2,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MacroItem(color: const Color(0xFFFF6B6B), label: 'Б ${totalProtein.toInt()}г'),
                      const SizedBox(width: 14),
                      _MacroItem(color: const Color(0xFFFFB347), label: 'Ж ${totalFat.toInt()}г'),
                      const SizedBox(width: 14),
                      _MacroItem(color: const Color(0xFF50C878), label: 'У ${totalCarbs.toInt()}г'),
                    ],
                  ),
                ],
              ),
            ),

            // STATS ROW
            Row(
              children: [
                StatCard(
                  icon: SolarIconsBold.cup,
                  iconColor: const Color(0xFF5B8BFF),
                  label: 'Вода',
                  value: waterMl >= 1000
                      ? (waterMl / 1000).toStringAsFixed(1)
                      : waterMl.toString(),
                  suffix: waterMl >= 1000
                      ? ' / ${(waterGoal / 1000).toStringAsFixed(1)} л'
                      : ' / $waterGoal мл',
                  progress: waterProgress,
                ),
                const SizedBox(width: 10),
                StatCard(
                  icon: SolarIconsBold.walkingRound,
                  iconColor: const Color(0xFF50C878),
                  label: 'Шаги',
                  value: '6 420',
                  suffix: ' / 10к',
                  progress: 0.64,
                ),
                const SizedBox(width: 10),
                StatCard(
                  icon: SolarIconsBold.moonSleep,
                  iconColor: const Color(0xFFC678FF),
                  label: 'Сон',
                  value: sleepH > 0 ? sleepH.toStringAsFixed(1) : '—',
                  suffix: ' ч',
                  progress: sleepH / 8.0,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SCHEDULE
            SectionTitle('Расписание'),
            ...prov.sortedTasks.take(3).map(
                  (t) => TaskCard(task: t),
                ),

            // HABITS
            const SizedBox(height: 4),
            SectionTitle('Привычки'),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: prov.habits.length,
                separatorBuilder: (_, __) => const SizedBox(width: 18),
                itemBuilder: (_, i) => HabitChip(
                  habit: prov.habits[i],
                  onTap: () => context.read<AppProvider>().toggleHabit(prov.habits[i].id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final Color color;
  final String label;

  const _MacroItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: context.lc.text2,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
