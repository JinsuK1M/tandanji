import 'dart:io';
import 'package:args/command_runner.dart';
import '../services/api_service.dart';
import '../services/config_service.dart';

class AuthCommand extends Command {
  @override
  final name = 'auth';
  @override
  final description = '인증 관련 명령어 (login, register, logout)';

  AuthCommand() {
    addSubcommand(LoginCommand());
    addSubcommand(RegisterCommand());
    addSubcommand(LogoutCommand());
  }
}

class LoginCommand extends Command {
  @override
  final name = 'login';
  @override
  final description = '로그인';

  @override
  Future<void> run() async {
    print('\n🔐 로그인\n');
    
    stdout.write('이메일: ');
    final email = stdin.readLineSync()?.trim() ?? '';

    stdout.write('비밀번호: ');
    stdin.echoMode = false;
    final password = stdin.readLineSync() ?? '';
    stdin.echoMode = true;
    print('');

    if (email.isEmpty || password.isEmpty) {
      print('❌ 이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    try {
      print('\n⏳ 로그인 중...');
      final result = await ApiService.instance.login(email, password);
      await ConfigService.instance.saveUserId(result['user_id'], result['name']);
      
      print('\n✅ 로그인 성공!');
      print('환영합니다, ${result['name']}님! 🎉\n');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

class RegisterCommand extends Command {
  @override
  final name = 'register';
  @override
  final description = '회원가입';

  @override
  Future<void> run() async {
    print('\n📝 회원가입\n');
    
    stdout.write('이름: ');
    final name = stdin.readLineSync()?.trim() ?? '';

    stdout.write('이메일: ');
    final email = stdin.readLineSync()?.trim() ?? '';

    stdout.write('비밀번호: ');
    stdin.echoMode = false;
    final password = stdin.readLineSync() ?? '';
    stdin.echoMode = true;
    print('');

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      print('❌ 모든 정보를 입력해주세요.');
      return;
    }

    try {
      print('\n⏳ 회원가입 중...');
      final result = await ApiService.instance.register(email, password, name);
      await ConfigService.instance.saveUserId(result['user_id'], name);
      
      print('\n✅ 회원가입 성공!');
      print('환영합니다, $name님! 🎉\n');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

class LogoutCommand extends Command {
  @override
  final name = 'logout';
  @override
  final description = '로그아웃';

  @override
  Future<void> run() async {
    await ConfigService.instance.clearConfig();
    print('✅ 로그아웃 되었습니다.\n');
  }
}