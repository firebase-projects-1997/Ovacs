enum DocumentSecurityLevel {
  red('red'),
  yellow('yellow'),
  green('green');

  const DocumentSecurityLevel(this.value);
  final String value;

  static DocumentSecurityLevel fromString(String? level) {
    switch (level?.toLowerCase()) {
      case 'red':
        return DocumentSecurityLevel.red;
      case 'yellow':
        return DocumentSecurityLevel.yellow;
      case 'green':
        return DocumentSecurityLevel.green;
      default:
        return DocumentSecurityLevel.green; // Default to most permissive
    }
  }

  String get displayName {
    switch (this) {
      case DocumentSecurityLevel.red:
        return 'Red (Highly Confidential)';
      case DocumentSecurityLevel.yellow:
        return 'Yellow (Confidential)';
      case DocumentSecurityLevel.green:
        return 'Green (General)';
    }
  }

  /// Get the color associated with this security level
  int get colorValue {
    switch (this) {
      case DocumentSecurityLevel.red:
        return 0xFFE53E3E; // Red
      case DocumentSecurityLevel.yellow:
        return 0xFFD69E2E; // Yellow
      case DocumentSecurityLevel.green:
        return 0xFF38A169; // Green
    }
  }
}
