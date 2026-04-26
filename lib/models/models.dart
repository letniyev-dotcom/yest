import 'package:flutter/material.dart';

// ── Habit ─────────────────────────────────────────────────
class Habit {
  final String id;
  String name;
  String icon; // solar icon name
  Color color;
  List<int> daysOfWeek; // 1=Mon..7=Sun, empty=daily
  double progress; // 0.0 - 1.0
  bool completedToday;

  Habit({
    required this.id,
    required this.name,
    this.icon = 'solar:star-bold',
    Color? color,
    List<int>? daysOfWeek,
    this.progress = 0.0,
    this.completedToday = false,
  })  : color = color ?? const Color(0xFF5B8BFF),
        daysOfWeek = daysOfWeek ?? [];
}

// ── Task ──────────────────────────────────────────────────
class AppTask {
  final String id;
  String name;
  String icon;
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<int> daysOfWeek; // empty = daily
  bool completedToday;

  AppTask({
    required this.id,
    required this.name,
    this.icon = 'solar:star-bold',
    required this.startTime,
    required this.endTime,
    List<int>? daysOfWeek,
    this.completedToday = false,
  }) : daysOfWeek = daysOfWeek ?? [];

  String get timeLabel {
    String _t(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return '${_t(startTime)} – ${_t(endTime)}';
  }

  TaskStatus get status {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    final startMin = startTime.hour * 60 + startTime.minute;
    final endMin = endTime.hour * 60 + endTime.minute;

    if (completedToday) return TaskStatus.done;
    if (nowMin >= startMin && nowMin < endMin) return TaskStatus.live;
    if (nowMin < startMin) return TaskStatus.upcoming;
    return TaskStatus.done;
  }

  String get statusLabel {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    final startMin = startTime.hour * 60 + startTime.minute;
    final endMin = endTime.hour * 60 + endTime.minute;

    switch (status) {
      case TaskStatus.live:
        final remaining = endMin - nowMin;
        return 'До конца $remaining мин';
      case TaskStatus.upcoming:
        final diff = startMin - nowMin;
        if (diff < 60) return 'Через $diff мин';
        return 'Через ${diff ~/ 60} ч';
      case TaskStatus.done:
        return 'Выполнено';
    }
  }
}

enum TaskStatus { live, upcoming, done }

// ── Meal ──────────────────────────────────────────────────
class Meal {
  final String id;
  String name;
  MealType type;
  double calories;
  double protein;
  double fat;
  double carbs;
  DateTime timestamp;

  Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.timestamp,
  });
}

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Завтрак';
      case MealType.lunch:
        return 'Обед';
      case MealType.dinner:
        return 'Ужин';
      case MealType.snack:
        return 'Перекус';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return 'solar:sun-bold';
      case MealType.lunch:
        return 'solar:bowl-spoon-bold';
      case MealType.dinner:
        return 'solar:moon-bold';
      case MealType.snack:
        return 'solar:apple-bold';
    }
  }
}

// ── Water Entry ───────────────────────────────────────────
class WaterEntry {
  final String id;
  int ml;
  DateTime timestamp;

  WaterEntry({
    required this.id,
    required this.ml,
    required this.timestamp,
  });
}

// ── Weight Entry ──────────────────────────────────────────
class WeightEntry {
  final String id;
  double kg;
  DateTime timestamp;

  WeightEntry({
    required this.id,
    required this.kg,
    required this.timestamp,
  });
}

// ── Sleep Entry ───────────────────────────────────────────
class SleepEntry {
  final String id;
  int sleepHour;
  int sleepMinute;
  int wakeHour;
  int wakeMinute;
  DateTime timestamp;

  SleepEntry({
    required this.id,
    required this.sleepHour,
    required this.sleepMinute,
    required this.wakeHour,
    required this.wakeMinute,
    required this.timestamp,
  });

  double get durationHours {
    final sleepMin = sleepHour * 60 + sleepMinute;
    var wakeMin = wakeHour * 60 + wakeMinute;
    if (wakeMin <= sleepMin) wakeMin += 24 * 60;
    return (wakeMin - sleepMin) / 60.0;
  }

  String get durationLabel {
    final total = durationHours;
    final h = total.floor();
    final m = ((total - h) * 60).round();
    return '${h}ч ${m}мин';
  }

  String get timeLabel {
    return '${_pad(sleepHour)}:${_pad(sleepMinute)} — ${_pad(wakeHour)}:${_pad(wakeMinute)}';
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
}

// ── User Profile ──────────────────────────────────────────
class UserProfile {
  String name;
  String gender;
  double currentWeight;
  double goalWeight;
  int waterGoalMl;
  int calorieGoal;

  UserProfile({
    this.name = 'Алексей',
    this.gender = 'Мужской',
    this.currentWeight = 74.2,
    this.goalWeight = 70.0,
    this.waterGoalMl = 2500,
    this.calorieGoal = 2400,
  });
}
