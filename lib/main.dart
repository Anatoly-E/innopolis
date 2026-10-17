import 'package:flutter/material.dart';
import 'ui/screens/catalog_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Наш фирменный цвет
    const Color coffeeBrown = Color(0xFF6F4E37);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Каталог кофе',
      theme: ThemeData(
        useMaterial3: true,
        // Настраиваем палитру
        colorScheme: ColorScheme.fromSeed(
          seedColor: coffeeBrown,
          primary: coffeeBrown, // Основной цвет
          onPrimary: Colors.white, // Цвет текста на основном цвете
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F0EA), // Светлый фон
        
        // Задаем цвет текста по умолчанию для всего приложения
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: coffeeBrown), // Заголовки
          bodyLarge: TextStyle(color: coffeeBrown),  // Основной текст
          bodyMedium: TextStyle(color: coffeeBrown), // Мелкий текст
        ),
        
        // Настраиваем AppBar глобально
        appBarTheme: const AppBarTheme(
          backgroundColor: coffeeBrown,
          foregroundColor: Colors.white, // Весь текст и иконки в AppBar белые
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const CatalogScreen(),
    );
  }
}