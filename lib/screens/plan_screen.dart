import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import '../providers/app_provider.dart';
import '../widgets/widgets.dart';
import '../widgets/modals/modals.dart';
import '../theme/app_theme.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lc = context.lc;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          children: [
            const SizedBox(height: 56),
            const ScreenHeader(title: 'План'),

            // ── HABITS SECTION ────────────────────────────
            SectionTitle(
              'Привычки',
              trailing: LetoIconButton(
                icon: SolarIconsBold.addCircle,
                onTap: () => showLetoModal(context, const AddHabitModal()),
              ),
            ),

            LetoCard(
              padding: const EdgeInsets.all(16),
              child: prov.habits.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('Нет привычек',
                            style: TextStyle(
                                fontSize: 14, color: lc.text2, fontWeight: FontWeight.w500)),
                      ),
                    )
                  : SizedBox(
                      height: 92,
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
            ),

            const SizedBox(height: 4),

            // ── SCHEDULE SECTION ──────────────────────────
            SectionTitle(
              'Расписание',
              trailing: Row(
                children: [
                  Text('Сегодня',
                      style: TextStyle(
                          fontSize: 13,
                          color: lc.accent,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  LetoIconButton(
                    icon: SolarIconsBold.addCircle,
                    onTap: () => showLetoModal(context, const AddTaskModal()),
                  ),
                ],
              ),
            ),

            if (prov.tasks.isEmpty)
              LetoCard(
                child: Center(
                  child: Text('Нет задач',
                      style: TextStyle(
                          fontSize: 14, color: lc.text2, fontWeight: FontWeight.w500)),
                ),
              )
            else
              ...prov.sortedTasks.map(
                (t) => TaskCard(
                  task: t,
                  onTap: () => context.read<AppProvider>().toggleTask(t.id),
                  onLongPress: () => _confirmDelete(context, t.id, t.name),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    final lc = context.lc;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: lc.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            Text('Удалить задачу?',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900, color: lc.text)),
            const SizedBox(height: 8),
            Text(name,
                style: TextStyle(fontSize: 15, color: lc.text2, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: lc.card2,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text('Отмена',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: lc.text, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AppProvider>().removeTask(id);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text('Удалить',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
