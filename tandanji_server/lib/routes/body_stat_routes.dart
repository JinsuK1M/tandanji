import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';

class BodyStatRoutes {
  Router get router {
    final router = Router();

    // 체성분 기록 추가
    router.post('/', (Request request) async {
      try {
        final bodyString = await request.readAsString();
        final body = jsonDecode(bodyString);
        final statId = const Uuid().v4();
        
        DatabaseService.instance.db.execute(
          'INSERT INTO body_stats (id, user_id, weight, body_fat, muscle_mass, date) VALUES (?, ?, ?, ?, ?, ?)',
          [
            statId,
            body['user_id'],
            body['weight'],
            body['body_fat'],
            body['muscle_mass'],
            DateTime.now().toIso8601String(),
          ],
        );

        return Response.ok(
          jsonEncode({
            'message': '체성분 기록이 추가되었습니다',
            'stat_id': statId,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('체성분 추가 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 최근 체성분 조회
    router.get('/latest/<userId>', (Request request, String userId) async {
      try {
        final result = DatabaseService.instance.db.select(
          'SELECT * FROM body_stats WHERE user_id = ? ORDER BY date DESC LIMIT 1',
          [userId],
        );

        if (result.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': '기록을 찾을 수 없습니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final stat = result.first;
        return Response.ok(
          jsonEncode({
            'id': stat['id'],
            'weight': stat['weight'],
            'body_fat': stat['body_fat'],
            'muscle_mass': stat['muscle_mass'],
            'date': stat['date'],
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('체성분 조회 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // ✅ 모든 체성분 기록 조회 (새로 추가)
    router.get('/list/<userId>', (Request request, String userId) async {
      try {
        final result = DatabaseService.instance.db.select(
          'SELECT * FROM body_stats WHERE user_id = ? ORDER BY date DESC',
          [userId],
        );

        final stats = result.map((row) {
          return {
            'id': row['id'],
            'weight': row['weight'],
            'body_fat': row['body_fat'],
            'muscle_mass': row['muscle_mass'],
            'date': row['date'],
          };
        }).toList();

        return Response.ok(
          jsonEncode(stats),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('체성분 목록 조회 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 주간 통계
    router.get('/weekly/<userId>', (Request request, String userId) async {
      try {
        final weekAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

        final result = DatabaseService.instance.db.select(
          'SELECT * FROM body_stats WHERE user_id = ? AND date >= ? ORDER BY date',
          [userId, weekAgo],
        );

        final stats = result.map((row) {
          return {
            'weight': row['weight'],
            'body_fat': row['body_fat'],
            'muscle_mass': row['muscle_mass'],
            'date': row['date'],
          };
        }).toList();

        return Response.ok(
          jsonEncode(stats),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('주간 통계 조회 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // ✅ 특정 체성분 기록 삭제 (새로 추가)
    router.delete('/<statId>', (Request request, String statId) async {
      try {
        // 기록이 존재하는지 확인
        final checkResult = DatabaseService.instance.db.select(
          'SELECT * FROM body_stats WHERE id = ?',
          [statId],
        );

        if (checkResult.isEmpty) {
          return Response.notFound(
            jsonEncode({'error': '기록을 찾을 수 없습니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // 기록 삭제
        DatabaseService.instance.db.execute(
          'DELETE FROM body_stats WHERE id = ?',
          [statId],
        );

        return Response.ok(
          jsonEncode({
            'message': '체성분 기록이 삭제되었습니다',
            'stat_id': statId,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('체성분 삭제 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // ✅ 모든 체성분 기록 삭제 (새로 추가)
    router.delete('/clear/<userId>', (Request request, String userId) async {
      try {
        // 삭제할 기록 수 확인
        final countResult = DatabaseService.instance.db.select(
          'SELECT COUNT(*) as count FROM body_stats WHERE user_id = ?',
          [userId],
        );

        final count = countResult.first['count'];

        if (count == 0) {
          return Response.ok(
            jsonEncode({'message': '삭제할 기록이 없습니다', 'deleted_count': 0}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // 모든 기록 삭제
        DatabaseService.instance.db.execute(
          'DELETE FROM body_stats WHERE user_id = ?',
          [userId],
        );

        return Response.ok(
          jsonEncode({
            'message': '모든 체성분 기록이 삭제되었습니다',
            'deleted_count': count,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        print('체성분 전체 삭제 오류: $e');
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}