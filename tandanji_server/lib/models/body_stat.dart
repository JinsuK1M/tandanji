class BodyStat {
  final String id;
  final String userId;
  final double weight;
  final double? bodyFat;
  final double? muscleMass;
  final DateTime date;

  BodyStat({
    required this.id,
    required this.userId,
    required this.weight,
    this.bodyFat,
    this.muscleMass,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'weight': weight,
    'body_fat': bodyFat,
    'muscle_mass': muscleMass,
    'date': date.toIso8601String(),
  };

  factory BodyStat.fromMap(Map<String, dynamic> map) => BodyStat(
    id: map['id'],
    userId: map['user_id'],
    weight: (map['weight'] as num).toDouble(),
    bodyFat: map['body_fat'] != null ? (map['body_fat'] as num).toDouble() : null,
    muscleMass: map['muscle_mass'] != null ? (map['muscle_mass'] as num).toDouble() : null,
    date: DateTime.parse(map['date']),
  );
}