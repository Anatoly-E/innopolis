import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/coffee.dart';
import '../widgets/coffee_card.dart';

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

  /// Поток данных из Firestore (создаем один раз в initState)
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream;

  @override
  void initState() {
    super.initState();
    // Подписываемся на коллекцию 'coffees'
    _itemsStream = FirebaseFirestore.instance.collection('coffees').snapshots();
  }

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

      // Отправляем в Firestore
      await FirebaseFirestore.instance.collection('coffees').add(newCoffee.toJson());

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
              onPressed: _addCoffee,
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
                // --- Статистика ---
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _itemsStream,
                  builder: (context, snapshot) {
                    // Получаем актуальное количество из Firestore
                    final totalCount = snapshot.data?.docs.length ?? 0;
                    
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
      // --- Список карточек ---
      body: Column(
        children: [
          if (_showForm) _buildForm(),
          Expanded(
            // StreamBuilder автоматически обновляет список при изменении базы
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _itemsStream,
              builder: (context, snapshot) {
                // 1. Состояние ошибки
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ошибка: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Перезапуск потока
                            setState(() {
                              _itemsStream = FirebaseFirestore.instance.collection('coffees').snapshots();
                            });
                          },
                          child: const Text('Обновить'),
                        ),
                      ],
                    ),
                  );
                }

                // 2. Состояние загрузки
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 3. Данные получены
                final docs = snapshot.data?.docs ?? [];
                final items = docs.map((doc) => CoffeeItem.fromFirestore(doc)).toList();

                // Логика фильтрации (как в ДЗ 4)
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