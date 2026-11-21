import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/coffee.dart';
import 'coffee_event.dart';
import 'coffee_state.dart';

class CoffeeBloc extends Bloc<CoffeeEvent, CoffeeState> {
  // Создаем коллекцию один раз
  final _db = FirebaseFirestore.instance.collection('coffees');

  CoffeeBloc() : super(CoffeeLoadInProgress()) {
    // Когда приходит событие LoadRequested, вызываем функцию _onLoadRequested
    on<CoffeeLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    CoffeeLoadRequested event,
    Emitter<CoffeeState> emit,
  ) async {
    // 1. Сообщаем экрану, что началась загрузка
    emit(CoffeeLoadInProgress());

    // 2. Подписываемся на поток Firestore и превращаем его в состояния
    await emit.forEach(
      _db.snapshots(),
      onData: (snapshot) {
        final items = snapshot.docs.map((doc) => CoffeeItem.fromFirestore(doc)).toList();
        return CoffeeLoadSuccess(items); // Отдаем данные
      },
      onError: (error, stackTrace) {
        return CoffeeLoadFailure('Не удалось загрузить каталог: $error'); // Отдаем ошибку
      },
    );
  }
}