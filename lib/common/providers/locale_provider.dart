import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  final StorageService _storageService;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider(this._storageService);

  Future<void> init() async {
    final langCode = _storageService.getString('locale');
    if (langCode != null) {
      _locale = Locale(langCode);
    }
  }

  void setLocale(Locale locale) {
    _locale = locale;
    _storageService.setString('locale', locale.languageCode);
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('en');
    _storageService.setString('locale', 'en');
    notifyListeners();
  }
}
