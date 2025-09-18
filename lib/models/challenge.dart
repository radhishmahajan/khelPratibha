class Challenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final double goal;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.goal,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      goal: (map['goal'] as num).toDouble(),
    );
  }
}