import '../domain/entities/coffee.dart';

/// Состояния экрана каталога
sealed class CoffeeState {}

/// Состояние: идет загрузка
class CoffeeLoadInProgress extends CoffeeState {}

/// Состояние: данные успешно загружены
class CoffeeLoadSuccess extends CoffeeState {
  final List<CoffeeItem> items;
  CoffeeLoadSuccess(this.items);
}

/// Состояние: произошла ошибка
class CoffeeLoadFailure extends CoffeeState {
  final String message;
  CoffeeLoadFailure(this.message);
}