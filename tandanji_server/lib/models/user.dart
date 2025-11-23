class User {
  final String id;
  final String email;
  final String name;
  final String passwordHash;
  final double? weight;
  final double? height;
  final int? age;
  final String dietPlan;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.passwordHash,
    this.weight,
    this.height,
    this.age,
    this.dietPlan = 'diet',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'weight': weight,
    'height': height,
    'age': age,
    'diet_plan': dietPlan,
    'created_at': createdAt.toIso8601String(),
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    email: map['email'],
    name: map['name'],
    passwordHash: map['password_hash'],
    weight: map['weight']?.toDouble(),
    height: map['height']?.toDouble(),
    age: map['age'],
    dietPlan: map['diet_plan'] ?? 'diet',
    createdAt: DateTime.parse(map['created_at']),
  );
}