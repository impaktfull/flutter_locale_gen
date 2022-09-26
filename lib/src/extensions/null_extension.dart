extension NullExtension<T> on T {
  R? let<R>(R Function(T) f) {
    if (this == null) return null;
    return f(this);
  }
}
