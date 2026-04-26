import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../../theme/app_theme.dart';

const _uuid = Uuid();

// ─────────────────────────────────────────────────────────
// Add Food Modal
// ─────────────────────────────────────────────────────────
class AddFoodModal extends StatefulWidget {
  const AddFoodModal({super.key});

  @override
  State<AddFoodModal> createState() => _AddFoodModalState();
}

class _AddFoodModalState extends State<AddFoodModal> {
  final _name = TextEditingController();
  final _cal = TextEditingController();
  final _protein = TextEditingController();
  final _fat = TextEditingController();
  final _carbs = TextEditingController();
  int _mealType = 0;

  @override
  void dispose() {
    _name.dispose(); _cal.dispose(); _protein.dispose();
    _fat.dispose(); _carbs.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.isEmpty) return;
    final types = [MealType.breakfast, MealType.lunch, MealType.dinner, MealType.snack];
    context.read<AppProvider>().addMeal(Meal(
      id: _uuid.v4(),
      name: _name.text,
      type: types[_mealType],
      calories: double.tryParse(_cal.text) ?? 0,
      protein: double.tryParse(_protein.text) ?? 0,
      fat: double.tryParse(_fat.text) ?? 0,
      carbs: double.tryParse(_carbs.text) ?? 0,
      timestamp: DateTime.now(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return _Sheet(
      title: 'Добавить питание',
      children: [
        LetoField(label: 'Название', placeholder: 'Например, куриная грудка', controller: _name),
        const SizedBox(height: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ПРИЁМ ПИЩИ', style: TextStyle(fontSize: 11, color: lc.text2, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          LetoSegmented(
            options: ['Завтрак', 'Обед', 'Ужин', 'Перекус'],
            selected: _mealType,
            onChanged: (i) => setState(() => _mealType = i),
          ),
        ]),
        const SizedBox(height: 14),
        LetoField(label: 'Калории', placeholder: '0 ккал', controller: _cal, keyboardType: TextInputType.number),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: LetoField(label: 'Белки, г', placeholder: '0', controller: _protein, keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(child: LetoField(label: 'Жиры, г', placeholder: '0', controller: _fat, keyboardType: TextInputType.number)),
          const SizedBox(width: 8),
          Expanded(child: LetoField(label: 'Углеводы, г', placeholder: '0', controller: _carbs, keyboardType: TextInputType.number)),
        ]),
        LargeButton(label: 'Добавить', onTap: _save),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Add Habit Modal
// ─────────────────────────────────────────────────────────
class AddHabitModal extends StatefulWidget {
  const AddHabitModal({super.key});

  @override
  State<AddHabitModal> createState() => _AddHabitModalState();
}

class _AddHabitModalState extends State<AddHabitModal> {
  final _name = TextEditingController();
  int _iconIndex = 0;
  Set<int> _days = {};

  static const _icons = [
    ('glass-water', SolarIconsBold.glassWater),
    ('dumbbell', SolarIconsBold.dumbbell),
    ('book-2', SolarIconsBold.book2),
    ('meditation', SolarIconsBold.meditation),
    ('moon-sleep', SolarIconsBold.moonSleep),
    ('running', SolarIconsBold.runningRound),
    ('fire', SolarIconsBold.fire),
    ('heart', SolarIconsBold.heart),
  ];

  static const _dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.isEmpty) return;
    final prov = context.read<AppProvider>();
    prov.addHabit(Habit(
      id: _uuid.v4(),
      name: _name.text,
      icon: _icons[_iconIndex].$1,
      color: prov.accentColor,
      daysOfWeek: _days.toList(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return _Sheet(
      title: 'Новая привычка',
      children: [
        LetoField(label: 'Название', placeholder: 'Например, медитация', controller: _name),
        const SizedBox(height: 14),
        Text('ИКОНКА', style: TextStyle(fontSize: 11, color: lc.text2, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 10, children: List.generate(_icons.length, (i) {
          final isSelected = _iconIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _iconIndex = i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isSelected ? lc.accent.withOpacity(0.15) : lc.card2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Icon(_icons[i].$2, size: 22, color: isSelected ? lc.accent : lc.text2)),
            ),
          );
        })),
        const SizedBox(height: 14),
        Text('ДНИ (пусто = ежедневно)', style: TextStyle(fontSize: 11, color: lc.text2, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final isOn = _days.contains(i + 1);
            return GestureDetector(
              onTap: () => setState(() => isOn ? _days.remove(i + 1) : _days.add(i + 1)),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isOn ? lc.accent.withOpacity(0.13) : lc.card2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(_dayLabels[i],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: isOn ? lc.accent : lc.text2))),
              ),
            );
          }),
        ),
        LargeButton(label: 'Добавить', onTap: _save),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Add Task Modal
// ─────────────────────────────────────────────────────────
class AddTaskModal extends StatefulWidget {
  const AddTaskModal({super.key});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _name = TextEditingController();
  int _iconIndex = 0;
  Set<int> _days = {};
  int _startH = 9, _startM = 0;
  int _endH = 10, _endM = 0;

  static const _icons = [
    ('dumbbell', SolarIconsBold.dumbbell),
    ('running', SolarIconsBold.runningRound),
    ('yoga', SolarIconsBold.stretching),
    ('meditation', SolarIconsBold.meditation),
    ('book-2', SolarIconsBold.book2),
  ];

  static const _dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  void _save() {
    if (_name.text.isEmpty) return;
    context.read<AppProvider>().addTask(AppTask(
      id: _uuid.v4(),
      name: _name.text,
      icon: _icons[_iconIndex].$1,
      startTime: TimeOfDay(hour: _startH, minute: _startM),
      endTime: TimeOfDay(hour: _endH, minute: _endM),
      daysOfWeek: _days.toList(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return _Sheet(
      title: 'Новая задача',
      children: [
        LetoField(label: 'Название', placeholder: 'Например, тренировка', controller: _name),
        const SizedBox(height: 14),
        Text('ДНИ (пусто = ежедневно)', style: TextStyle(fontSize: 11, color: lc.text2, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final isOn = _days.contains(i + 1);
            return GestureDetector(
              onTap: () => setState(() => isOn ? _days.remove(i + 1) : _days.add(i + 1)),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isOn ? lc.accent.withOpacity(0.13) : lc.card2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(_dayLabels[i],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: isOn ? lc.accent : lc.text2))),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('НАЧАЛО', style: TextStyle(fontSize: 11, color: lc.text2, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            _TimePicker(hour: _startH, minute: _startM, onChanged: (h, m) => setState(() { _startH = h; _startM = m; })),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('КОНЕЦ', style: TextStyle(fontSize: 11, color: lc.text2, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            _TimePicker(hour: _endH, minute: _endM, onChanged: (h, m) => setState(() { _endH = h; _endM = m; })),
          ])),
        ]),
        LargeButton(label: 'Добавить', onTap: _save),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Add Weight Modal
// ─────────────────────────────────────────────────────────
class AddWeightModal extends StatefulWidget {
  const AddWeightModal({super.key});

  @override
  State<AddWeightModal> createState() => _AddWeightModalState();
}

class _AddWeightModalState extends State<AddWeightModal> {
  late double _weight;

  @override
  void initState() {
    super.initState();
    _weight = context.read<AppProvider>().profile.currentWeight;
  }

  void _adjust(double delta) {
    setState(() => _weight = (_weight + delta).clamp(30.0, 300.0));
    _weight = double.parse(_weight.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return _Sheet(
      title: 'Добавить вес',
      children: [
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _AdjustButton(icon: SolarIconsBold.minusCircle, onTap: () => _adjust(-0.1)),
          const SizedBox(width: 28),
          RichText(text: TextSpan(children: [
            TextSpan(text: _weight.toStringAsFixed(1),
                style: TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: lc.text, letterSpacing: -2, fontFamily: 'Outfit')),
            TextSpan(text: ' кг',
                style: TextStyle(fontSize: 18, color: lc.text2, fontWeight: FontWeight.w600, fontFamily: 'Outfit')),
          ])),
          const SizedBox(width: 28),
          _AdjustButton(icon: SolarIconsBold.addCircle, onTap: () => _adjust(0.1)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _QuickBtn('-1 кг', () => _adjust(-1.0)),
          const SizedBox(width: 8),
          _QuickBtn('-0.5', () => _adjust(-0.5)),
          const SizedBox(width: 8),
          _QuickBtn('+0.5', () => _adjust(0.5)),
          const SizedBox(width: 8),
          _QuickBtn('+1 кг', () => _adjust(1.0)),
        ]),
        LargeButton(label: 'Сохранить', onTap: () {
          context.read<AppProvider>().addWeight(_weight);
          Navigator.pop(context);
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Add Sleep Modal
// ─────────────────────────────────────────────────────────
class AddSleepModal extends StatefulWidget {
  const AddSleepModal({super.key});

  @override
  State<AddSleepModal> createState() => _AddSleepModalState();
}

class _AddSleepModalState extends State<AddSleepModal> {
  int _sleepH = 23, _sleepM = 30;
  int _wakeH = 7, _wakeM = 0;

  double get _duration {
    final sleepMin = _sleepH * 60 + _sleepM;
    var wakeMin = _wakeH * 60 + _wakeM;
    if (wakeMin <= sleepMin) wakeMin += 1440;
    return (wakeMin - sleepMin) / 60.0;
  }

  String get _durationLabel {
    final d = _duration;
    final h = d.floor();
    final m = ((d - h) * 60).round();
    return '${h}ч ${m}мин';
  }

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return _Sheet(
      title: 'Добавить сон',
      children: [
        Text('ЗАСЫПАНИЕ', style: TextStyle(fontSize: 11, color: lc.text2, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        _TimePicker(
          hour: _sleepH,
          minute: _sleepM,
          onChanged: (h, m) => setState(() { _sleepH = h; _sleepM = m; }),
        ),
        const SizedBox(height: 14),
        Text('ПРОБУЖДЕНИЕ', style: TextStyle(fontSize: 11, color: lc.text2, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        _TimePicker(
          hour: _wakeH,
          minute: _wakeM,
          onChanged: (h, m) => setState(() { _wakeH = h; _wakeM = m; }),
        ),
        const SizedBox(height: 16),
        Center(child: RichText(text: TextSpan(children: [
          TextSpan(text: 'Продолжительность: ',
              style: TextStyle(fontSize: 14, color: lc.text2, fontWeight: FontWeight.w600, fontFamily: 'Outfit')),
          TextSpan(text: _durationLabel,
              style: TextStyle(fontSize: 14, color: lc.accent, fontWeight: FontWeight.w800, fontFamily: 'Outfit')),
        ]))),
        LargeButton(label: 'Сохранить', onTap: () {
          context.read<AppProvider>().addSleep(SleepEntry(
            id: _uuid.v4(),
            sleepHour: _sleepH,
            sleepMinute: _sleepM,
            wakeHour: _wakeH,
            wakeMinute: _wakeM,
            timestamp: DateTime.now(),
          ));
          Navigator.pop(context);
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// _Sheet — bottom sheet wrapper
// ─────────────────────────────────────────────────────────
class _Sheet extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Sheet({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Container(
      decoration: BoxDecoration(
        color: lc.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 44),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            Text(title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: lc.text,
                    letterSpacing: -0.3)),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// _TimePicker — custom time selector (no system dialog)
// ─────────────────────────────────────────────────────────
class _TimePicker extends StatelessWidget {
  final int hour;
  final int minute;
  final void Function(int h, int m) onChanged;

  const _TimePicker({
    required this.hour,
    required this.minute,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: lc.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TimeColumn(
            value: hour,
            max: 24,
            onInc: () => onChanged((hour + 1) % 24, minute),
            onDec: () => onChanged((hour - 1 + 24) % 24, minute),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(':', style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w900,
                color: lc.text2, letterSpacing: -1)),
          ),
          _TimeColumn(
            value: minute,
            max: 60,
            onInc: () => onChanged(hour, (minute + 5) % 60),
            onDec: () => onChanged(hour, (minute - 5 + 60) % 60),
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final int value;
  final int max;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const _TimeColumn({
    required this.value,
    required this.max,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TimeArrow(icon: SolarIconsBold.altArrowUp, onTap: onInc, lc: lc),
        SizedBox(
          width: 64,
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: lc.text,
                letterSpacing: -1.5),
          ),
        ),
        _TimeArrow(icon: SolarIconsBold.altArrowDown, onTap: onDec, lc: lc),
      ],
    );
  }
}

class _TimeArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final LetoColors lc;

  const _TimeArrow({required this.icon, required this.onTap, required this.lc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 34,
        decoration: BoxDecoration(
          color: lc.card2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Icon(icon, size: 18, color: lc.text)),
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AdjustButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(color: lc.card2, shape: BoxShape.circle),
        child: Center(child: Icon(icon, size: 24, color: lc.text)),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickBtn(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: lc.card2,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: lc.text)),
        ),
      ),
    );
  }
}

// Helper to show modals
void showLetoModal(BuildContext context, Widget modal) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (_) => modal,
  );
}
