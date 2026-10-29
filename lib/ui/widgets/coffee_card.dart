import 'package:flutter/material.dart';

import '../../domain/entities/coffee.dart';

/// Виджет карточки одного напитка
/// Является StatelessWidget, так как состояние лайка хранится на экране
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
    // Берем основые цвета из темы приложения
    final theme = Theme.of(context);
    final themeColor = theme.colorScheme.primary;
    final cardColor = theme.colorScheme.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // --- Карточка ---
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => debugPrint('Нажата карточка ${item.title}'),
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
                        // Проверка на пустой путь к картинке (для новых элементов)
                        child: item.imagePath.isEmpty
                            ? Container(color: Color(item.colorHex))
                            : Image.asset(
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

              // --- Текстовый блок ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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

              // Декоративная стрелочка
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right,
                  color: themeColor.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
