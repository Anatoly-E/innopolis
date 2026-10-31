import 'package:widjets_1/domain/entities/coffee.dart';

/// События, которые могут произойти в каталоге
sealed class CoffeeEvent {}

/// Событие: запросить загрузку каталога
class CoffeeLoadRequested extends CoffeeEvent {}

/// Событие: переключить лайк (передаем ID)
class CoffeeLikeToggled extends CoffeeEvent {
  final String id;
  CoffeeLikeToggled(this.id);
}

/// Событие: переключить фильтр "Только избранные"
class CoffeeFilterToggled extends CoffeeEvent {}

/// Событие: добавить новый кофе
class CoffeeAdded extends CoffeeEvent {
  final CoffeeItem coffee;
  CoffeeAdded(this.coffee);
}