import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/coffee_bloc.dart';
import '../../bloc/coffee_state.dart';
import '../../bloc/coffee_event.dart';

class CoffeeDetailScreen extends StatelessWidget {
  final String coffeeId;

  /// Экран деталей карточки кофе 
  const CoffeeDetailScreen({super.key, required this.coffeeId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Детали напитка')),
      body: BlocBuilder<CoffeeBloc, CoffeeState>(
        builder: (context, state) {
          if (state is! CoffeeLoadSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          final coffee = state.items.firstWhere((c) => c.id == coffeeId);
          final isLiked = state.likedIds.contains(coffeeId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Обложка (большая)
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Color(coffee.colorHex),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: coffee.imagePath.isNotEmpty 
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(coffee.imagePath, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.coffee, size: 100, color: Colors.white54),
                ),
                const SizedBox(height: 24),
                
                // Название и лайк (с глобальным счетчиком)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        coffee.title,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 20, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${coffee.likesCount}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(width: 12),
                        IconButton(
                          iconSize: 40,
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            context.read<CoffeeBloc>().add(CoffeeLikeToggled(coffee.id));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Категория
                Chip(label: Text(coffee.category.name)),
                const SizedBox(height: 16),
                
                // Подпись
                Text(coffee.subtitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                
                // Описание в красивом контейнере
                if (coffee.description != null && coffee.description!.isNotEmpty) ...[
                  Text('Описание', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), // Легкий фон в тон темы
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      coffee.description!,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5), // Межстрочный интервал для читаемости
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}