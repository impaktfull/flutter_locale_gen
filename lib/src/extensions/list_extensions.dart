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
}
