/// String helpers for the package's own use; nothing here is exported.
extension StringExt on String {
  /// The string with its first character in upper case.
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
