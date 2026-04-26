import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../widgets/modals/modals.dart';
import '../theme/app_theme.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(children: [
                const SizedBox(height: 56),
                ScreenHeader(
                  title: 'Питание',
                  action: LetoIconButton(
                    icon: SolarIconsBold.addCircle,
                    onTap: () => showLetoModal(context, const AddFoodModal()),
                  ),
                ),
                LetoSegmented(
                  options: ['💧  Вода', '🍽  Еда'],
                  selected: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 6),
              ]),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: const [_WaterTab(), _FoodTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterTab extends StatelessWidget {
  const _WaterTab();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lc = context.lc;
    const waterColor = Color(0xFF5B8BFF);

    final waterMl = prov.totalWaterToday;
    final goal = prov.profile.waterGoalMl;
    final remaining = (goal - waterMl).clamp(0, goal);
    final progress = (waterMl / goal).clamp(0.0, 1.0);

    final today = DateTime.now();
    final todayEntries = prov.waterEntries.reversed
        .where((e) =>
            e.timestamp.year == today.year &&
            e.timestamp.month == today.month &&
            e.timestamp.day == today.day)
        .take(8)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        LetoCard(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(children: [
            RingChart(
              progress: progress,
              size: 174,
              strokeWidth: 13,
              trackColor: lc.card2,
              fillColor: waterColor,
              center: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(waterMl.toString(),
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: lc.text,
                        letterSpacing: -1)),
                Text('из $goal мл',
                    style: TextStyle(
                        fontSize: 11,
                        color: lc.text2,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: 'Осталось ',
                    style: TextStyle(
                        fontSize: 13,
                        color: lc.text2,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Outfit')),
                TextSpan(
                    text: '$remaining мл',
                    style: const TextStyle(
                        fontSize: 13,
                        color: waterColor,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Outfit')),
              ]),
            ),
          ]),
        ),
        LetoCard(
          padding: const EdgeInsets.all(16),
          radius: 20,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Быстрое добавление',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: lc.text)),
            const SizedBox(height: 12),
            Row(children: [
              for (int i = 0; i < [150, 200, 350, 500].length; i++) ...[
                Expanded(child: _QuickWaterBtn(ml: [150, 200, 350, 500][i])),
                if (i < 3) const SizedBox(width: 8),
              ],
            ]),
          ]),
        ),
        if (todayEntries.isNotEmpty) ...[
          SectionTitle('История'),
          ...todayEntries.map((e) => _WaterHistoryItem(
                ml: e.ml,
                timestamp: e.timestamp,
              )),
        ],
      ],
    );
  }
}

class _QuickWaterBtn extends StatelessWidget {
  final int ml;
  const _QuickWaterBtn({required this.ml});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return GestureDetector(
      onTap: () => context.read<AppProvider>().addWater(ml),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: lc.card2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text('+$ml',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: lc.text)),
      ),
    );
  }
}

class _WaterHistoryItem extends StatelessWidget {
  final int ml;
  final DateTime timestamp;
  const _WaterHistoryItem({required this.ml, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    final timeStr =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration:
          BoxDecoration(color: lc.card, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Вода',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: lc.text)),
              Text(timeStr,
                  style: TextStyle(
                      fontSize: 11, color: lc.text2, fontWeight: FontWeight.w500)),
            ])),
        Text('$ml мл',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5B8BFF))),
      ]),
    );
  }
}

class _FoodTab extends StatelessWidget {
  const _FoodTab();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lc = context.lc;

    final totalCal = prov.totalCaloriesToday;
    final goalCal = prov.profile.calorieGoal.toDouble();
    final protein = prov.totalProteinToday;
    final fat = prov.totalFatToday;
    final carbs = prov.totalCarbsToday;
    final macroTotal = protein + fat + carbs;

