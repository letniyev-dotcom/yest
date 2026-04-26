import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────
// LetoCard
// ─────────────────────────────────────────────────────────
class LetoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color? color;

  const LetoCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? context.lc.card,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────
// RingChart — circular progress with rounded caps
// ─────────────────────────────────────────────────────────
class RingChart extends StatefulWidget {
  final double progress; // 0.0–1.0
  final double size;
  final double strokeWidth;
  final Color trackColor;
  final Color fillColor;
  final Widget? center;

  const RingChart({
    super.key,
    required this.progress,
    this.size = 196,
    this.strokeWidth = 14,
    Color? trackColor,
    required this.fillColor,
    this.center,
  }) : trackColor = trackColor ?? const Color(0xFF202020);

  @override
  State<RingChart> createState() => _RingChartState();
}

class _RingChartState extends State<RingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0, end: widget.progress.clamp(0, 1))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant RingChart old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _anim = Tween<double>(begin: _anim.value, end: widget.progress.clamp(0, 1))
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _RingPainter(
                progress: _anim.value,
                strokeWidth: widget.strokeWidth,
                trackColor: widget.trackColor,
                fillColor: widget.fillColor,
              ),
            ),
          ),
          if (widget.center != null) widget.center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color fillColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.fillColor != fillColor;
}

// ─────────────────────────────────────────────────────────
// MultiRingChart — for macros (КБЖУ)
// ─────────────────────────────────────────────────────────
class MultiRingChart extends StatelessWidget {
  final double size;
  final List<_RingSegment> segments;
  final Widget? center;

