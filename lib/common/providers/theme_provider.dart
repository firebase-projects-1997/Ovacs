import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  bool _isDarkMode = false;

  ThemeProvider(this._storageService);

  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    _isDarkMode = _storageService.getBool('isDarkMode') ?? false;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _storageService.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    _storageService.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
