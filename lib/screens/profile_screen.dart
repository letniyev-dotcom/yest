import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final lc = context.lc;
    final profile = prov.profile;
    final latestWeight = prov.latestWeight;
    final currentW = latestWeight?.kg ?? profile.currentWeight;
    final goalW = profile.goalWeight;
    final progress = (currentW - goalW).abs().toStringAsFixed(1);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          children: [
            const SizedBox(height: 56),
            const ScreenHeader(title: 'Профиль'),

            // ── AVATAR CARD ───────────────────────────────
            LetoCard(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: lc.accent.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Center(
                      child: Icon(SolarIconsBold.user, size: 36, color: lc.accent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(profile.name,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: lc.text,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('${profile.gender} · Цель: похудение',
                      style: TextStyle(
                          fontSize: 13, color: lc.text2, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(value: currentW.toStringAsFixed(1), label: 'Вес, кг', accent: lc.accent),
                      _Divider(lc: lc),
                      _StatItem(value: goalW.toStringAsFixed(0), label: 'Цель, кг', accent: lc.accent),
                      _Divider(lc: lc),
                      _StatItem(value: '−$progress', label: 'Прогресс', accent: lc.accent),
                    ],
                  ),
                ],
              ),
            ),

            // ── О СЕБЕ ────────────────────────────────────
            const SectionTitle('О себе'),
            LetoCard(
              child: Column(
                children: [
                  _SettingsItem(
                    icon: SolarIconsBold.user,
                    label: 'Имя',
                    value: profile.name,
                    onTap: () => _editField(context, 'Имя', profile.name, (v) {
                      context.read<AppProvider>().updateProfile(name: v);
                    }),
                  ),
                  _SettingsItem(
                    icon: SolarIconsBold.usersGroupRounded,
                    label: 'Пол',
                    value: profile.gender,
                    onTap: () => _pickGender(context),
                  ),
                  _SettingsItem(
                    icon: SolarIconsBold.rulerPen,
                    label: 'Текущий вес',
                    value: '${currentW.toStringAsFixed(1)} кг',
                    isLast: true,
                  ),
                ],
              ),
            ),

            // ── ЦЕЛИ ─────────────────────────────────────
            const SectionTitle('Цели'),
            LetoCard(
              child: Column(
                children: [
                  _SettingsItem(
                    icon: SolarIconsBold.cup,
                    iconColor: const Color(0xFF5B8BFF),
                    label: 'Вода в день',
                    value: '${profile.waterGoalMl} мл',
                    onTap: () => _editNumberField(context, 'Вода в день (мл)', profile.waterGoalMl.toString(), (v) {
                      final n = int.tryParse(v);
                      if (n != null) context.read<AppProvider>().updateProfile(waterGoal: n);
                    }),
                  ),
                  _SettingsItem(
                    icon: SolarIconsBold.target,
                    iconColor: const Color(0xFF50C878),
                    label: 'Целевой вес',
                    value: '${profile.goalWeight.toStringAsFixed(0)} кг',
                    onTap: () => _editNumberField(context, 'Целевой вес (кг)', profile.goalWeight.toStringAsFixed(0), (v) {
                      final n = double.tryParse(v);
                      if (n != null) context.read<AppProvider>().updateProfile(goalWeight: n);
                    }),
                  ),
                  _SettingsItem(
                    icon: SolarIconsBold.fire,
                    iconColor: const Color(0xFFFF6B6B),
                    label: 'Калории в день',
                    value: '${profile.calorieGoal} ккал',
                    isLast: true,
                    onTap: () => _editNumberField(context, 'Калории (ккал)', profile.calorieGoal.toString(), (v) {
                      final n = int.tryParse(v);
                      if (n != null) context.read<AppProvider>().updateProfile(calorieGoal: n);
                    }),
                  ),
                ],
              ),
            ),

            // ── ВНЕШНИЙ ВИД ───────────────────────────────
            const SectionTitle('Внешний вид'),
            LetoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme toggle
                  _SettingsRow(
                    icon: SolarIconsBold.moonStars,
                    label: 'Тема',
                    trailing: _ThemeToggle(
                      isDark: prov.themeMode == ThemeMode.dark,
                      onChanged: (isDark) => context.read<AppProvider>().setThemeMode(
                          isDark ? ThemeMode.dark : ThemeMode.light),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Accent color
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(SolarIconsBold.palette, size: 20, color: lc.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Акцентный цвет',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: lc.text)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                children: List.generate(kAccentColors.length, (i) {
                                  final isSelected =
                                      prov.accentColor == kAccentColors[i];
                                  return GestureDetector(
                                    onTap: () => context.read<AppProvider>().setAccentColor(i),
                                    behavior: HitTestBehavior.opaque,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: kAccentColors[i],
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(
                                                color: lc.text,
                                                width: 2.5,
                                                strokeAlign: BorderSide.strokeAlignOutside,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editField(BuildContext context, String title, String current, void Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    final lc = context.lc;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: lc.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: lc.text)),
            const SizedBox(height: 16),
            LetoField(label: title, placeholder: '', controller: ctrl),
            LargeButton(label: 'Сохранить', onTap: () {
              onSave(ctrl.text);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  void _editNumberField(BuildContext context, String title, String current, void Function(String) onSave) {
    final ctrl = TextEditingController(text: current);
    final lc = context.lc;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: lc.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: lc.text)),
            const SizedBox(height: 16),
            LetoField(label: title, placeholder: '', controller: ctrl, keyboardType: TextInputType.number),
            LargeButton(label: 'Сохранить', onTap: () {
              onSave(ctrl.text);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  void _pickGender(BuildContext context) {
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
            Text('Пол', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: lc.text)),
            const SizedBox(height: 16),
            for (final g in ['Мужской', 'Женский'])
              GestureDetector(
                onTap: () {
                  context.read<AppProvider>().updateProfile(gender: g);
                  Navigator.pop(context);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: lc.card2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(g,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: lc.text)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value, label;
  final Color accent;
  const _StatItem({required this.value, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: accent, letterSpacing: -0.5)),
      Text(label,
          style: TextStyle(fontSize: 11, color: context.lc.text2, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _Divider extends StatelessWidget {
  final LetoColors lc;
  const _Divider({required this.lc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: lc.text3,
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          top: 12,
          bottom: isLast ? 4 : 12,
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: iconColor ?? lc.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: lc.text))),
          Text(value, style: TextStyle(fontSize: 14, color: lc.text2, fontWeight: FontWeight.w500)),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(SolarIconsBold.altArrowRight, size: 16, color: lc.text2),
          ],
        ]),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: lc.accent),
        const SizedBox(width: 10),
        Expanded(child: Text(label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: lc.text))),
        trailing,
      ]),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ThemeToggle({required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: lc.card2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleOption(label: 'Тёмная', isOn: isDark, onTap: () => onChanged(true)),
          _ToggleOption(label: 'Светлая', isOn: !isDark, onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isOn;
  final VoidCallback onTap;

  const _ToggleOption({required this.label, required this.isOn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
        decoration: BoxDecoration(
          color: isOn ? lc.card : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isOn ? lc.text : lc.text2,
          ),
        ),
      ),
    );
  }
}
