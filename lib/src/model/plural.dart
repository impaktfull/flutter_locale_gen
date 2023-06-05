class Plural {
  final String? zero;
  final String? one;
  final String? two;
  final String? few;
  final String? many;
  final String other;

  Plural.fromJson(Map<String, dynamic> json)
      : zero = json['zero'] as String?,
        one = json['one'] as String?,
        two = json['two'] as String?,
        few = json['few'] as String?,
        many = json['many'] as String?,
        other = json['other'] as String;
}
