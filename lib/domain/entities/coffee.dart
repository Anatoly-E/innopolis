/// Файл модели данных (Entity)
/// Описывает структуру одного элемента каталога (напитка)

/// Перечисление категорий кофе
enum CoffeeCategory { espresso, milk, specialty }

/// Модель напитка в каталоге
class CoffeeItem {
  /// Уникальный идентификатор для хранения лайков
  final int id;
  
  /// Название напитка
  final String title;
  
  /// Краткое описание
  final String subtitle;
  
  /// Категория напитка
  final CoffeeCategory category;
  
  /// Полное описание
  final String? description;
  
  /// Путь к локальной картинке
  final String imagePath;
  
  /// Резервный цвет, если картинка не загрузится
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
}