import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

const _uuid = Uuid();

class AppProvider extends ChangeNotifier {
  late SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.dark;
  Color _accentColor = kAccentColors[0];
  UserProfile profile = UserProfile();

  // Data
  List<Habit> habits = [];
  List<AppTask> tasks = [];
  List<Meal> meals = [];
  List<WaterEntry> waterEntries = [];
  List<WeightEntry> weightEntries = [];
  List<SleepEntry> sleepEntries = [];

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  // ── Computed ───────────────────────────────────────────
  int get totalWaterToday {
    final today = DateTime.now();
    return waterEntries
        .where((e) => _isToday(e.timestamp, today))
        .fold(0, (sum, e) => sum + e.ml);
  }

  double get totalCaloriesToday {
    final today = DateTime.now();
    return meals
        .where((m) => _isToday(m.timestamp, today))
        .fold(0.0, (sum, m) => sum + m.calories);
  }

  double get totalProteinToday {
    final today = DateTime.now();
    return meals
        .where((m) => _isToday(m.timestamp, today))
        .fold(0.0, (sum, m) => sum + m.protein);
  }

  double get totalFatToday {
    final today = DateTime.now();
    return meals
        .where((m) => _isToday(m.timestamp, today))
        .fold(0.0, (sum, m) => sum + m.fat);
  }

  double get totalCarbsToday {
    final today = DateTime.now();
    return meals
        .where((m) => _isToday(m.timestamp, today))
        .fold(0.0, (sum, m) => sum + m.carbs);
  }

  List<Meal> mealsOfType(MealType type) {
    final today = DateTime.now();
    return meals
        .where((m) => m.type == type && _isToday(m.timestamp, today))
        .toList();
  }

  WeightEntry? get latestWeight =>
      weightEntries.isEmpty ? null : weightEntries.last;

  SleepEntry? get latestSleep =>
      sleepEntries.isEmpty ? null : sleepEntries.last;

  List<WeightEntry> get lastWeekWeight {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    return weightEntries
        .where((e) => e.timestamp.isAfter(start))
        .toList();
  }

  bool _isToday(DateTime dt, DateTime today) =>
      dt.year == today.year && dt.month == today.month && dt.day == today.day;

