import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/coffee.dart';
import '../widgets/coffee_card.dart';
import '../../bloc/coffee_bloc.dart'; 
import '../../bloc/coffee_event.dart'; 
import '../../bloc/coffee_state.dart'; 

/// Главный экран каталога
/// Является StatefulWidget, так как хранит состояние лайков и фильтра
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // --- Состояния экрана ---
  /// Хранилище ID лайкнутых элементов
  final Set<String> _likedIds = {};
  bool _showOnlyFavorites = false;

  // --- Состояния формы ---
  bool _showForm = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  /// --- POST ЗАПРОС (Добавление в Firestore) ---
  Future<void> _addCoffee() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название напитка!')),
      );
      return;
    }

    try {
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

      // Отправляем в Firestore напрямую (BLoC сам подхватит изменения)
      await FirebaseAuth.instance; // Заглушка, чтобы не ругался импорт (или можно удалить)
      await BlocProvider.of<CoffeeBloc>(context).state; // Просто обращаемся к BLoC
            
      // Отправляем в Firestore
      await FirebaseFirestore.instance.collection('coffees').add(newCoffee.toJson());

      // Вместо прямого вызова, мы попросим BLoC сделать это (но в ДЗ 6 этого нет).
      // Поэтому оставляем прямой вызов. Для этого нужен импорт.
      
      // P.S. Я вернул импорт cloud_firestore наверх для этого метода.

      setState(() {
        _titleController.clear();
        _subtitleController.clear();
        _showForm = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Добавлено: ${newCoffee.title}')),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void _toggleLike(String id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
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
              onPressed: () {
                _addCoffee();
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

    // --- Логика фильтрации ---
    // (Перенесена внутрь BlocBuilder, так как зависит от данных из состояния)

    return Scaffold(
      // --- Шапка ---
      appBar: AppBar(
        title: const Text('Каталог кофе', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Статистика (используем BlocBuilder для получения количества) ---
                BlocBuilder<CoffeeBloc, CoffeeState>(
                  builder: (context, state) {
                    int totalCount = 0;
                    if (state is CoffeeLoadSuccess) {
                      totalCount = state.items.length;
                    }
                    
                    return Row(
                      children: [
                        Text('В каталоге: $totalCount', style: const TextStyle(fontSize: 14, color: Colors.white)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('•', style: TextStyle(fontSize: 14, color: Colors.white)),
                        ),
                        Text('В избранном: ${_likedIds.length}', style: const TextStyle(fontSize: 14, color: Colors.white)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                // --- Кнопка-переключатель фильтра ---
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showOnlyFavorites ? Colors.grey.shade300 : theme.colorScheme.surface,
                      foregroundColor: themeColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                    ),
                    onPressed: () {
                      setState(() => _showOnlyFavorites = !_showOnlyFavorites);
                    },
                    icon: Icon(_showOnlyFavorites ? Icons.favorite : Icons.favorite_border, color: _showOnlyFavorites ? Colors.red : themeColor, size: 18),
                    label: const Text('Только избранные', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // --- Список карточек (используем BlocBuilder) ---
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
                        Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Отправляем событие заново в BLoC
                            context.read<CoffeeBloc>().add(CoffeeLoadRequested());
                          },
                          child: const Text('Обновить'),
                        ),
                      ],
                    ),
                  );
                }

                // 3. Состояние с данными
                final s = state as CoffeeLoadSuccess;
                final items = s.items;

                // Логика фильтрации
                final filteredItems = _showOnlyFavorites
                    ? items.where((item) => _likedIds.contains(item.id)).toList()
                    : items;

                if (filteredItems.isEmpty) {
                  return const Center(child: Text('Ничего не нашлось', style: TextStyle(fontSize: 18)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    // Передаем данные вниз (item, isLiked) и событие вверх (onLikeTap)
                    return CoffeeCard(
                      item: item,
                      isLiked: _likedIds.contains(item.id),
                      onLikeTap: () => _toggleLike(item.id),
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