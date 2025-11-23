import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';

class MealRoutes {
  Router get router {
    final router = Router();

    // 식단 추가
    router.post('/', (Request request) async {
      try {
        final bodyString = await request.readAsString();
        final body = jsonDecode(bodyString);
        final mealId = const Uuid().v4();
        
        DatabaseService.instance.db.execute(
          'INSERT INTO meals (id, user_id, name, meal_number, foods, date) VALUES (?, ?, ?, ?, ?, ?)',
          [
            mealId,
            body['user_id'],
            body['name'],
            body['meal_number'],
            jsonEncode(body['foods']),
            DateTime.now().toIso8601String(),
          ],
        );

        return Response.ok(
          jsonEncode({
            'message': '식단이 추가되었습니다',
            'meal_id': mealId,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('식단 추가 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // ✅ 식단 수정 (새로 추가)
    router.put('/today/<userId>/meal/<mealNumber>', 
      (Request request, String userId, String mealNumber) async {
      try {
        final bodyString = await request.readAsString();
        final body = jsonDecode(bodyString);
        
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
        final endOfDay = DateTime(today.year, today.month, today.day + 1).toIso8601String();

        // 기존 식단이 있는지 확인
        final existing = DatabaseService.instance.db.select(
          'SELECT * FROM meals WHERE user_id = ? AND meal_number = ? AND date >= ? AND date < ?',
          [userId, int.parse(mealNumber), startOfDay, endOfDay],
        );

        if (existing.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': 'Meal $mealNumber을 찾을 수 없습니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // 식단 업데이트
        DatabaseService.instance.db.execute(
          'UPDATE meals SET foods = ?, name = ? WHERE user_id = ? AND meal_number = ? AND date >= ? AND date < ?',
          [
            jsonEncode(body['foods']),
            body['name'] ?? 'Meal $mealNumber',
            userId,
            int.parse(mealNumber),
            startOfDay,
            endOfDay,
          ],
        );

        return Response.ok(
          jsonEncode({
            'message': 'Meal $mealNumber이 수정되었습니다',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('식단 수정 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // ✅ 식단에 음식 추가 (새로 추가)
    router.post('/today/<userId>/meal/<mealNumber>/food', 
      (Request request, String userId, String mealNumber) async {
      try {
        final bodyString = await request.readAsString();
        final body = jsonDecode(bodyString);
        
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
        final endOfDay = DateTime(today.year, today.month, today.day + 1).toIso8601String();

        // 기존 식단 조회
        final existing = DatabaseService.instance.db.select(
          'SELECT * FROM meals WHERE user_id = ? AND meal_number = ? AND date >= ? AND date < ?',
          [userId, int.parse(mealNumber), startOfDay, endOfDay],
        );

        if (existing.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': 'Meal $mealNumber을 찾을 수 없습니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // 기존 음식 목록 가져오기
        final currentFoods = jsonDecode(existing.first['foods'] as String) as List;
        
        // 새 음식 추가
        currentFoods.add(body);

        // 업데이트
        DatabaseService.instance.db.execute(
          'UPDATE meals SET foods = ? WHERE user_id = ? AND meal_number = ? AND date >= ? AND date < ?',
          [
            jsonEncode(currentFoods),
            userId,
            int.parse(mealNumber),
            startOfDay,
            endOfDay,
          ],
        );

        return Response.ok(
          jsonEncode({
            'message': '음식이 추가되었습니다',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('음식 추가 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // ✅ 식단에서 음식 삭제 (새로 추가)
    router.delete('/today/<userId>/meal/<mealNumber>/food/<foodIndex>', 
      (Request request, String userId, String mealNumber, String foodIndex) async {
      try {
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
        final endOfDay = DateTime(today.year, today.month, today.day + 1).toIso8601String();

        // 기존 식단 조회
        final existing = DatabaseService.instance.db.select(
          'SELECT * FROM meals WHERE user_id = ? AND meal_number = ? AND date >= ? AND date < ?',
          [userId, int.parse(mealNumber), startOfDay, endOfDay],
        );

        if (existing.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': 'Meal $mealNumber을 찾을 수 없습니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // 기존 음식 목록 가져오기
        final currentFoods = jsonDecode(existing.first['foods'] as String) as List;
        final index = int.parse(foodIndex);

        if (index < 0 || index >= currentFoods.length) {
          return Response.badRequest(
            body: jsonEncode({'error': '잘못된 음식 인덱스입니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // 음식 삭제
        currentFoods.removeAt(index);

        // 업데이트
        DatabaseService.instance.db.execute(
          'UPDATE meals SET foods = ? WHERE user_id = ? AND meal_number = ? AND date >= ? AND date < ?',
          [
            jsonEncode(currentFoods),
            userId,
            int.parse(mealNumber),
            startOfDay,
            endOfDay,
          ],
        );

        return Response.ok(
          jsonEncode({
            'message': '음식이 삭제되었습니다',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('음식 삭제 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 오늘의 식단 조회
    router.get('/today/<userId>', (Request request, String userId) async {
      try {
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
        final endOfDay = DateTime(today.year, today.month, today.day + 1).toIso8601String();

        final result = DatabaseService.instance.db.select(
          'SELECT * FROM meals WHERE user_id = ? AND date >= ? AND date < ? ORDER BY meal_number',
          [userId, startOfDay, endOfDay],
        );

        final meals = result.map((row) {
          return {
            'id': row['id'],
            'name': row['name'],
            'meal_number': row['meal_number'],
            'foods': jsonDecode(row['foods'] as String),
            'date': row['date'],
          };
        }).toList();

        return Response.ok(
          jsonEncode(meals),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('식단 조회 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 식단 삭제 (ID로)
    router.delete('/<mealId>', (Request request, String mealId) async {
      try {
        final checkResult = DatabaseService.instance.db.select(
          'SELECT * FROM meals WHERE id = ?',
          [mealId],
        );

        if (checkResult.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': '식단을 찾을 수 없습니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        DatabaseService.instance.db.execute(
          'DELETE FROM meals WHERE id = ?',
          [mealId],
        );

        return Response.ok(
          jsonEncode({
            'message': '식단이 삭제되었습니다',
            'meal_id': mealId,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('식단 삭제 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 특정 끼니 삭제
    router.delete('/today/<userId>/meal/<mealNumber>', 
      (Request request, String userId, String mealNumber) async {
      try {
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
        final endOfDay = DateTime(today.year, today.month, today.day + 1).toIso8601String();

        DatabaseService.instance.db.execute(
          'DELETE FROM meals WHERE user_id = ? AND meal_number = ? AND date >= ? AND date < ?',
          [userId, int.parse(mealNumber), startOfDay, endOfDay],
        );

        return Response.ok(
          jsonEncode({
            'message': 'Meal $mealNumber이 삭제되었습니다',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('식단 삭제 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}