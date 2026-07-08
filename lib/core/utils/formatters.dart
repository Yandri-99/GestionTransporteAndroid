class Formatters {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String severityLabel(String severity) {
    switch (severity) {
      case 'high': return 'Alta';
      case 'medium': return 'Media';
      case 'low': return 'Baja';
      default: return severity;
    }
  }

  static String statusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }
}
