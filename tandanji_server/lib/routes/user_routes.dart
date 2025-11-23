import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/database_service.dart';

class UserRoutes {
  Router get router {
    final router = Router();

    // 사용자 정보 조회
    router.get('/<userId>', (Request request, String userId) async {
      try {
        final result = DatabaseService.instance.db.select(
          'SELECT id, email, name, weight, height, age, diet_plan FROM users WHERE id = ?',
          [userId],
        );

        if (result.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': '사용자를 찾을 수 없습니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final user = result.first;
        return Response.ok(
          jsonEncode(user),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 식단 목표 업데이트
    router.put('/<userId>/diet-plan', (Request request, String userId) async {
      try {
        final body = jsonDecode(await request.readAsString());
        final dietPlan = body['diet_plan'];

        DatabaseService.instance.db.execute(
          'UPDATE users SET diet_plan = ? WHERE id = ?',
          [dietPlan, userId],
        );

        return Response.ok(jsonEncode({
          'message': '식단 목표가 업데이트되었습니다',
        }), headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}