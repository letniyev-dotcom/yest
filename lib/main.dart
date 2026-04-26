import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/trackers_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/floating_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final provider = AppProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const LetoApp(),
    ),
  );
}

class LetoApp extends StatelessWidget {
  const LetoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return AnimatedTheme(
      data: prov.themeMode == ThemeMode.dark
          ? AppTheme.dark(prov.accentColor)
          : AppTheme.light(prov.accentColor),
      duration: const Duration(milliseconds: 300),
      child: Builder(
        builder: (ctx) => MaterialApp(
          title: 'Лето',
          debugShowCheckedModeBanner: false,
          theme: prov.themeMode == ThemeMode.dark
              ? AppTheme.dark(prov.accentColor)
              : AppTheme.light(prov.accentColor),
          themeMode: prov.themeMode,
          home: const AppShell(),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    NutritionScreen(),
    PlanScreen(),
    TrackersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lc = context.lc;
    // Sync status bar style with theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    return Scaffold(
      backgroundColor: lc.bg,
      body: Stack(
        children: [
          // Screens
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          // Floating Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}
