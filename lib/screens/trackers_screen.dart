import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../widgets/modals/modals.dart';
import '../theme/app_theme.dart';

class TrackersScreen extends StatelessWidget {
  const TrackersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lc = context.lc;
    final latestWeight = prov.latestWeight;
    final latestSleep = prov.latestSleep;
    final weekWeight = prov.lastWeekWeight;

    // sleep for last 7 days
    final now = DateTime.now();
    final sleepData = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final entry = prov.sleepEntries.where((e) =>
          e.timestamp.year == day.year &&
          e.timestamp.month == day.month &&
          e.timestamp.day == day.day).lastOrNull;
      return entry?.durationHours ?? 0.0;
    });

    final dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    // today's index based on weekday (Mon=1..Sun=7)
    final todayIdx = now.weekday - 1; // 0=Mon

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          children: [
            const SizedBox(height: 56),
            const ScreenHeader(title: 'Трекеры'),

            // ── WEIGHT ────────────────────────────────────
            SectionTitle(
              'Вес',
              trailing: LetoIconButton(
                icon: SolarIconsBold.addCircle,
                onTap: () => showLetoModal(context, const AddWeightModal()),
              ),
            ),

            LetoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: latestWeight != null
                                      ? latestWeight.kg.toStringAsFixed(1)
                                      : '—',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: lc.text,
                                    letterSpacing: -1.5,
                                    height: 1,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                                TextSpan(
                                  text: ' кг',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: lc.text2,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 4),
                            if (weekWeight.length >= 2)
                              Builder(builder: (_) {
                                final diff = weekWeight.last.kg - weekWeight.first.kg;
                                final isDown = diff < 0;
                                return Text(
                                  '${isDown ? '↓' : '↑'} ${diff.abs().toStringAsFixed(1)} кг за неделю',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDown
                                        ? const Color(0xFF50C878)
                                        : const Color(0xFFFF6B6B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Цель',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: lc.text2,
                                  fontWeight: FontWeight.w600)),
                          Text(
                            '${prov.profile.goalWeight.toStringAsFixed(0)} кг',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: lc.accent,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (latestWeight != null)
                            Text(
                              '−${(latestWeight.kg - prov.profile.goalWeight).abs().toStringAsFixed(1)} кг осталось',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: lc.text2,
                                  fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Weight chart
                  SizedBox(
                    height: 110,
                    child: weekWeight.length < 2
                        ? Center(
                            child: Text('Недостаточно данных',
                                style: TextStyle(color: lc.text2, fontSize: 13)))
                        : _WeightChart(entries: weekWeight, accent: lc.accent, card2: lc.card2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final isToday = i == todayIdx;
                      return Text(
                        i == 6 ? 'Сег' : dayLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday ? lc.accent : lc.text2,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── SLEEP ─────────────────────────────────────
            SectionTitle(
              'Сон',
              trailing: LetoIconButton(
                icon: SolarIconsBold.addCircle,
                onTap: () => showLetoModal(context, const AddSleepModal()),
              ),
            ),

            LetoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: latestSleep != null
                                      ? '${latestSleep.durationHours.floor()}:${((latestSleep.durationHours % 1) * 60).toInt().toString().padLeft(2, '0')}'
                                      : '—',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: lc.text,
                                    letterSpacing: -1.5,
                                    height: 1,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                                TextSpan(
                                  text: ' ч',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: lc.text2,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              latestSleep?.timeLabel ?? '',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: lc.text2,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Норма',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: lc.text2,
                                  fontWeight: FontWeight.w600)),
                          Text('8 ч',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: lc.accent,
                                  letterSpacing: -0.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SleepBars(data: sleepData, labels: dayLabels, todayIdx: todayIdx, accent: lc.accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Weight Line Chart (custom painted)
// ─────────────────────────────────────────────────────────
class _WeightChart extends StatelessWidget {
  final List<WeightEntry> entries;
  final Color accent;
  final Color card2;

  const _WeightChart({
    required this.entries,
    required this.accent,
    required this.card2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WeightChartPainter(entries: entries, accent: accent, card2: card2),
      size: Size.infinite,
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final Color accent;
  final Color card2;

  _WeightChartPainter({
    required this.entries,
    required this.accent,
    required this.card2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final vals = entries.map((e) => e.kg).toList();
    final minV = vals.reduce(math.min);
    final maxV = vals.reduce(math.max);
    final range = (maxV - minV).clamp(0.5, double.infinity);

    List<Offset> pts = [];
    for (int i = 0; i < vals.length; i++) {
      final x = i / (vals.length - 1) * size.width;
      final y = size.height - ((vals[i] - minV) / range) * (size.height * 0.85) - 8;
      pts.add(Offset(x, y));
    }

    // Gradient fill
    final path = Path();
    path.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [accent.withOpacity(0.25), accent.withOpacity(0)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, Paint()..shader = gradient);

    // Line
    final linePath = Path();
    linePath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Last point dot
    final last = pts.last;
    canvas.drawCircle(last, 8, Paint()..color = accent.withOpacity(0.18));
    canvas.drawCircle(last, 4.5, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) => true;
}

// ─────────────────────────────────────────────────────────
// Sleep bar chart
// ─────────────────────────────────────────────────────────
class _SleepBars extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final int todayIdx;
  final Color accent;

  const _SleepBars({
    required this.data,
    required this.labels,
    required this.todayIdx,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    final maxH = data.isEmpty ? 8.0 : data.reduce(math.max).clamp(1.0, 12.0);

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final h = data[i];
          final ratio = h / maxH;
          final isToday = i == todayIdx;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < data.length - 1 ? 6 : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: accent.withOpacity(isToday ? 1.0 : 0.55 + 0.05 * i),
                                borderRadius:
                                    const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      color: isToday ? accent : lc.text2,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
