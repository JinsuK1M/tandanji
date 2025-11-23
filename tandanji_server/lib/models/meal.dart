import 'dart:convert';

class Meal {
  final String id;
  final String userId;
  final String name;
  final int mealNumber;
  final List<FoodItem> foods;
  final DateTime date;

  Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.mealNumber,
    required this.foods,
    required this.date,
  });

  double get totalCarbs => foods.fold(0, (sum, food) => sum + food.carbs);
  double get totalProtein => foods.fold(0, (sum, food) => sum + food.protein);
  double get totalFat => foods.fold(0, (sum, food) => sum + food.fat);
  double get totalCalories => 
    (totalCarbs * 4) + (totalProtein * 4) + (totalFat * 9);

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'meal_number': mealNumber,
    'foods': foods.map((f) => f.toJson()).toList(),
    'date': date.toIso8601String(),
    'total_carbs': totalCarbs,
    'total_protein': totalProtein,
    'total_fat': totalFat,
    'total_calories': totalCalories,
  };

  factory Meal.fromMap(Map<String, dynamic> map) {
    final foodsJson = jsonDecode(map['foods'] as String) as List;
    return Meal(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      mealNumber: map['meal_number'],
      foods: foodsJson.map((f) => FoodItem.fromJson(f)).toList(),
      date: DateTime.parse(map['date']),
    );
  }
}

class FoodItem {
  final String name;
  final double amount;
  final double carbs;
  final double protein;
  final double fat;

  FoodItem({
    required this.name,
    required this.amount,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'carbs': carbs,
    'protein': protein,
    'fat': fat,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    name: json['name'],
    amount: (json['amount'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
    protein: (json['protein'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
  );
}