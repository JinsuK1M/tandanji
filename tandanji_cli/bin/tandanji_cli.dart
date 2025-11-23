import 'dart:io';
import 'package:args/command_runner.dart';
import '../lib/commands/auth_command.dart';
import '../lib/commands/meal_command.dart';
import '../lib/commands/stats_command.dart';
import '../lib/commands/body_command.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner(
    'tandanji',
    '🥗 탄단지 - 다이어트 도우미 CLI\n\n'
    '사용 예시:\n'
    '  tandanji auth register     # 회원가입\n'
    '  tandanji auth login        # 로그인\n'
    '  tandanji meal add -m 1     # 식단 추가\n'
    '  tandanji meal list         # 오늘의 식단\n'
    '  tandanji body add          # 체중 기록\n'
    '  tandanji stats             # 통계 조회',
  )
    ..addCommand(AuthCommand())
    ..addCommand(MealCommand())
    ..addCommand(StatsCommand())
    ..addCommand(BodyCommand());

  try {
    await runner.run(arguments);
  } catch (e) {
    if (e is UsageException) {
      print(e.message);
      print('\n${e.usage}');
    } else {
      print('❌ 오류: $e');
    }
    exit(1);
  }
}