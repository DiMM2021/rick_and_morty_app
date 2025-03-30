import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/data/models/character.dart';
import '../../logic/cubit/favorite_cubit.dart';
import '../widgets/character_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Избранное")),
      body: BlocBuilder<FavoriteCubit, List<Character>>(
        builder: (context, favorites) {
          if (favorites.isEmpty) {
            return Center(child: Text("Нет избранных персонажей"));
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return CharacterCard(character: favorites[index]);
            },
          );
        },
      ),
    );
  }
}
