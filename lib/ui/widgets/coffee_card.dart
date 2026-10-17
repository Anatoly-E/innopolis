import 'package:flutter/material.dart';
import '../../domain/entities/coffee.dart';

/// Виджет карточки одного напитка
class CoffeeCard extends StatelessWidget {
  /// Модель данных напитка
  final CoffeeItem item;
  
  /// Флаг: находится ли этот напиток в избранном
  final bool isLiked;
  
  /// Колбэк функция, которая вызывается при нажатии на сердечко
  final VoidCallback onLikeTap;

  const CoffeeCard({
    super.key,
    required this.item,
    required this.isLiked,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем основной цвет из темы приложения
    final themeColor = Theme.of(context).colorScheme.primary;

    // --- Контейнер карточки ---
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
      // --- Карточка ---
      child: Row(
        children: [
          // --- Картинка и сердечко карточки ---
          SizedBox(
            width: 130,
            height: 110,
            child: Stack(
              children: [
                // Картинка
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
                      // Резервный вариант, если картинка не найдена
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Color(item.colorHex));
                      },
                    ),
                  ),
                ),
                // Сердечко
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    // Вызываем колбэк, переданный от экрана
                    onPressed: onLikeTap,
                  ),
                ),
              ],
            ),
          ),

          // --- Текстовый блок карточки ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Заголовок
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Краткое описание
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: themeColor.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Декоративная стрелочка (для ДЗ 4 ;) )
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right, color: themeColor.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }
}