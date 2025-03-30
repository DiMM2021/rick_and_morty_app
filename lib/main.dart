import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rick_and_morty_app/app.dart';
import 'data/models/character.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CharacterAdapter());

  await Hive.openBox<Character>('charactersBox');
  final favoritesBox = await Hive.openBox<Character>('favorites');
  final settingsBox = await Hive.openBox('settings');

  runApp(MyApp(favoritesBox, settingsBox));
}

