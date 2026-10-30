import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'ui/screens/catalog_screen.dart';
import 'ui/screens/auth_screen.dart';
import 'bloc/coffee_bloc.dart';
import 'bloc/coffee_event.dart';

void main() async {
  // Обязательно для работы Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const AuthGate(),
    );
  }
}

/// Виджет-«страж», который слушает состояние входа (Firebase Auth)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Ждем, пока Firebase проверит сохраненный вход
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Если пользователь вошел — показываем каталог
        if (snapshot.hasData) {
          // Оборачиваем экран в BlocProvider, чтобы экран видел BLoC
          return BlocProvider(
            create: (_) => CoffeeBloc()..add(CoffeeLoadRequested()), // Создали и сразу загрузили
            child: const CatalogScreen(),
          );
        }
        
        // Если не вошел — показываем экран входа
        return const AuthScreen();
      },
    );
  }
}