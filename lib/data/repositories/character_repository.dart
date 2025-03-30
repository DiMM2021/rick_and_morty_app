import 'package:dio/dio.dart';
import '../models/character.dart';

class CharacterRepository {
  final Dio _dio = Dio();

  Future<List<Character>> fetchCharacters({int page = 1}) async {
    try {
      final response = await _dio
          .get('https://rickandmortyapi.com/api/character?page=$page');

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results
            .map<Character>((json) => Character.fromJson(json))
            .toList();
      } else {
        throw Exception("Ошибка загрузки персонажей: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Ошибка сети: $e");
    }
  }
}
