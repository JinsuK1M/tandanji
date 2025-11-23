import 'dart:io';
import 'package:args/command_runner.dart';
import '../services/api_service.dart';
import '../services/config_service.dart';

class BodyCommand extends Command {
  @override
  final name = 'body';
  @override
  final description = '체성분 관련 명령어 (add, show, list, delete, clear)';

  BodyCommand() {
    addSubcommand(AddBodyStatCommand());
    addSubcommand(ShowBodyStatCommand());
    addSubcommand(ListBodyStatsCommand());
    addSubcommand(DeleteBodyStatCommand());
    addSubcommand(ClearBodyStatsCommand());
  }
}

class AddBodyStatCommand extends Command {
  @override
  final name = 'add';
  @override
  final description = '체성분 기록 추가';

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    print('\n⚖️ 체성분 기록 추가\n');

    stdout.write('체중 (kg): ');
    final weightStr = stdin.readLineSync()?.trim() ?? '';
    final weight = double.tryParse(weightStr);
    if (weight == null) {
      print('❌ 올바른 숫자를 입력하세요.\n');
      return;
    }

    stdout.write('체지방률 (%) [선택사항, 엔터로 스킵]: ');
    final bodyFatInput = stdin.readLineSync()?.trim() ?? '';
    final bodyFat = bodyFatInput.isEmpty ? null : double.tryParse(bodyFatInput);

    stdout.write('골격근량 (kg) [선택사항, 엔터로 스킵]: ');
    final muscleMassInput = stdin.readLineSync()?.trim() ?? '';
    final muscleMass = muscleMassInput.isEmpty ? null : double.tryParse(muscleMassInput);

    try {
      print('\n⏳ 기록 저장 중...');
      await ApiService.instance.addBodyStat(
        userId: config['user_id'],
        weight: weight,
        bodyFat: bodyFat,
        muscleMass: muscleMass,
      );

      print('\n✅ 체성분 기록이 추가되었습니다!');
      print('  체중: ${weight}kg');
      if (bodyFat != null) print('  체지방률: ${bodyFat}%');
      if (muscleMass != null) print('  골격근량: ${muscleMass}kg');
      print('');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

class ShowBodyStatCommand extends Command {
  @override
  final name = 'show';
  @override
  final description = '최근 체성분 조회';

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    try {
      print('\n⏳ 체성분 조회 중...');
      final stat = await ApiService.instance.getLatestBodyStat(config['user_id']);

      print('\n⚖️ 최근 체성분 기록\n');
      print('━━━━━━━━━━━━━━━━━━━━');
      print('체중: ${stat['weight']}kg');
      if (stat['body_fat'] != null) print('체지방률: ${stat['body_fat']}%');
      if (stat['muscle_mass'] != null) print('골격근량: ${stat['muscle_mass']}kg');
      print('기록일: ${stat['date']}');
      print('');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

// ✅ 모든 체성분 기록 조회 (새로 추가)
class ListBodyStatsCommand extends Command {
  @override
  final name = 'list';
  @override
  final description = '모든 체성분 기록 조회';

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    try {
      print('\n⏳ 체성분 기록 조회 중...');
      final stats = await ApiService.instance.getAllBodyStats(config['user_id']);

      if (stats.isEmpty) {
        print('\n📝 기록된 체성분이 없습니다.\n');
        return;
      }

      print('\n⚖️ 체성분 기록 목록\n');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      for (int i = 0; i < stats.length; i++) {
        final stat = stats[i];
        final date = DateTime.parse(stat['date']);
        
        print('${i + 1}. ${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}');
        stdout.write('   체중: ${stat['weight']}kg');
        if (stat['body_fat'] != null) stdout.write(' | 체지방: ${stat['body_fat']}%');
        if (stat['muscle_mass'] != null) stdout.write(' | 골격근: ${stat['muscle_mass']}kg');
        print('');
        print('   ID: ${(stat['id'] as String).substring(0, 8)}...');
        if (i < stats.length - 1) print('');
      }
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('총 ${stats.length}개 기록\n');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

// ✅ 특정 체성분 기록 삭제 (새로 추가)
class DeleteBodyStatCommand extends Command {
  @override
  final name = 'delete';
  @override
  final description = '특정 체성분 기록 삭제';

  DeleteBodyStatCommand() {
    argParser.addOption(
      'id',
      abbr: 'i',
      help: '삭제할 기록 ID',
    );
  }

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    try {
      // 먼저 목록 조회
      print('\n⏳ 체성분 기록 조회 중...');
      final stats = await ApiService.instance.getAllBodyStats(config['user_id']);

      if (stats.isEmpty) {
        print('\n📝 기록된 체성분이 없습니다.\n');
        return;
      }

      // 목록 출력
      print('\n⚖️ 체성분 기록 목록\n');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      for (int i = 0; i < stats.length; i++) {
        final stat = stats[i];
        final date = DateTime.parse(stat['date']);
        
        print('${i + 1}. ${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')} - '
              '체중: ${stat['weight']}kg');
      }
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // 삭제할 번호 입력
      stdout.write('삭제할 기록 번호 (1-${stats.length}): ');
      final indexStr = stdin.readLineSync()?.trim();
      final index = int.tryParse(indexStr ?? '');

      if (index == null || index < 1 || index > stats.length) {
        print('❌ 올바른 번호를 입력하세요.\n');
        return;
      }

      final statToDelete = stats[index - 1];
      final date = DateTime.parse(statToDelete['date']);

      // 확인
      stdout.write('\n⚠️ ${date.month}/${date.day}의 기록 (체중: ${statToDelete['weight']}kg)을 삭제하시겠습니까? (y/n): ');
      final confirm = stdin.readLineSync()?.trim().toLowerCase();
      
      if (confirm != 'y' && confirm != 'yes') {
        print('❌ 삭제가 취소되었습니다.\n');
        return;
      }

      // 삭제
      print('\n⏳ 기록 삭제 중...');
      await ApiService.instance.deleteBodyStat(statToDelete['id']);

      print('✅ 체성분 기록이 삭제되었습니다.\n');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

// ✅ 모든 체성분 기록 삭제 (새로 추가)
class ClearBodyStatsCommand extends Command {
  @override
  final name = 'clear';
  @override
  final description = '모든 체성분 기록 삭제';

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    try {
      // 먼저 기록 조회
      final stats = await ApiService.instance.getAllBodyStats(config['user_id']);

      if (stats.isEmpty) {
        print('📝 삭제할 체성분 기록이 없습니다.\n');
        return;
      }

      // 삭제할 기록 목록 표시
      print('\n⚠️ 다음 기록들이 모두 삭제됩니다:\n');
      for (final stat in stats) {
        final date = DateTime.parse(stat['date']);
        print('  • ${date.month}/${date.day} - 체중: ${stat['weight']}kg');
      }

      stdout.write('\n정말로 모든 체성분 기록을 삭제하시겠습니까? (y/n): ');
      final confirm = stdin.readLineSync()?.trim().toLowerCase();
      
      if (confirm != 'y' && confirm != 'yes') {
        print('❌ 삭제가 취소되었습니다.\n');
        return;
      }

      print('\n⏳ 모든 기록 삭제 중...');
      final result = await ApiService.instance.clearAllBodyStats(config['user_id']);

      print('✅ 모든 체성분 기록이 삭제되었습니다. (총 ${result['deleted_count']}개)\n');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}
