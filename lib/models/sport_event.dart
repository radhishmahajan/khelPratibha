class SportEvent {
  final String id;
  final String programId;
  final String name;
  final String description;

  const SportEvent({
    required this.id,
    required this.programId,
    required this.name,
    required this.description,
  });

  factory SportEvent.fromMap(Map<String, dynamic> map) {
    return SportEvent(
      id: map['id'] ?? '',
      programId: map['program_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}