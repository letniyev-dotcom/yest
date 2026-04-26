import 'package:flutter/material.dart';

const List<Color> kAccentColors = [
  Color(0xFF5B8BFF),
  Color(0xFFFF6B6B),
  Color(0xFF50C878),
  Color(0xFFFFB347),
  Color(0xFFC678FF),
  Color(0xFFFF7A9A),
  Color(0xFF1DD3B0),
  Color(0xFFFF9F1C),
];

class LetoColors extends ThemeExtension<LetoColors> {
  final Color bg;
  final Color card;
  final Color card2;
  final Color text;
  final Color text2;
  final Color text3;
  final Color accent;

  const LetoColors({
    required this.bg,
    required this.card,
    required this.card2,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
  });

  Color get accentSoft => accent.withOpacity(0.13);

  @override
  LetoColors copyWith({
    Color? bg,
    Color? card,
    Color? card2,
    Color? text,
    Color? text2,
    Color? text3,
    Color? accent,
  }) =>
      LetoColors(
        bg: bg ?? this.bg,
        card: card ?? this.card,
        card2: card2 ?? this.card2,
        text: text ?? this.text,
        text2: text2 ?? this.text2,
        text3: text3 ?? this.text3,
        accent: accent ?? this.accent,
      );

  @override
  LetoColors lerp(LetoColors? other, double t) {
    if (other == null) return this;
    return LetoColors(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      card2: Color.lerp(card2, other.card2, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

class AppTheme {
  static ThemeData dark(Color accent) => _build(
        brightness: Brightness.dark,
        bg: const Color(0xFF000000),
        card: const Color(0xFF181818),
        card2: const Color(0xFF202020),
        text: Colors.white,
        text2: Colors.white.withOpacity(0.44),
        text3: Colors.white.withOpacity(0.16),
        navBg: const Color(0xE0161616),
        accent: accent,
      );

  static ThemeData light(Color accent) => _build(
        brightness: Brightness.light,
        bg: const Color(0xFFF1F1F3),
        card: const Color(0xFFFFFFFF),
        card2: const Color(0xFFF5F5F7),
        text: const Color(0xFF111111),
        text2: Colors.black.withOpacity(0.40),
        text3: Colors.black.withOpacity(0.14),
        navBg: Colors.white.withOpacity(0.88),
        accent: accent,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color card2,
    required Color text,
    required Color text2,
    required Color text3,
    required Color navBg,
    required Color accent,
  }) {
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: brightness,
        primary: accent,
        surface: card,
      ),
      fontFamily: 'Outfit',
      extensions: [
        LetoColors(
          bg: bg,
          card: card,
          card2: card2,
          text: text,
          text2: text2,
          text3: text3,
          accent: accent,
        ),
      ],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        filled: true,
        fillColor: bg,
      ),
    );
  }
}

extension LetoColorsX on BuildContext {
  LetoColors get lc => Theme.of(this).extension<LetoColors>()!;
  Color get accent => lc.accent;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
