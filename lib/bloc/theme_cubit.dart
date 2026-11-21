import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit для управления темой приложения
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme(); // Загружаем сохраненную тему при старте
  }

  static const String _themeKey = 'app_theme_mode';

  /// Загрузить тему из памяти
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    
    if (savedTheme == 'light') emit(ThemeMode.light);
    else if (savedTheme == 'dark') emit(ThemeMode.dark);
    else emit(ThemeMode.system);
  }

  /// Переключить тему и сохранить в память
  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) await prefs.setString(_themeKey, 'light');
    else if (mode == ThemeMode.dark) await prefs.setString(_themeKey, 'dark');
    else await prefs.setString(_themeKey, 'system');
  }
}