import 'package:flutter/material.dart';

bool isDarkMode(context) {
  if (Theme.of(context).brightness == Brightness.dark) return true;
  return false;
}
