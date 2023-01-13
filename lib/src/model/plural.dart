class Plural {
  final String? zero;
  final String? one;
  final String? two;
  final String? few;
  final String? many;
  final String other;

  Plural.fromJson(Map<String, dynamic> json)
      : zero = json['zero'],
        one = json['one'],
        two = json['two'],
        few = json['few'],
        many = json['many'],
        other = json['other'];
}
