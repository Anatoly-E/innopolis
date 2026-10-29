// ЛР 1 — шесть независимых виджетов.
//
// Как сдавать: скопируйте этот файл целиком себе в main.dart, допишите
// шесть функций ниже вместо TODO, запустите — все шесть элементов должны
// появиться на экране. Пришлите готовый файл на проверку.
//
// Основной виджет трогать не нужно. Редактируйте там, где написано TODO.

import 'package:flutter/material.dart';

void main() {
  runApp(const Lab1App());
}

class Lab1App extends StatelessWidget {
  const Lab1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ЛР 1')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task 1:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                task1(),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 4),
                Text(
                  'Task 2:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                task2(),

                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 4),
                Text(
                  'Task 3:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                task3(),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 4),
                Text(
                  'Task 4:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                task4(),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 4),
                Text(
                  'Task 5:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                task5(),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 4),
                Text(
                  'Task 6:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                task6(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 1. Заголовок — Text, крупный жирный текст чёрного цвета, обрезается в одну строку, если не помещается.
Widget task1() {
  return const Text(
    'Amet magna minim aute culpa dolor ullamco amet ad incididunt voluptate.',
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

// 2. Подпись — небольшой, нежирный курсивный текст белого цвета, обрезается в две строки.
// Также реализуйте подложку из тёмно-серого контейнера с закруглениями, чтобы текст было видно
Widget task2() {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      'Veniam deserunt minim voluptate ad duis occaecat consectetur irure nisi proident enim dolor et duis. Non magna magna nulla consectetur. Aute reprehenderit labore deserunt cillum et irure nostrud sint cupidatat labore dolore ad qui ullamco. Consequat eiusmod culpa laborum sint. Id ea fugiat irure veniam aliquip minim. Ipsum adipisicing enim proident cupidatat occaecat. Aute ipsum cupidatat minim cupidatat pariatur laborum voluptate eu quis reprehenderit adipisicing id.',
      style: TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: Colors.white,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

// 3. Иконка — любая Icon на ваш вкус,
// с применением цвета и размером.
Widget task3() {
  return const Icon(Icons.star, color: Colors.amber, size: 48);
}

// 4. Кнопка с иконкой избранного — большая иконка сердца красного цвета без фона.
// При нажатии пишет в консоль "Вы добавили в избранное"
Widget task4() {
  return IconButton(
    icon: const Icon(Icons.favorite, color: Colors.red, size: 48),
    onPressed: () {
      print('Вы добавили в избранное');
    },
  );
}

// 5. Кнопка «Подробнее» — кнопка с текстом и обводкой, при нажатии пишет в консоль "Узнать детали"
Widget task5() {
  return OutlinedButton(
    onPressed: () {
      print('Узнать детали');
    },
    child: const Text('Подробнее'),
  );
}

// 6. Изображение в стиле Polaroid—  выберите любое из каталога по ссылке
// https://picsum.photos/ (необходим vpn), либо используйте https://docs.flutter.dev/assets/images/dash/dash-fainting.gif
// Добавьте чёрную обводку, а внутри белую рамку в стиле фотографии Polaroid (https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAeKRHzUEOMCX836O6p8R5-XBkrSlf8C4go4C7f1q8ClnmlFaV9emSrUFL&s=10)
// Для реализации используйте Container
Widget task6() {
  return Container(
    padding: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 60), // White frame
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 2), // Black outline
      boxShadow: const [
        BoxShadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Image.network(
      'https://fastly.picsum.photos/id/56/2880/1920.jpg?hmac=BIplhYgNZ9bsjPXYhD0xx6M1yPgmg4HtthKkCeJp6Fk',
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    ),
  );
}
