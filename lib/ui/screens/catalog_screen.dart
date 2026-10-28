import 'package:flutter/material.dart';
import '../../domain/entities/coffee.dart';
import '../widgets/coffee_card.dart';

/// Список данных каталога
const List<CoffeeItem> _items = [
  CoffeeItem(id: 1, title: 'Американо', subtitle: 'Эспрессо, разбавленный горячей водой', category: CoffeeCategory.espresso, imagePath: 'assets/hw2/images/americano.png', colorHex: 0xFF4B3621),
  CoffeeItem(id: 2, title: 'Бреве', subtitle: 'Кофе на сливках вместо молока', category: CoffeeCategory.milk, imagePath: 'assets/hw2/images/breve.png', colorHex: 0xFFE0B084),
  CoffeeItem(id: 3, title: 'Капучино', subtitle: 'Эспрессо с молочной пенкой', category: CoffeeCategory.milk, imagePath: 'assets/hw2/images/cappuccino.png', colorHex: 0xFFA0764B),
  CoffeeItem(id: 4, title: 'Эспрессо кон панна', subtitle: 'Эспрессо со взбитыми сливками', category: CoffeeCategory.espresso, imagePath: 'assets/hw2/images/espresso_con_panna.png', colorHex: 0xFF6F4E37),
  CoffeeItem(id: 5, title: 'Флэт уайт', subtitle: 'Двойной эспрессо с тонким слоем молока', category: CoffeeCategory.milk, imagePath: 'assets/hw2/images/flat_white.png', colorHex: 0xFFC4A484),
  CoffeeItem(id: 6, title: 'Латте', subtitle: 'Мягкий кофе с большим количеством молока', category: CoffeeCategory.milk, imagePath: 'assets/hw2/images/latte.png', colorHex: 0xFFD7B899),
  CoffeeItem(id: 7, title: 'Латте макиато', subtitle: 'Молоко с каплей эспрессо', category: CoffeeCategory.milk, imagePath: 'assets/hw2/images/latte_macciato.png', colorHex: 0xFFB58B6B),
  CoffeeItem(id: 8, title: 'Макиато', subtitle: 'Эспрессо с каплей молока', category: CoffeeCategory.espresso, imagePath: 'assets/hw2/images/macciato.png', colorHex: 0xFF5D4037),
  CoffeeItem(id: 9, title: 'Мокко', subtitle: 'Кофе с шоколадом и молоком', category: CoffeeCategory.specialty, imagePath: 'assets/hw2/images/mocha.png', colorHex: 0xFF3E2723),
  CoffeeItem(id: 10, title: 'Ристретто', subtitle: 'Концентрированный короткий эспрессо', category: CoffeeCategory.espresso, imagePath: 'assets/hw2/images/ristretto.png', colorHex: 0xFF2E1A0F),
];

/// Главный экран каталога
/// Является StatefulWidget, так как хранит состояние лайков и фильтра
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  /// Хранилище ID лайкнутых элементов
  /// Используем Set (множество) для быстрого поиска (O(1)) и уникальности
  final Set<int> _likedIds = {};
  
  /// Флаг: включен ли фильтр "Только избранные"
  bool _showOnlyFavorites = false;

  /// Метод переключения лайка вызывается карточкой
  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;

    // --- Логика фильтрации ---
    // Если фильтр включен, оставляем только те элементы, чей ID есть в _likedIds.
    // Фильтрация происходит "на лету" в build, отдельный список не храним.
    final filteredItems = _showOnlyFavorites
        ? _items.where((item) => _likedIds.contains(item.id)).toList()
        : _items;

    return Scaffold(
      // --- Шапка ---
      appBar: AppBar(
        title: const Text(
          'Каталог кофе',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        // Кастомная нижняя часть AppBar: статистика и кнопка фильтра
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Статистика ---
                Row(
                  children: [
                    Text(
                      'В каталоге: ${_items.length}',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('•', style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                    Text(
                      'В избранном: ${_likedIds.length}',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
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
                      backgroundColor: _showOnlyFavorites 
                          ? Colors.grey.shade300 
                          : Colors.white,
                      foregroundColor: themeColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _showOnlyFavorites = !_showOnlyFavorites;
                      });
                    },
                    icon: Icon(
                      _showOnlyFavorites 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                      color: _showOnlyFavorites ? Colors.red : themeColor,
                      size: 18,
                    ),
                    label: const Text(
                      'Только избранные',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // --- Список карточек ---
      body: filteredItems.isEmpty
          ? const Center(
              child: Text('Ничего не нашлось', style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
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
            ),
    );
  }
}