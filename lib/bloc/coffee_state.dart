import '../domain/entities/coffee.dart';

/// Состояния экрана каталога
sealed class CoffeeState {}

/// Состояние: идет загрузка
class CoffeeLoadInProgress extends CoffeeState {}

/// Состояние: данные успешно загружены
class CoffeeLoadSuccess extends CoffeeState {
  final List<CoffeeItem> items;
  final Set<String> likedIds;
  final bool onlyFavorites;

  CoffeeLoadSuccess({
    required this.items,
    this.likedIds = const {},
    this.onlyFavorites = false,
  });

  // Геттер для отфильтрованного списка
  List<CoffeeItem> get visibleItems {
    if (!onlyFavorites) return items;
    return items.where((item) => likedIds.contains(item.id)).toList();
  }

  // Метод для создания копии с изменениями (важно для BLoC!)
  CoffeeLoadSuccess copyWith({
    List<CoffeeItem>? items,
    Set<String>? likedIds,
    bool? onlyFavorites,
  }) {
    return CoffeeLoadSuccess(
      items: items ?? this.items,
      likedIds: likedIds ?? this.likedIds,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
    );
  }
}

/// Состояние: произошла ошибка
class CoffeeLoadFailure extends CoffeeState {
  final String message;
  CoffeeLoadFailure(this.message);
}