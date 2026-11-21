import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/coffee.dart';

/// Репозиторий — единственное место в приложении, которое знает про Firebase.
class CoffeeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _coffees =>
      _db.collection('coffees');

  CollectionReference<Map<String, dynamic>>? get _favorites {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('favorites');
  }

  Stream<List<CoffeeItem>> watchCoffees() {
    return _coffees.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CoffeeItem.fromFirestore(doc)).toList();
    });
  }

  Future<void> addCoffee(CoffeeItem coffee) async {
    await _coffees.add(coffee.toJson());
  }

  Future<Set<String>> fetchLikedIds() async {
    final favs = _favorites;
    if (favs == null) return {}; 
    
    final snapshot = await favs.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Поставить или снять лайк и обновить глобальный счетчик
  Future<void> toggleLike(String coffeeId, bool isLiked) async {
    final favs = _favorites;
    if (favs == null) return;

    // Используем batch для атомарного обновления (все или ничего)
    final batch = _db.batch();
    final coffeeRef = _coffees.doc(coffeeId);

    if (isLiked) {
      // Снимаем лайк: удаляем из избранного и уменьшаем счетчик
      batch.delete(favs.doc(coffeeId));
      batch.update(coffeeRef, {'likesCount': FieldValue.increment(-1)});
    } else {
      // Ставим лайк: добавляем в избранное и увеличиваем счетчик
      batch.set(favs.doc(coffeeId), {'createdAt': FieldValue.serverTimestamp()});
      batch.update(coffeeRef, {'likesCount': FieldValue.increment(1)});
    }

    await batch.commit(); // Отправляем оба изменения разом
  }

  static const String _filterKey = 'only_favorites';

  Future<void> saveFilterState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_filterKey, value);
  }

  Future<bool> getFilterState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_filterKey) ?? false;
  }
}