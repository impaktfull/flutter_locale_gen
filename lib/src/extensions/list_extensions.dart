extension ListExtension<T> on List<T> {
  List<T> moveToFirstIndex(T item) => List<T>.from(this)
    ..remove(item)
    ..insert(0, item);
}
