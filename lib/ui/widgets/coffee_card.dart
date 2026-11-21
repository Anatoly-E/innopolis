import 'package:flutter/material.dart';
import '../../domain/entities/coffee.dart';

/// Виджет карточки одного напитка
class CoffeeCard extends StatelessWidget {
  final CoffeeItem item;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onTap;

  const CoffeeCard({
    super.key,
    required this.item,
    required this.isLiked,
    required this.onLikeTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                width: 130,
                height: 110,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: item.imagePath.isEmpty
                            ? Container(color: Color(item.colorHex))
                            : Image.asset(
                                item.imagePath,
                                fit: BoxFit.cover,
                                alignment: Alignment.centerLeft,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(color: Color(item.colorHex));
                                },
                              ),
                      ),
                    ),
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
                        onPressed: onLikeTap,
                      ),
                    ),
                  ],
                ),
              ),

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
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // НОВОЕ: Глобальный счетчик лайков
                      Row(
                        children: [
                          Icon(Icons.favorite, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${item.likesCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}