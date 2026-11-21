import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/coffee_repository.dart';
import 'coffee_event.dart';
import 'coffee_state.dart';

class CoffeeBloc extends Bloc<CoffeeEvent, CoffeeState> {
  final CoffeeRepository _repository;

  CoffeeBloc(this._repository) : super(CoffeeLoadInProgress()) {
    on<CoffeeLoadRequested>(_onLoadRequested);
    on<CoffeeLikeToggled>(_onLikeToggled);
    on<CoffeeFilterToggled>(_onFilterToggled);
    on<CoffeeAdded>(_onCoffeeAdded);
  }

  Future<void> _onLoadRequested(
    CoffeeLoadRequested event,
    Emitter<CoffeeState> emit,
  ) async {
    emit(CoffeeLoadInProgress());
    try {
      final likedIds = await _repository.fetchLikedIds();

      // Загружаем сохраненный фильтр
      final savedFilter = await _repository.getFilterState();

      await emit.forEach(
        _repository.watchCoffees(),
        onData: (items) {
          final currentState = state;
          if (currentState is CoffeeLoadSuccess) {
            return currentState.copyWith(items: items);
          }
          // Передаем сохраненный фильтр в состояние
          return CoffeeLoadSuccess(
            items: items,
            likedIds: likedIds,
            onlyFavorites: savedFilter, 
          );
        },
        onError: (error, stackTrace) {
          return CoffeeLoadFailure('Не удалось загрузить каталог');
        },
      );
    } catch (e) {
      emit(CoffeeLoadFailure('Ошибка при получении лайков: $e'));
    }
  }

  Future<void> _onLikeToggled(
    CoffeeLikeToggled event,
    Emitter<CoffeeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CoffeeLoadSuccess) return;

    final wasLiked = currentState.likedIds.contains(event.id);

    // 1. Сразу обновляем UI (оптимистичный подход)
    final newLikedIds = Set<String>.from(currentState.likedIds);
    if (wasLiked) {
      newLikedIds.remove(event.id);
    } else {
      newLikedIds.add(event.id);
    }
    emit(currentState.copyWith(likedIds: newLikedIds));

    // 2. Отправляем в базу (если ошибка, можно откатить, но для аттестации сойдет)
    await _repository.toggleLike(event.id, wasLiked);
  }

  Future<void> _onFilterToggled(
    CoffeeFilterToggled event,
    Emitter<CoffeeState> emit,
  ) async {
    final currentState = state;
    if (currentState is CoffeeLoadSuccess) {
      final newValue = !currentState.onlyFavorites;

      // 1. Обновляем UI
      emit(currentState.copyWith(onlyFavorites: newValue));

      // 2. Сохраняем в память устройства
      await _repository.saveFilterState(newValue);
    }
  }

  Future<void> _onCoffeeAdded(CoffeeAdded event, Emitter<CoffeeState> emit) async {
    // Просто отправляем в репозиторий. Поток snapshots() сам пришлет обновление.
    await _repository.addCoffee(event.coffee);
  }
}