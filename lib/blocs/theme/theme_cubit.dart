import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false) {
    _loadTheme();
  }

  bool get isDarkMode => state;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getBool('isDarkMode') ?? false);
  }

  Future<void> toggleTheme() async {
    final newValue = !state;
    emit(newValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newValue);
  }
}
