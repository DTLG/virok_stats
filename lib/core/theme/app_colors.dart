import 'package:flutter/material.dart';

class AppColors {
  // Основний колір
  static const Color primary = Color.fromARGB(255, 180, 7, 18); // Червоний
  static const Color secondary = Color(0xFFF7B500); // Жовтий
  static const Color accent = Color(0xFF1B4B8F); // Темно-синій

  // Відтінки основного кольору
  static const Color primaryLight = Color(0xFFFF4D4D);
  static const Color primaryDark = Color(0xFFB30000);

  // Нейтральні кольори
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE30613);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Текстові кольори
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Colors.white;
  static const Color textHint = Color(0xFF9E9E9E);

  // Кольори для графіків
  static const List<Color> chartColors = [
    Color(0xFFE30613), // Червоний (основний)
    Color(0xFFF7B500), // Золотий жовтий
    Color(0xFF1B4B8F), // Глибокий синій
    Color(0xFF4CAF50), // Класичний зелений
    Color(0xFF9C27B0), // Насичений фіолетовий
    Color(0xFFFF9800), // Теплий оранжевий
    Color(0xFF00BCD4), // Бірюзовий (циан)
    Color(0xFF795548), // Теплий коричневий
    Color(0xFF607D8B), // Прохолодний сірий
    Color(0xFF8BC34A), // Світло-зелений (лайм)

    Color(0xFFE53935), // Інтенсивний червоний (темніший варіант)
    Color(0xFF7CB342), // Природний зелений (як молода трава)
    Color(0xFF5E35B1), // Насичений індиго
    Color(0xFFFF7043), // Кораловий (теплий помаранчевий)
    Color(0xFF00ACC1), // Яскрава морська хвиля
    Color(0xFFD81B60), // Яскраво-рожевий (маджента)
    Color(0xFF039BE5), // Чистий блакитний
    Color(0xFF43A047), // Темно-зелений (як хвоя)
    Color(0xFFFB8C00), // Яскраво-жовтогарячий
    Color(0xFF8E24AA), // Електричний фіолетовий
  ];

  static const Color primaryButtonColor = Color(0xFFE30613);
  static const Color primaryButtonTextColor = Colors.white;
}
