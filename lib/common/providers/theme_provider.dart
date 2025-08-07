import 'package:flutter/material.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:new_ovacs/core/utils/color_utils.dart';
import '../../../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  ThemeProvider(this._storageService);

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Color _primaryColor = AppColors.primaryBlue;
  Color get primaryColor => _primaryColor;

  /// Gets the 4 derived colors for dashboard cards based on the current primary color
  List<Color> get dashboardColors =>
      ColorUtils.getDashboardColors(_primaryColor);

  Future<void> init() async {
    _isDarkMode = _storageService.getBool('isDarkMode') ?? false;

    final hexColor = _storageService.getString('primary_color');
    if (hexColor != null) {
      final color = ColorUtils.hexToColor(hexColor);
      _primaryColor = color ?? AppColors.primaryBlue;
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
    final hexColor = ColorUtils.colorToHex(color);
    _storageService.setString('primary_color', hexColor);
    _primaryColor = color;
    notifyListeners();
  }
}
