import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../lib/routes/auth_routes.dart';
import '../lib/routes/meal_routes.dart';
import '../lib/routes/body_stat_routes.dart';
import '../lib/routes/user_routes.dart';
import '../lib/services/database_service.dart';

void main() async {
  print('🚀 탄단지 서버 시작 중...');
  
  // 데이터베이스 초기화
  try {
    await DatabaseService.instance.init();
  } catch (e) {
    print('❌ 데이터베이스 연결 실패: $e');
    print('💡 PostgreSQL이 실행 중인지 확인하세요: brew services start postgresql@14');
    exit(1);
  }
  
  final app = Router();

  // 헬스 체크
  app.get('/health', (Request request) {
    return Response.ok('Server is running!');
  });

  // 라우트 등록
  app.mount('/api/auth', AuthRoutes().router);
  app.mount('/api/meals', MealRoutes().router);
  app.mount('/api/body-stats', BodyStatRoutes().router);
  app.mount('/api/users', UserRoutes().router);

  // 미들웨어 설정
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(app);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('✅ 탄단지 서버가 http://${server.address.host}:${server.port} 에서 실행 중입니다');
  print('📡 API 엔드포인트: http://localhost:8080/api');
}