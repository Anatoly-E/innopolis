/// События, которые могут произойти в каталоге
sealed class CoffeeEvent {}

/// Событие: запросить загрузку каталога
class CoffeeLoadRequested extends CoffeeEvent {}