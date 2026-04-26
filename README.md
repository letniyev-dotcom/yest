# Лето — Health & Habits App 🌿

Flutter-приложение для трекинга здоровья, привычек, питания и сна.

## Экраны

- **Главная** — кольцо калорий, вода/шаги/сон, расписание, привычки
- **Питание** — вода (кольцо + быстрые кнопки) и еда (КБЖУ + приёмы пищи)
- **План** — привычки + расписание задач
- **Трекеры** — вес (линейный график) + сон (бар-чарт)
- **Профиль** — настройки, тема (тёмная/светлая), акцентный цвет

## Дизайн

- Тёмная тема: фон `#000000`, карточки `#181818`
- Светлая тема: фон `#F1F1F3`, карточки `#FFFFFF`
- 8 акцентных цветов на выбор
- Иконки: Solar Icons (solar_icons package)
- Никаких ripple-эффектов, никаких бордеров у контейнеров

## Установка и запуск

### Требования

- Flutter SDK 3.27.x+
- Dart 3.2.x+
- Android Studio / VS Code

### 1. Шрифты (Outfit)

Скачай и положи в папку `fonts/`:
```
https://fonts.google.com/specimen/Outfit
```

Нужные файлы:
- `Outfit-Regular.ttf`
- `Outfit-Medium.ttf`
- `Outfit-SemiBold.ttf`
- `Outfit-Bold.ttf`
- `Outfit-ExtraBold.ttf`
- `Outfit-Black.ttf`

### 2. Установка зависимостей

```bash
flutter pub get
```

### 3. Запуск

```bash
flutter run
```

## Сборка через GitHub Actions

Просто запушь код в `main` ветку — GitHub Actions автоматически:

1. Соберёт **Debug APK** → скачать в Artifacts
2. Соберёт **Release APK** → скачать в Artifacts  
3. Соберёт **Release AAB** (для Google Play) → скачать в Artifacts
4. Соберёт **iOS IPA** (unsigned, только на macOS runner)

### Как настроить репозиторий

```bash
git init
git add .
git commit -m "Initial commit — Leto app"
git remote add origin https://github.com/YOUR_USER/leto.git
git push -u origin main
```

После пуша перейди в Actions на GitHub — сборка запустится автоматически.

## Структура проекта

```
lib/
├── main.dart                  # Точка входа, AppShell + навбар
├── theme/
│   └── app_theme.dart         # Цвета, темы, расширения
├── models/
│   └── models.dart            # Habit, Task, Meal, Water, Weight, Sleep
├── providers/
│   └── app_provider.dart      # Состояние + бизнес-логика
├── screens/
│   ├── home_screen.dart
│   ├── nutrition_screen.dart
│   ├── plan_screen.dart
│   ├── trackers_screen.dart
│   └── profile_screen.dart
└── widgets/
    ├── widgets.dart           # LetoCard, RingChart, HabitChip, TaskCard...
    ├── floating_navbar.dart   # Плавающий навбар-островок
    └── modals/
        └── modals.dart        # Все bottom sheet модалки
```

## Зависимости

| Пакет | Версия | Назначение |
|-------|--------|------------|
| `solar_icons` | ^0.0.2 | Solar иконки |
| `provider` | ^6.1.2 | State management |
| `shared_preferences` | ^2.3.2 | Сохранение настроек |
| `google_fonts` | ^6.2.1 | Шрифты |
| `fl_chart` | ^0.69.0 | Графики |
| `intl` | ^0.19.0 | Локализация дат |
| `uuid` | ^4.5.1 | ID сущностей |
