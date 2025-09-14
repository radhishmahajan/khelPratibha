class Recommendation {
  final String id;
  final String text;

  Recommendation({required this.id, required this.text});

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'],
      text: map['recommendation_text'],
    );
  }
}