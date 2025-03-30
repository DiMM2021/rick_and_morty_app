import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import '../../data/models/character.dart';

class FavoriteCubit extends Cubit<List<Character>> {
  final Box<Character> _favoritesBox;

  FavoriteCubit(this._favoritesBox) : super(_sortCharacters(_favoritesBox.values.toList()));

  void toggleFavorite(Character character) {
    if (_favoritesBox.containsKey(character.id)) {
      _favoritesBox.delete(character.id);
    } else {
      _favoritesBox.put(character.id, character);
    }
    emit(_sortCharacters(_favoritesBox.values.toList()));
  }

  bool isFavorite(int id) {
    return _favoritesBox.containsKey(id);
  }

  static List<Character> _sortCharacters(List<Character> characters) {
    const statusOrder = {'Alive': 1, 'Dead': 2, 'unknown': 3};
    
    return characters..sort((a, b) {
      final aStatus = statusOrder[a.status] ?? 3;
      final bStatus = statusOrder[b.status] ?? 3;
      return aStatus.compareTo(bStatus);
    });
  }
}