  // ── Init ───────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    _seedDemoData();
    notifyListeners();
  }

  void _loadSettings() {
    final themeIndex = _prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    final accentIndex = _prefs.getInt('accentIndex') ?? 0;
    _accentColor = kAccentColors[accentIndex.clamp(0, kAccentColors.length - 1)];

    final name = _prefs.getString('name');
    if (name != null) profile.name = name;
  }

  void _seedDemoData() {
    if (habits.isEmpty) {
      habits = [
        Habit(id: _uuid.v4(), name: 'Вода', icon: 'glass-water', color: const Color(0xFF5B8BFF), completedToday: true, progress: 1.0),
        Habit(id: _uuid.v4(), name: 'Чтение', icon: 'book-2', color: const Color(0xFFC678FF)),
        Habit(id: _uuid.v4(), name: 'Медитация', icon: 'meditation', color: const Color(0xFF50C878), completedToday: true, progress: 1.0),
        Habit(id: _uuid.v4(), name: 'Спорт', icon: 'dumbbell', color: const Color(0xFFFF6B6B)),
        Habit(id: _uuid.v4(), name: 'Ранний сон', icon: 'moon-sleep', color: const Color(0xFFFFB347)),
      ];
    }

    if (tasks.isEmpty) {
      final now = DateTime.now();
      tasks = [
        AppTask(
          id: _uuid.v4(),
          name: 'Утренняя зарядка',
          icon: 'dumbbell',
          startTime: const TimeOfDay(hour: 7, minute: 0),
          endTime: const TimeOfDay(hour: 7, minute: 20),
          completedToday: true,
        ),
        AppTask(
          id: _uuid.v4(),
          name: 'Тренировка в зале',
          icon: 'dumbbell',
          startTime: TimeOfDay(hour: now.hour, minute: now.minute > 30 ? 0 : now.minute),
          endTime: TimeOfDay(hour: now.hour + 1, minute: 30),
        ),
        AppTask(
          id: _uuid.v4(),
          name: 'Вечерняя пробежка',
          icon: 'running',
          startTime: const TimeOfDay(hour: 18, minute: 0),
          endTime: const TimeOfDay(hour: 19, minute: 0),
        ),
        AppTask(
          id: _uuid.v4(),
          name: 'Растяжка',
          icon: 'yoga',
          startTime: const TimeOfDay(hour: 20, minute: 0),
          endTime: const TimeOfDay(hour: 20, minute: 30),
        ),
      ];
    }

    if (meals.isEmpty) {
      final today = DateTime.now();
      meals = [
        Meal(
          id: _uuid.v4(),
          name: 'Овсянка с бананом',
          type: MealType.breakfast,
          calories: 340,
          protein: 12,
          fat: 8,
          carbs: 58,
          timestamp: today,
        ),
        Meal(
          id: _uuid.v4(),
          name: 'Куриная грудка с рисом',
          type: MealType.lunch,
          calories: 480,
          protein: 42,
          fat: 12,
          carbs: 45,
          timestamp: today,
        ),
        Meal(
          id: _uuid.v4(),
          name: 'Греческий йогурт',
          type: MealType.snack,
          calories: 130,
          protein: 18,
          fat: 3,
          carbs: 9,
          timestamp: today,
        ),
      ];
    }

    if (waterEntries.isEmpty) {
      final today = DateTime.now();
      waterEntries = [
        WaterEntry(id: _uuid.v4(), ml: 350, timestamp: today.subtract(const Duration(hours: 4))),
        WaterEntry(id: _uuid.v4(), ml: 200, timestamp: today.subtract(const Duration(hours: 3))),
        WaterEntry(id: _uuid.v4(), ml: 350, timestamp: today.subtract(const Duration(hours: 2))),
        WaterEntry(id: _uuid.v4(), ml: 500, timestamp: today.subtract(const Duration(hours: 1))),
      ];
    }

    if (weightEntries.isEmpty) {
      final now = DateTime.now();
      final weights = [75.0, 74.8, 75.2, 74.6, 74.4, 74.3, 74.2];
      for (int i = 0; i < weights.length; i++) {
        weightEntries.add(WeightEntry(
          id: _uuid.v4(),
          kg: weights[i],
          timestamp: now.subtract(Duration(days: 6 - i)),
        ));
      }
    }

    if (sleepEntries.isEmpty) {
      final now = DateTime.now();
      final sleeps = [
        [23, 30, 7, 0, 7.5],
        [0, 0, 8, 0, 8.0],
        [23, 0, 5, 30, 6.5],
        [22, 30, 7, 0, 8.5],
        [23, 45, 7, 30, 7.75],
        [0, 15, 8, 30, 8.25],
        [23, 30, 7, 0, 7.5],
      ];
      for (int i = 0; i < sleeps.length; i++) {
        sleepEntries.add(SleepEntry(
          id: _uuid.v4(),
          sleepHour: sleeps[i][0].toInt(),
          sleepMinute: sleeps[i][1].toInt(),
          wakeHour: sleeps[i][2].toInt(),
          wakeMinute: sleeps[i][3].toInt(),
          timestamp: now.subtract(Duration(days: 6 - i)),
        ));
      }
    }
  }

  // ── Theme ──────────────────────────────────────────────
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  void setAccentColor(int index) {
    _accentColor = kAccentColors[index];
    _prefs.setInt('accentIndex', index);
    notifyListeners();
  }

  // ── Profile ────────────────────────────────────────────
  void updateProfile({String? name, String? gender, double? currentWeight, double? goalWeight, int? waterGoal, int? calorieGoal}) {
    if (name != null) { profile.name = name; _prefs.setString('name', name); }
    if (gender != null) profile.gender = gender;
    if (currentWeight != null) profile.currentWeight = currentWeight;
    if (goalWeight != null) profile.goalWeight = goalWeight;
    if (waterGoal != null) profile.waterGoalMl = waterGoal;
    if (calorieGoal != null) profile.calorieGoal = calorieGoal;
    notifyListeners();
  }

  // ── Habits ─────────────────────────────────────────────
  void addHabit(Habit habit) {
    habits.add(habit);
    notifyListeners();
  }

  void toggleHabit(String id) {
    final h = habits.firstWhere((h) => h.id == id);
    h.completedToday = !h.completedToday;
    h.progress = h.completedToday ? 1.0 : 0.0;
    notifyListeners();
  }

  void removeHabit(String id) {
    habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  // ── Tasks ──────────────────────────────────────────────
  void addTask(AppTask task) {
    tasks.add(task);
    notifyListeners();
  }

  void toggleTask(String id) {
    final t = tasks.firstWhere((t) => t.id == id);
    t.completedToday = !t.completedToday;
    notifyListeners();
  }

  void removeTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<AppTask> get sortedTasks {
    final list = [...tasks];
    list.sort((a, b) {
      final aMin = a.startTime.hour * 60 + a.startTime.minute;
      final bMin = b.startTime.hour * 60 + b.startTime.minute;
      return aMin.compareTo(bMin);
    });
    return list;
  }

  // ── Meals ──────────────────────────────────────────────
  void addMeal(Meal meal) {
    meals.add(meal);
    notifyListeners();
  }

  void removeMeal(String id) {
    meals.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // ── Water ──────────────────────────────────────────────
  void addWater(int ml) {
    waterEntries.add(WaterEntry(
      id: _uuid.v4(),
      ml: ml,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void removeWaterEntry(String id) {
    waterEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ── Weight ─────────────────────────────────────────────
  void addWeight(double kg) {
    weightEntries.add(WeightEntry(
      id: _uuid.v4(),
      kg: kg,
      timestamp: DateTime.now(),
    ));
    profile.currentWeight = kg;
    notifyListeners();
  }

  // ── Sleep ──────────────────────────────────────────────
  void addSleep(SleepEntry entry) {
    sleepEntries.add(entry);
    notifyListeners();
  }
}
