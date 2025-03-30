import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/character.dart';
import '../../logic/cubit/favorite_cubit.dart';

class CharacterCard extends StatelessWidget {
  final Character character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: character.image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Status: ${character.status}'),
                  Text('Species: ${character.species}'),
                  Text('Gender: ${character.gender}'),
                  Text('Location: ${character.location}'),
                ],
              ),
            ),
            BlocBuilder<FavoriteCubit, List<Character>>(
              builder: (context, favorites) {
                bool isFavorite =
                    favorites.any((fav) => fav.id == character.id);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : null,
                  ),
                  onPressed: () {
                    context.read<FavoriteCubit>().toggleFavorite(character);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
