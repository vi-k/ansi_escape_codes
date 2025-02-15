extension StringExt on String {
  String firstToUpperCase() {
    if (isEmpty) {
      return this;
    }

    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension ListExt on List<dynamic> {
  int get deepHashCode {
    var hash = 0;

    for (final v in this) {
      if (v is List<dynamic>) {
        hash ^= v.deepHashCode;
      } else {
        hash ^= v.hashCode;
      }
    }

    return hash;
  }

  bool deepEquals(List<dynamic> other) {
    if (identical(this, other)) {
      return true;
    }

    final length = this.length;
    if (other.length != length) {
      return false;
    }

    for (var i = 0; i < length; i++) {
      final a = this[i];
      final b = other[i];

      if (a is List<dynamic> && b is List<dynamic> && !a.deepEquals(b) ||
          a != b) {
        return false;
      }
    }

    return true;
  }
}
