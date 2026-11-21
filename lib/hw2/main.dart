import 'package:flutter/material.dart';
import '../ui/screens/catalog_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Корневой виджет приложения
/// Настраивает глобальную тему, чтобы использовать её во всех экранах
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coffeeBrown = Color(0xFF6F4E37);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Каталог кофе',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coffeeBrown,
          primary: coffeeBrown, // Основной цвет бренда
          onPrimary: Colors.white, // Цвет текста на основном фоне
          surface: Colors.white, // Цвет карточек и форм
          onSurface: coffeeBrown, // Основной цвет текста
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F0EA),
        appBarTheme: const AppBarTheme(
          backgroundColor: coffeeBrown,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const CatalogScreen(),
    );
  }
}