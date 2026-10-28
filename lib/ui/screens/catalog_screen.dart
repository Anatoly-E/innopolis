import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/coffee.dart';
import '../widgets/coffee_card.dart';

const String baseUrl = 'https://6ad3a79e59dd78397bbbfcdf.mockapi.io';

/// Главный экран каталога
/// Является StatefulWidget, так как хранит состояние лайков и фильтра
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  // --- Состояния экрана ---
  /// Хранилище ID лайкнутых элементов
  final Set<String> _likedIds = {};
  bool _showOnlyFavorites = false;
  List<CoffeeItem> _items = [];
  bool _isLoading = true;
  String? _error;

  // --- Состояния формы ---
  bool _showForm = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCoffees();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  /// --- GET ЗАПРОС (Загрузка с сервера) ---
  Future<void> _fetchCoffees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/coffees'));

      if (response.statusCode != 200) {
        throw Exception('Ошибка сервера: статус ${response.statusCode}');
      }

      // utf8.decode нужен для корректного отображения кириллицы
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      final List<CoffeeItem> loadedItems = data.map((json) => CoffeeItem.fromJson(json)).toList();

      setState(() {
        _items = loadedItems;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить данные.\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// --- POST ЗАПРОС (Добавление на сервер) ---
  Future<void> _addCoffee() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название напитка!')),
      );
      return;
    }

    try {
      // Создаем объект с дефолтными значениями для сервера
      final newCoffee = CoffeeItem(
        id: '', // Сервер выдаст свой
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim().isEmpty 
            ? 'Вкусный напиток' 
            : _subtitleController.text.trim(),
        category: CoffeeCategory.espresso, 
        imagePath: '', 
        // Этот HEX-код уходит на сервер как данные, поэтому он жестко задан
        colorHex: 0xFF8B4513, 
      );

      final response = await http.post(
        Uri.parse('$baseUrl/coffees'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(newCoffee.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Ошибка создания: статус ${response.statusCode}');
      }

      final createdCoffee = CoffeeItem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

      setState(() {
        // Добавляем в конец списка (чтобы совпадало с поведением сервера)
        _items.add(createdCoffee); 
        _titleController.clear();
        _subtitleController.clear();
        _showForm = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Добавлено: ${createdCoffee.title}')),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void _toggleLike(String id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  /// --- ФОРМА ДОБАВЛЕНИЯ ---
  Widget _buildForm() {

    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface, 
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название (обязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addCoffee,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Добавить кофе'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColor = theme.colorScheme.primary;

    // --- Логика фильтрации ---
    // Если фильтр включен, оставляем только те элементы, чей ID есть в _likedIds.
    // Фильтрация происходит "на лету" в build, отдельный список не храним.
    final filteredItems = _showOnlyFavorites
        ? _items.where((item) => _likedIds.contains(item.id)).toList()
        : _items;

    return Scaffold(
      // --- Шапка ---
      appBar: AppBar(
        title: const Text('Каталог кофе', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            tooltip: 'Добавить напиток',
            onPressed: () {
              setState(() => _showForm = !_showForm);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Статистика ---
                Row(
                  children: [
                    Text('В каталоге: ${_items.length}', style: const TextStyle(fontSize: 14, color: Colors.white)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('•', style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                    Text('В избранном: ${_likedIds.length}', style: const TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                // --- Кнопка-переключатель фильтра ---
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showOnlyFavorites ? Colors.grey.shade300 : theme.colorScheme.surface,
                      foregroundColor: themeColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
                    ),
                    onPressed: () {
                      setState(() => _showOnlyFavorites = !_showOnlyFavorites);
                    },
                    icon: Icon(_showOnlyFavorites ? Icons.favorite : Icons.favorite_border, color: _showOnlyFavorites ? Colors.red : themeColor, size: 18),
                    label: const Text('Только избранные', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // --- Список карточек ---
      body: Column(
        children: [
          if (_showForm) _buildForm(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchCoffees,
                              child: const Text('Обновить'),
                            ),
                          ],
                        ),
                      )
                    : filteredItems.isEmpty
                        ? const Center(child: Text('Ничего не нашлось', style: TextStyle(fontSize: 18)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                // Передаем данные вниз (item, isLiked) и событие вверх (onLikeTap)
                              return CoffeeCard(
                                item: item,
                                isLiked: _likedIds.contains(item.id),
                                onLikeTap: () => _toggleLike(item.id),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}