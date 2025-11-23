import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';

class AuthRoutes {
  Router get router {
    final router = Router();

    // 회원가입
    router.post('/register', (Request request) async {
      try {
        final body = jsonDecode(await request.readAsString());
        final email = body['email'];
        final password = body['password'];
        final name = body['name'];

        // 이메일 중복 체크
        final existing = DatabaseService.instance.db.select(
          'SELECT * FROM users WHERE email = ?',
          [email],
        );

        if (existing.isNotEmpty) {
          return Response(409, 
            body: jsonEncode({'error': '이미 존재하는 이메일입니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // 비밀번호 해시화
        final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
        final userId = const Uuid().v4();

        DatabaseService.instance.db.execute(
          'INSERT INTO users (id, email, name, password_hash) VALUES (?, ?, ?, ?)',
          [userId, email, name, passwordHash],
        );

        return Response.ok(jsonEncode({
          'message': '회원가입 성공',
          'user_id': userId,
        }), headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // 로그인
    router.post('/login', (Request request) async {
      try {
        final body = jsonDecode(await request.readAsString());
        final email = body['email'];
        final password = body['password'];

        final result = DatabaseService.instance.db.select(
          'SELECT * FROM users WHERE email = ?',
          [email],
        );

        if (result.isEmpty) {
          return Response(403,
            body: jsonEncode({'error': '이메일 또는 비밀번호가 잘못되었습니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final user = result.first;
        final passwordHash = user['password_hash'] as String;

        if (!BCrypt.checkpw(password, passwordHash)) {
          return Response(403,
            body: jsonEncode({'error': '이메일 또는 비밀번호가 잘못되었습니다'}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        return Response.ok(jsonEncode({
          'message': '로그인 성공',
          'user_id': user['id'],
          'name': user['name'],
          'email': user['email'],
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