import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // 인증
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? '회원가입 실패');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? '로그인 실패');
    }
  }

  // 체성분
  Future<void> addBodyStat({
    required String userId,
    required double weight,
    double? bodyFat,
    double? muscleMass,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/body'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'weight': weight,
        'body_fat': bodyFat,
        'muscle_mass': muscleMass,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('체성분 기록 실패');
    }
  }

  Future<Map<String, dynamic>> getLatestBodyStat(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/body/$userId/latest'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('체성분 조회 실패');
    }
  }

  Future<List<dynamic>> getAllBodyStats(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/body/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('체성분 목록 조회 실패');
    }
  }

  Future<void> deleteBodyStat(String statId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/body/$statId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('체성분 삭제 실패');
    }
  }

  // 식단
  Future<void> addMeal({
    required String userId,
    required String mealName,
    required String foodName,
    required int calories,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/meals'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'meal_name': mealName,
        'food_name': foodName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('식단 기록 실패');
    }
  }

  Future<List<dynamic>> getTodayMeals(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meals/$userId/today'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('식단 조회 실패');
    }
  }

  Future<List<dynamic>> getAllMeals(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meals/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('식단 목록 조회 실패');
    }
  }

  // 운동
  Future<void> addWorkout({
    required String userId,
    required String exerciseName,
    required int sets,
    required int reps,
    double? weight,
    int? duration,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/workouts'),
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'exercise_name': exerciseName,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'duration': duration,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('운동 기록 실패');
    }
  }

  Future<List<dynamic>> getTodayWorkouts(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/workouts/$userId/today'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('운동 조회 실패');
    }
  }

  Future<List<dynamic>> getAllWorkouts(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/workouts/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('운동 목록 조회 실패');
    }
  }
}
