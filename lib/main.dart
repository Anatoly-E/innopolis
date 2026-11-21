import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widjets_1/bloc/theme_cubit.dart';
import 'package:widjets_1/data/coffee_repository.dart';

import 'firebase_options.dart';
import 'ui/screens/catalog_screen.dart';
import 'ui/screens/auth_screen.dart';
import 'bloc/coffee_bloc.dart';
import 'bloc/coffee_event.dart';

void main() async {
  // Обязательно для работы Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Наш фирменный цвет
    const Color coffeeBrown = Color(0xFF6F4E37);

    return BlocProvider(
      create: (_) => ThemeCubit(), // Создаем Cubit для темы
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Каталог кофе',
            themeMode: themeMode, // Применяем выбранную тему
            // --- СВЕТЛАЯ ТЕМА ---
            theme: ThemeData(
              useMaterial3: true,
              // Настраиваем палитру
              colorScheme: ColorScheme.fromSeed(
                seedColor: coffeeBrown,
                primary: coffeeBrown,
                onPrimary: Colors.white,
              ),
              scaffoldBackgroundColor: const Color(0xFFF5F0EA), // Светлый фон
              // Задаем цвет текста по умолчанию для всего приложения
              textTheme: const TextTheme(
                titleLarge: TextStyle(color: coffeeBrown),
                bodyLarge: TextStyle(color: coffeeBrown),
                bodyMedium: TextStyle(color: coffeeBrown),
              ),

              // Настраиваем AppBar глобально
              appBarTheme: const AppBarTheme(
                backgroundColor: coffeeBrown,
                foregroundColor: Colors.white,
                centerTitle: false,
                elevation: 0,
              ),
            ),

            // --- ТЕМНАЯ ТЕМА ---
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: coffeeBrown,
                brightness: Brightness.dark, // Включаем темный режим
              ),
              // В темной теме фон делаем темно-серым
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF2C2C2C),
                foregroundColor: Colors.white,
                centerTitle: false,
                elevation: 0,
              ),
            ),

            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  /// Виджет-«страж», который слушает состояние входа (Firebase Auth)
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
          return BlocProvider(
            // Передаем репозиторий
            create: (_) =>
                CoffeeBloc(CoffeeRepository())..add(CoffeeLoadRequested()),
            child: const CatalogScreen(),
          );
        }
        // Если не вошел — показываем экран авторизации/регистрации
        return const AuthScreen();
      },
    );
  }
}
