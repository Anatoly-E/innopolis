import 'package:cloud_firestore/cloud_firestore.dart';

/// Файл модели данных (Entity)
/// Описывает структуру одного элемента каталога (напитка)

/// Перечисление категорий кофе
enum CoffeeCategory { espresso, milk, specialty }

/// Модель напитка в каталоге
class CoffeeItem {

  /// Уникальный идентификатор (в Firestore это ID документа)
  final String id;

  /// Название напитка
  final String title;

  /// Краткое описание
  final String subtitle;
  
  /// Категория напитка
  final CoffeeCategory category;

  /// Полное описание (может отсутствовать)
  final String? description;

  /// Путь к локальной картинке
  final String imagePath;

  /// Резервный цвет обложки, если картинка не загрузится
  final int colorHex;

  /// Конструктор
  const CoffeeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.description,
    required this.imagePath,
    required this.colorHex,
  });

  /// Превращает документ Firestore в объект Flutter
  factory CoffeeItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CoffeeItem(
      id: doc.id,
      title: data['title'] ?? 'Без названия',
      subtitle: data['subtitle'] ?? '',
      category: CoffeeCategory.values.byName(data['category'] ?? 'espresso'),
      description: data['description'],
      imagePath: data['image'] ?? '',
      colorHex: int.tryParse('FF${data['color']}', radix: 16) ?? 0xFF8B4513,
    );
  }

  /// Превращает объект в Map для отправки в Firestore (POST)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category.name,
      'description': description ?? '',
      'image': imagePath,
      'color': colorHex.toRadixString(16).substring(2).toUpperCase(),
    };
  }
}