  const MultiRingChart({
    super.key,
    required this.size,
    required this.segments,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _MultiRingPainter(segments: segments),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _RingSegment {
  final double progress;
  final Color color;
  final double radius;
  final double strokeWidth;

  const _RingSegment({
    required this.progress,
    required this.color,
    required this.radius,
    this.strokeWidth = 12,
  });
}

class _MultiRingPainter extends CustomPainter {
  final List<_RingSegment> segments;

  _MultiRingPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final seg in segments) {
      final trackPaint = Paint()
        ..color = seg.color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = seg.strokeWidth
        ..strokeCap = StrokeCap.round;

      final fillPaint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = seg.strokeWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: seg.radius);
      canvas.drawCircle(center, seg.radius, trackPaint);
      if (seg.progress > 0) {
        canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * seg.progress, false, fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_MultiRingPainter old) => true;
}

// ─────────────────────────────────────────────────────────
// StatCard — for Home screen water/steps/sleep row
// ─────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String suffix;
  final double progress;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.suffix = '',
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: lc.card,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: lc.text2,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: iconColor,
                        fontFamily: 'Outfit'),
                  ),
                  if (suffix.isNotEmpty)
                    TextSpan(
                      text: suffix,
                      style: TextStyle(
                          fontSize: 11,
                          color: lc.text2,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Outfit'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                backgroundColor: lc.card2,
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HabitChip
// ─────────────────────────────────────────────────────────
class HabitChip extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitChip({super.key, required this.habit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    final isComplete = habit.completedToday;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(62, 62),
                  painter: _HabitRingPainter(
                    progress: habit.progress,
                    trackColor: lc.text3,
                    fillColor: habit.color,
                  ),
                ),
                Icon(
                  _habitIcon(habit.icon),
                  size: 24,
                  color: isComplete ? habit.color : lc.text2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 62,
            child: Text(
              habit.name,
              style: TextStyle(
                  fontSize: 10,
                  color: lc.text2,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _habitIcon(String name) {
    switch (name) {
      case 'glass-water':
        return SolarIconsBold.glassWater;
      case 'book-2':
        return SolarIconsBold.book2;
      case 'meditation':
        return SolarIconsBold.meditation;
      case 'dumbbell':
        return SolarIconsBold.dumbbell;
      case 'moon-sleep':
        return SolarIconsBold.moonSleep;
      case 'running':
        return SolarIconsBold.runningRound;
      case 'yoga':
        return SolarIconsBold.stretching;
      case 'fire':
        return SolarIconsBold.fire;
      case 'heart':
        return SolarIconsBold.heart;
      default:
        return SolarIconsBold.star;
    }
  }
}

class _HabitRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;

  _HabitRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 28.0;
    const sw = 2.5;

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
          ..color = fillColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_HabitRingPainter old) =>
      old.progress != progress || old.fillColor != fillColor;
}

// ─────────────────────────────────────────────────────────
// TaskCard
// ─────────────────────────────────────────────────────────
class TaskCard extends StatelessWidget {
  final AppTask task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TaskCard({super.key, required this.task, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    final status = task.status;

    Color badgeBg;
    Color badgeText;
    Color cardBg = lc.card;
    String badgeLabel;

    switch (status) {
      case TaskStatus.live:
        badgeBg = const Color(0xFF46C882).withOpacity(0.13);
        badgeText = const Color(0xFF46C882);
        cardBg = const Color(0xFF46C882).withOpacity(0.07);
        badgeLabel = 'Сейчас';
      case TaskStatus.upcoming:
        badgeBg = lc.accent.withOpacity(0.13);
        badgeText = lc.accent;
        badgeLabel = _timeLabel(task.startTime);
      case TaskStatus.done:
        badgeBg = lc.card2;
        badgeText = lc.text2;
        badgeLabel = 'Готово';
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: status == TaskStatus.done ? 0.55 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      badgeLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: badgeText),
                    ),
                    if (status == TaskStatus.upcoming)
                      Text(
                        _timeLabel(task.endTime),
                        style: TextStyle(
                            fontSize: 10,
                            color: badgeText.withOpacity(0.65)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.name,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: lc.text)),
                    const SizedBox(height: 2),
                    Text(
                      status == TaskStatus.done
                          ? '${task.timeLabel} · выполнено'
                          : '${task.timeLabel} · ${task.statusLabel}',
                      style: TextStyle(
                          fontSize: 12,
                          color: lc.text2,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _taskIcon(task.icon),
                size: 22,
                color: status == TaskStatus.live
                    ? const Color(0xFF46C882)
                    : status == TaskStatus.done
                        ? const Color(0xFF46C882)
                        : lc.text2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  IconData _taskIcon(String name) {
    switch (name) {
      case 'dumbbell':
        return SolarIconsBold.dumbbell;
      case 'running':
        return SolarIconsBold.runningRound;
      case 'yoga':
        return SolarIconsBold.stretching;
      case 'meditation':
        return SolarIconsBold.meditation;
      case 'book-2':
        return SolarIconsBold.book2;
      default:
        return SolarIconsBold.star;
    }
  }
}

// ─────────────────────────────────────────────────────────
// Sheet handle
// ─────────────────────────────────────────────────────────
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: context.lc.text3,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LetoSegmented — pill tab switcher
// ─────────────────────────────────────────────────────────
class LetoSegmented extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const LetoSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: lc.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final isOn = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isOn ? lc.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  options[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isOn ? Colors.white : lc.text2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ScreenHeader
// ─────────────────────────────────────────────────────────
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: lc.text,
                        letterSpacing: -0.6,
                        height: 1)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: TextStyle(
                            fontSize: 13,
                            color: lc.text2,
                            fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// IconButton (Leto style — rounded square, no ripple)
// ─────────────────────────────────────────────────────────
class LetoIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const LetoIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: lc.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Icon(icon, size: size, color: lc.text),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LargeButton — accent filled button
// ─────────────────────────────────────────────────────────
class LargeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const LargeButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(top: 14),
        decoration: BoxDecoration(
          color: context.lc.accent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// FormField (Leto style)
// ─────────────────────────────────────────────────────────
class LetoField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const LetoField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              color: lc.text2,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: lc.bg,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: lc.text,
                fontFamily: 'Outfit'),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: lc.text3, fontFamily: 'Outfit'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// SectionTitle
// ─────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: lc.text,
                    letterSpacing: -0.3)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
