class Chore {
  const Chore({
    required this.id,
    required this.familyId,
    required this.name,
    required this.assigneeId,
    required this.instructions,
    required this.scheduledAt,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String familyId; // relasi -> Family.id
  final String name;
  final String assigneeId; // relasi -> Member.id
  final String instructions;
  final DateTime scheduledAt; // tenggat waktu
  final bool isCompleted;
  final DateTime? completedAt; // waktu selesai

  Chore copyWith({
    String? id,
    String? familyId,
    String? name,
    String? assigneeId,
    String? instructions,
    DateTime? scheduledAt,
    bool? isCompleted,
    DateTime? completedAt,
  }) =>
      Chore(
        id: id ?? this.id,
        familyId: familyId ?? this.familyId,
        name: name ?? this.name,
        assigneeId: assigneeId ?? this.assigneeId,
        instructions: instructions ?? this.instructions,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
      );
}