    final proteinR = macroTotal > 0 ? protein / macroTotal : 0.0;
    final fatR = macroTotal > 0 ? fat / macroTotal : 0.0;
    final carbsR = macroTotal > 0 ? carbs / macroTotal : 0.0;
    final calRatio = (totalCal / goalCal).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        LetoCard(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(children: [
            SizedBox(
              width: 174,
              height: 174,
              child: Stack(alignment: Alignment.center, children: [
                CustomPaint(
                  size: const Size(174, 174),
                  painter: _MacroRingsPainter(
                    proteinProgress: (proteinR * calRatio).clamp(0.0, 1.0),
                    fatProgress: (fatR * calRatio).clamp(0.0, 1.0),
                    carbsProgress: (carbsR * calRatio).clamp(0.0, 1.0),
                    trackColor: lc.card2,
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(totalCal.toInt().toString(),
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: lc.text,
                          letterSpacing: -1)),
                  Text('из ${goalCal.toInt()} ккал',
                      style: TextStyle(
                          fontSize: 11,
                          color: lc.text2,
                          fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _MacroLegend(
                  color: const Color(0xFFFF6B6B), label: 'Б ${protein.toInt()}г'),
              const SizedBox(width: 14),
              _MacroLegend(
                  color: const Color(0xFFFFB347), label: 'Ж ${fat.toInt()}г'),
              const SizedBox(width: 14),
              _MacroLegend(
                  color: const Color(0xFF50C878), label: 'У ${carbs.toInt()}г'),
            ]),
          ]),
        ),
        for (final type in MealType.values) _MealSection(type: type),
      ],
    );
  }
}

class _MacroLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _MacroLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
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
    ]);
  }
}

class _MacroRingsPainter extends CustomPainter {
  final double proteinProgress, fatProgress, carbsProgress;
  final Color trackColor;

  const _MacroRingsPainter({
    required this.proteinProgress,
    required this.fatProgress,
    required this.carbsProgress,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final rings = [
      (70.0, 13.0, const Color(0xFFFF6B6B), proteinProgress),
      (56.0, 11.0, const Color(0xFFFFB347), fatProgress),
      (42.0, 9.0, const Color(0xFF50C878), carbsProgress),
    ];

    for (final ring in rings) {
      final radius = ring.$1;
      final sw = ring.$2;
      final color = ring.$3 as Color;
      final progress = ring.$4 as double;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw,
      );
      if (progress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          2 * math.pi * progress,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = sw
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MacroRingsPainter old) => true;
}

class _MealSection extends StatelessWidget {
  final MealType type;
  const _MealSection({required this.type});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lc = context.lc;
    final meals = prov.mealsOfType(type);
    final totalCal = meals.fold(0.0, (s, m) => s + m.calories);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
        child: Row(children: [
          Expanded(
              child: Text(type.label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: lc.text))),
          Text('${totalCal.toInt()} ккал',
              style: TextStyle(
                  fontSize: 13, color: lc.text2, fontWeight: FontWeight.w600)),
        ]),
      ),
      if (meals.isEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
              color: lc.card, borderRadius: BorderRadius.circular(16)),
          child: Text('Нет записей',
              style: TextStyle(
                  fontSize: 13, color: lc.text2, fontWeight: FontWeight.w500)),
        )
      else
        ...meals.map((m) => _MealItem(meal: m)),
    ]);
  }
}

class _MealItem extends StatelessWidget {
  final Meal meal;
  const _MealItem({required this.meal});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return GestureDetector(
      onLongPress: () => context.read<AppProvider>().removeMeal(meal.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: lc.card, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text(meal.name,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: lc.text)),
            Text(
                'Б ${meal.protein.toInt()} · Ж ${meal.fat.toInt()} · У ${meal.carbs.toInt()}',
                style: TextStyle(
                    fontSize: 11,
                    color: lc.text2,
                    fontWeight: FontWeight.w500)),
          ])),
          Text('${meal.calories.toInt()} ккал',
              style: TextStyle(
                  fontSize: 14, color: lc.text2, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
