import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final Box settingsBox;

  ThemeCubit(this.settingsBox) : super(ThemeState(ThemeMode.light)) {
    _loadTheme();
  }

  void _loadTheme() {
    bool isDark = settingsBox.get('isDarkTheme', defaultValue: false);
    emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
  }

  void toggleTheme() {
    final isDark = state.themeMode == ThemeMode.light;
    settingsBox.put('isDarkTheme', isDark);
    emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
  }
}
