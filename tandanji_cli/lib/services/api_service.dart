import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  final String baseUrl = 'http://localhost:8080/api';

  // ==================== 인증 API ====================

  /// 회원가입
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? '회원가입 실패');
    }
  }

  /// 로그인
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
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
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? '로그인 실패');
    }
  }

  // ==================== 식단 API ====================

  /// 식단 추가
  Future<Map<String, dynamic>> addMeal({
    required String userId,
    required String name,
    required int mealNumber,
    required List<Map<String, dynamic>> foods,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/meals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'name': name,
        'meal_number': mealNumber,
        'foods': foods,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('식단 추가 실패: ${response.body}');
    }
  }

  /// 오늘의 식단 조회
  Future<List<dynamic>> getTodayMeals(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meals/today/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('식단 조회 실패');
    }
  }

  /// 식단 전체 수정
  Future<Map<String, dynamic>> updateMeal({
    required String userId,
    required int mealNumber,
    required String name,
    required List<Map<String, dynamic>> foods,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/meals/today/$userId/meal/$mealNumber'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'foods': foods,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('식단 수정 실패');
    }
  }

  /// 식단 ID로 삭제
  Future<Map<String, dynamic>> deleteMealById(String mealId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/meals/$mealId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('식단 삭제 실패');
    }
  }

  /// 오늘의 특정 끼니 삭제
  Future<Map<String, dynamic>> deleteTodayMeal(
    String userId,
    int mealNumber,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/meals/today/$userId/meal/$mealNumber'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('식단 삭제 실패');
    }
  }

  // ==================== 체성분 API ====================

  /// 체성분 기록 추가
  Future<Map<String, dynamic>> addBodyStat({
    required String userId,
    required double weight,
    double? bodyFat,
    double? muscleMass,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/body-stats'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'weight': weight,
        'body_fat': bodyFat,
        'muscle_mass': muscleMass,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('체성분 기록 실패');
    }
  }

  /// 최근 체성분 조회
  Future<Map<String, dynamic>> getLatestBodyStat(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/body-stats/latest/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('체성분 조회 실패');
    }
  }

  /// 모든 체성분 기록 조회
  Future<List<dynamic>> getAllBodyStats(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/body-stats/list/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('체성분 목록 조회 실패');
    }
  }

  /// 주간 통계 조회
  Future<List<dynamic>> getWeeklyStats(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/body-stats/weekly/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('주간 통계 조회 실패');
    }
  }

  /// 특정 체성분 기록 삭제
  Future<Map<String, dynamic>> deleteBodyStat(String statId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/body-stats/$statId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('체성분 기록 삭제 실패');
    }
  }

  /// 모든 체성분 기록 삭제
  Future<Map<String, dynamic>> clearAllBodyStats(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/body-stats/clear/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('체성분 기록 전체 삭제 실패');
    }
  }

  // ==================== 사용자 API ====================

  /// 사용자 정보 조회
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('사용자 정보 조회 실패');
    }
  }

  /// 식단 목표 업데이트
  Future<Map<String, dynamic>> updateDietPlan(
    String userId,
    String dietPlan,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/diet-plan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'diet_plan': dietPlan,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('식단 목표 업데이트 실패');
    }
  }
}