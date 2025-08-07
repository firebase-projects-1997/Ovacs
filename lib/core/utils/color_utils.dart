import 'package:flutter/material.dart';

/// Utility class for color operations and theme color generation
class ColorUtils {
  /// 8 predefined theme colors for the app
  static const List<Color> themeColors = [
    Color(0xFF29AECB), // Ocean Blue (original primary)
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
  ];

  /// Names for the theme colors (for display purposes)
  static const List<String> themeColorNames = [
    'Ocean Blue',
    'Indigo',
    'Purple',
    'Pink',
    'Red',
    'Amber',
    'Emerald',
    'Cyan',
  ];

  /// Generates 4 derived colors from a primary color for dashboard cards
  /// Returns colors with different variations: primary, lighter, darker, and accent
  static List<Color> getDashboardColors(Color primaryColor) {
    final HSLColor hslColor = HSLColor.fromColor(primaryColor);
    
    return [
      // Card 1: Original primary color
      primaryColor,
      
      // Card 2: Lighter variation (increased lightness)
      hslColor.withLightness(
        (hslColor.lightness + 0.15).clamp(0.0, 1.0)
      ).toColor(),
      
      // Card 3: Darker variation (decreased lightness)
      hslColor.withLightness(
        (hslColor.lightness - 0.15).clamp(0.0, 1.0)
      ).toColor(),
      
      // Card 4: Accent variation (shifted hue)
      hslColor.withHue(
        (hslColor.hue + 30) % 360
      ).withSaturation(
        (hslColor.saturation + 0.1).clamp(0.0, 1.0)
      ).toColor(),
    ];
  }

  /// Generates a complementary color
  static Color getComplementaryColor(Color color) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor.withHue((hslColor.hue + 180) % 360).toColor();
  }

  /// Generates an analogous color (30 degrees shift)
  static Color getAnalogousColor(Color color, {double hueShift = 30}) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor.withHue((hslColor.hue + hueShift) % 360).toColor();
  }

  /// Generates a triadic color (120 degrees shift)
  static Color getTriadicColor(Color color) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor.withHue((hslColor.hue + 120) % 360).toColor();
  }

  /// Creates a lighter shade of the color
  static Color lighten(Color color, [double amount = 0.1]) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness(
      (hslColor.lightness + amount).clamp(0.0, 1.0)
    ).toColor();
  }

  /// Creates a darker shade of the color
  static Color darken(Color color, [double amount = 0.1]) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness(
      (hslColor.lightness - amount).clamp(0.0, 1.0)
    ).toColor();
  }

  /// Creates a more saturated version of the color
  static Color saturate(Color color, [double amount = 0.1]) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor.withSaturation(
      (hslColor.saturation + amount).clamp(0.0, 1.0)
    ).toColor();
  }

  /// Creates a less saturated version of the color
  static Color desaturate(Color color, [double amount = 0.1]) {
    final HSLColor hslColor = HSLColor.fromColor(color);
    return hslColor.withSaturation(
      (hslColor.saturation - amount).clamp(0.0, 1.0)
    ).toColor();
  }

  /// Checks if a color is light or dark (for text contrast)
  static bool isLightColor(Color color) {
    final double luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  /// Gets appropriate text color (black or white) for a background color
  static Color getTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black : Colors.white;
  }

  /// Converts a color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Converts hex string to color
  static Color? hexToColor(String hex) {
    try {
      final String cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Creates a gradient from a primary color
  static LinearGradient createGradient(Color primaryColor, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        primaryColor.withOpacity(0.9),
        primaryColor.withOpacity(0.7),
      ],
    );
  }

  /// Creates a material color swatch from a single color
  static MaterialColor createMaterialColor(Color color) {
    final Map<int, Color> swatch = {
      50: lighten(color, 0.4),
      100: lighten(color, 0.3),
      200: lighten(color, 0.2),
      300: lighten(color, 0.1),
      400: lighten(color, 0.05),
      500: color,
      600: darken(color, 0.05),
      700: darken(color, 0.1),
      800: darken(color, 0.2),
      900: darken(color, 0.3),
    };
    
    return MaterialColor(color.value, swatch);
  }
}
