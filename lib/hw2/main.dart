import 'package:flutter/material.dart';

void main() {
  runApp(const Hw2App());
}

class Hw2App extends StatelessWidget {
  const Hw2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Каталог кофе',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5F0EA),
      ),
      home: const CatalogScreen(),
    );
  }
}

/// Модель одной карточки.
class CatalogItem {
  final String title;
  final String subtitle;
  final String imagePath; // путь к локальной картинке
  final Color color; // резервный цвет, если картинка не загрузится

  const CatalogItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.color,
  });
}

/// Данные каталога — 10 напитков.
const List<CatalogItem> items = [
  CatalogItem(
    title: 'Американо',
    subtitle: 'Эспрессо, разбавленный горячей водой',
    imagePath: 'assets/hw2/images/americano.png',
    color: Color(0xFF4B3621),
  ),
  CatalogItem(
    title: 'Бреве',
    subtitle: 'Кофе на сливках вместо молока',
    imagePath: 'assets/hw2/images/breve.png',
    color: Color(0xFFE0B084),
  ),
  CatalogItem(
    title: 'Капучино',
    subtitle: 'Эспрессо с молочной пенкой',
    imagePath: 'assets/hw2/images/cappuccino.png',
    color: Color(0xFFA0764B),
  ),
  CatalogItem(
    title: 'Эспрессо кон панна',
    subtitle: 'Эспрессо со взбитыми сливками',
    imagePath: 'assets/hw2/images/espresso_con_panna.png',
    color: Color(0xFF6F4E37),
  ),
  CatalogItem(
    title: 'Флэт уайт',
    subtitle: 'Двойной эспрессо с тонким слоем молока',
    imagePath: 'assets/hw2/images/flat_white.png',
    color: Color(0xFFC4A484),
  ),
  CatalogItem(
    title: 'Латте',
    subtitle: 'Мягкий кофе с большим количеством молока',
    imagePath: 'assets/hw2/images/latte.png',
    color: Color(0xFFD7B899),
  ),
  CatalogItem(
    title: 'Латте макиато',
    subtitle: 'Молоко с каплей эспрессо',
    imagePath: 'assets/hw2/images/latte_macciato.png',
    color: Color(0xFFB58B6B),
  ),
  CatalogItem(
    title: 'Макиато',
    subtitle: 'Эспрессо с каплей молока',
    imagePath: 'assets/hw2/images/macciato.png',
    color: Color(0xFF5D4037),
  ),
  CatalogItem(
    title: 'Мокко',
    subtitle: 'Кофе с шоколадом и молоком',
    imagePath: 'assets/hw2/images/mocha.png',
    color: Color(0xFF3E2723),
  ),
  CatalogItem(
    title: 'Ристретто',
    subtitle: 'Концентрированный короткий эспрессо',
    imagePath: 'assets/hw2/images/ristretto.png',
    color: Color(0xFF2E1A0F),
  ),
];

/// Экран со списком карточек.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF6F4E37),
        foregroundColor: Colors.white,
        toolbarHeight: 72,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Кофе',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Выбери свой вкус',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return CatalogCard(item: items[index]);
        },
      ),
    );
  }
}

/// Карточка каталога.
class CatalogCard extends StatelessWidget {
  final CatalogItem item;

  const CatalogCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // === ОБЛОЖКА: Stack из трёх слоёв ===
          SizedBox(
            width: 130,
            height: 110,
            child: Stack(
              children: [
                // Слой 1: картинка (с обрезкой по левым скруглениям)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerLeft,
                      // Если картинки нет — показываем цветной фон
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: item.color);
                      },
                    ),
                  ),
                ),
                // Слой 2: кнопка-сердечко в правом верхнем углу
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: 'В избранное',
                    onPressed: () {
                      debugPrint('Вы добавили в избранное: ${item.title}');
                    },
                  ),
                ),
              ],
            ),
          ),

          // === ТЕКСТОВЫЙ БЛОК: Expanded ===
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Стрелочка справа
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
