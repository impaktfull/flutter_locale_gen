extension ListExtension<T> on List<T> {
  List<T> moveToFirstIndex(T item) {
    for (var i = 0; i < length; ++i) {
      if (this[i] == item) {
        final temp = this[0];
        this[0] = this[i];
        this[i] = temp;
        break;
      }
    }
    return this;
  }

  List<T> sortedBy<R>(Comparable<R> Function(T item) by) {
    sort((a, b) => _compareValues(by(a), by(b)));
    return this;
  }
}

int _compareValues<T extends Comparable<dynamic>>(T a, T b) {
  if (identical(a, b)) return 0;
  return a.compareTo(b);
}
