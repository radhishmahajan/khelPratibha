class Goal {
  final String id;
  final String description;
  final bool isCompleted;

  Goal({
    required this.id,
    required this.description,
    this.isCompleted = false,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      description: map['description'],
      isCompleted: map['is_completed'] ?? false,
    );
  }
}