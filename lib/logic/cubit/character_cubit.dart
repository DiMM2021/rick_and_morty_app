import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_app/data/models/character.dart';
import 'package:meta/meta.dart';
import 'package:rick_and_morty_app/data/repositories/character_repository.dart';
import 'package:hive/hive.dart';

part 'character_state.dart';

class CharacterCubit extends Cubit<CharacterState> {
  final CharacterRepository repository;
  late final Box<Character> _charactersBox;

  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isOffline = false;
  static const int _pageSize = 20;

  CharacterCubit(this.repository) : super(CharacterInitial()) {
    _initCache();
  }

  void resetPagination() {
    _currentPage = 1;
    _hasMore = true;
    _isOffline = false;
    emit(CharacterLoading([]));
  }

  Future<void> _initCache() async {
    try {
      _charactersBox = await Hive.openBox<Character>('charactersBox');
      if (state is! CharacterLoaded ||
          (state as CharacterLoaded).characters.isEmpty) {
        _loadFromCache();
      }
    } catch (e) {
      print('Error opening Hive box: $e');
      emit(CharacterError('Failed to initialize cache'));
    }
  }

  void _loadFromCache() {
    try {
      final cachedCharacters = _charactersBox.values.toList();
      if (cachedCharacters.isNotEmpty) {
        emit(CharacterLoaded(
          _removeDuplicates(cachedCharacters),
          isOffline: true,
          hasReachedMax: true,
        ));
      }
    } catch (e) {
      print('Error loading from cache: $e');
      emit(CharacterError('Failed to load cached data'));
    }
  }

  Future<void> loadCharacters({bool loadMore = false}) async {
    if (_isLoading || (loadMore && !_hasMore)) return;

    _isLoading = true;
    debugPrint(
        'Loading page $_currentPage, loadMore: $loadMore, hasMore: $_hasMore');

    try {
      _isOffline = !await _isConnected();

      if (_isOffline) {
        if (loadMore) {
          emit((state as CharacterLoaded).copyWith(hasReachedMax: true));
        } else if (state is! CharacterLoaded ||
            (state as CharacterLoaded).characters.isEmpty) {
          _loadFromCache();
        }
        return;
      }

      if (!loadMore) {
        emit(CharacterLoading([]));
        _currentPage = 1;
        _hasMore = true;
      }

      final List<Character> characters =
          await repository.fetchCharacters(page: _currentPage);
      final List<Character> uniqueCharacters = _removeDuplicates(characters);

      _hasMore = uniqueCharacters.length == _pageSize;

      if (uniqueCharacters.isNotEmpty) {
        await _updateCache(uniqueCharacters);
      }

      final List<Character> currentCharacters =
          state is CharacterLoaded ? (state as CharacterLoaded).characters : [];

      final List<Character> finalCharacters = loadMore
          ? _removeDuplicates([...currentCharacters, ...uniqueCharacters])
          : uniqueCharacters;

      emit(CharacterLoaded(
        finalCharacters,
        hasReachedMax: !_hasMore,
        isOffline: false,
      ));

      if (loadMore && _hasMore) {
        _currentPage++;
      }
    } catch (e) {
      debugPrint("Loading error: $e");
      _isOffline = true;

      if (loadMore) {
        emit((state as CharacterLoaded).copyWith(hasReachedMax: true));
      } else if (state is! CharacterLoaded ||
          (state as CharacterLoaded).characters.isEmpty) {
        _loadFromCache();
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _updateCache(List<Character> characters) async {
    try {
      await _charactersBox.putAll({
        for (final character in characters) character.id.toString(): character
      });
    } catch (e) {
      print('Error updating cache: $e');
    }
  }

  List<Character> _removeDuplicates(List<Character> characters) {
    final ids = <int>{};
    return characters.where((character) => ids.add(character.id)).toList();
  }

  Future<bool> _isConnected() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      print('Connection check error: $e');
      return false;
    }
  }
}
