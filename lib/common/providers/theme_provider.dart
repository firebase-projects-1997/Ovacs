import 'package:flutter/material.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import '../../../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  ThemeProvider(this._storageService);

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Color _primaryColor = AppColors.primaryBlue;
  Color get primaryColor => _primaryColor;

  Future<void> init() async {
    _isDarkMode = _storageService.getBool('isDarkMode') ?? false;

    final hexColor = _storageService.getString('primary_color');
    if (hexColor != null) {
      try {
        final colorValue = int.parse(hexColor, radix: 16);
        _primaryColor = Color(colorValue);
      } catch (_) {
        _primaryColor = AppColors.primaryBlue;
      }
    } else {
      _primaryColor = AppColors.primaryBlue;
    }
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

  void setPrimaryColor(Color color) {
    final hexColor = color.value.toRadixString(16);
    _storageService.setString('primary_color', hexColor);
    _primaryColor = color;
    notifyListeners();
  }
}
