import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widjets_1/bloc/theme_cubit.dart';

import '../../domain/entities/coffee.dart';
import '../widgets/coffee_card.dart';
import '../../bloc/coffee_bloc.dart';
import '../../bloc/coffee_event.dart';
import '../../bloc/coffee_state.dart';
import 'coffee_detail_screen.dart';


/// Главный экран каталога
/// Является StatefulWidget, так как хранит состояние лайков и фильтра
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // --- Состояния формы (локальные для UI) ---
  bool _showForm = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  /// --- ФОРМА ДОБАВЛЕНИЯ ---
  Widget _buildForm() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название (обязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Отправляем событие в BLoC
              onPressed: () {
                if (_titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите название напитка!')),
                  );
                  return;
                }

                // Создаем объект с дефолтными значениями
                final newCoffee = CoffeeItem(
                  id: '', // Firestore выдаст свой ID
                  title: _titleController.text.trim(),
                  subtitle: _subtitleController.text.trim().isEmpty
                      ? 'Вкусный напиток'
                      : _subtitleController.text.trim(),
                  category: CoffeeCategory.espresso,
                  imagePath: '',
                  colorHex: 0xFF8B4513,
                );

                // Отправляем событие в BLoC
                context.read<CoffeeBloc>().add(CoffeeAdded(newCoffee));

                setState(() {
                  _titleController.clear();
                  _subtitleController.clear();
                  _showForm = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Добавить кофе'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColor = theme.colorScheme.primary;

    return Scaffold(
      // --- Шапка ---
      appBar: AppBar(
        title: const Text(
          'Каталог кофе',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          // --- Кнопка переключения темы ---
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Тема',
            onSelected: (mode) {
              context.read<ThemeCubit>().setTheme(mode);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Text('Светлая'),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Тёмная'),
              ),
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Text('Системная'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            tooltip: 'Добавить напиток',
            onPressed: () {
              setState(() => _showForm = !_showForm);
            },
          ),
          // Кнопка Выйти
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            // --- Статистика и фильтр (через BlocBuilder) ---
            child: BlocBuilder<CoffeeBloc, CoffeeState>(
              builder: (context, state) {
                final totalCount = state is CoffeeLoadSuccess
                    ? state.items.length
                    : 0;
                final likedCount = state is CoffeeLoadSuccess
                    ? state.likedIds.length
                    : 0;
                final isFilterOn = state is CoffeeLoadSuccess
                    ? state.onlyFavorites
                    : false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Статистика ---
                    Row(
                      children: [
                        Text(
                          'В каталоге: $totalCount',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '•',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                        Text(
                          'В избранном: $likedCount',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // --- Кнопка-переключатель фильтра ---
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFilterOn
                              ? Colors.grey.shade300
                              : theme.colorScheme.surface,
                          foregroundColor: themeColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        onPressed: () {
                          // Отправляем событие переключения фильтра
                          context.read<CoffeeBloc>().add(CoffeeFilterToggled());
                        },
                        icon: Icon(
                          isFilterOn ? Icons.favorite : Icons.favorite_border,
                          color: isFilterOn ? Colors.red : themeColor,
                          size: 18,
                        ),
                        label: const Text(
                          'Только избранные',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      // --- Список карточек ---
      body: Column(
        children: [
          if (_showForm) _buildForm(),
          Expanded(
            child: BlocBuilder<CoffeeBloc, CoffeeState>(
              builder: (context, state) {
                // 1. Состояние загрузки
                if (state is CoffeeLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Состояние ошибки
                if (state is CoffeeLoadFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CoffeeBloc>().add(
                              CoffeeLoadRequested(),
                            );
                          },
                          child: const Text('Обновить'),
                        ),
                      ],
                    ),
                  );
                }

                // 3. Состояние с данными
                final s = state as CoffeeLoadSuccess;
                final items = s.visibleItems; // Берем отфильтрованный список

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      s.onlyFavorites
                          ? 'В избранном пока пусто'
                          : 'Каталог пуст',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    // Убрали GestureDetector, так как навигация теперь передается в onTap карточки
                    return CoffeeCard(
                      item: item,
                      isLiked: s.likedIds.contains(item.id),
                      // Передаем событие вверх в BLoC
                      onLikeTap: () => context.read<CoffeeBloc>().add(
                        CoffeeLikeToggled(item.id),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<CoffeeBloc>(), // Передаем BLoC
                              child: CoffeeDetailScreen(coffeeId: item.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}