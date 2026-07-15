import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);
  void toggleTheme(Brightness currentBrightness) {
    if (currentBrightness == Brightness.dark) {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.dark);
    }
  }

  void useSystemTheme() {
    emit(ThemeMode.system);
  }
}
