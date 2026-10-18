/// Файл модели данных (Entity)
/// Описывает структуру одного элемента каталога (напитка)

/// Перечисление категорий кофе
enum CoffeeCategory { espresso, milk, specialty }

/// Модель напитка в каталоге
class CoffeeItem {

  /// Уникальный идентификатор (строковый, так как MockAPI использует Object ID)
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

  /// Превращает JSON с сервера в объект Flutter
  factory CoffeeItem.fromJson(Map<String, dynamic> json) {
    // Защита: если сервер не прислал id, используем title
    final String safeId = (json['id'] != null && json['id'].toString().isNotEmpty) 
        ? json['id'].toString() 
        : (json['title'] ?? 'unknown').toString();

    return CoffeeItem(
      id: safeId,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      category: CoffeeCategory.values.byName(json['category'] as String),
      description: json['description'] as String?,
      imagePath: json['image'] as String,
      colorHex: int.parse('FF${json['color']}', radix: 16),
    );
  }

  /// Превращает объект в Map для отправки на сервер (POST)
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