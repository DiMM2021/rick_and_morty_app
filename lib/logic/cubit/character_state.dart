part of 'character_cubit.dart';

@immutable
abstract class CharacterState {}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {
  final List<Character> characters;

  CharacterLoading(this.characters);
}

class CharacterLoaded extends CharacterState {
  final List<Character> characters;
  final bool hasReachedMax;
  final bool isOffline;

  CharacterLoaded(
    this.characters, {
    this.hasReachedMax = false,
    this.isOffline = false,
  });

  CharacterLoaded copyWith({
    List<Character>? characters,
    bool? hasReachedMax,
    bool? isOffline,
  }) {
    return CharacterLoaded(
      characters ?? this.characters,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class CharacterError extends CharacterState {
  final String message;

  CharacterError(this.message);
}
