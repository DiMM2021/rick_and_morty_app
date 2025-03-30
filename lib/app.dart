import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:rick_and_morty_app/data/models/character.dart';
import 'package:rick_and_morty_app/data/repositories/character_repository.dart';
import 'package:rick_and_morty_app/logic/cubit/character_cubit.dart';
import 'package:rick_and_morty_app/logic/cubit/favorite_cubit.dart';
import 'package:rick_and_morty_app/logic/cubit/theme_cubit.dart';
import 'package:rick_and_morty_app/presentation/screens/main_screen.dart';

class MyApp extends StatelessWidget {
  final Box<Character> favoritesBox;
  final Box settingsBox;

  const MyApp(this.favoritesBox, this.settingsBox, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CharacterCubit(CharacterRepository())),
        BlocProvider(create: (_) => FavoriteCubit(favoritesBox)),
        BlocProvider(create: (_) => ThemeCubit(settingsBox)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Rick and Morty App',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: state.themeMode,
            home: MainScreen(),
          );
        },
      ),
    );
  }
}
