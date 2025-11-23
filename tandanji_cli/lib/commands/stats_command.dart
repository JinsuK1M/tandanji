import 'package:args/command_runner.dart';
import '../services/api_service.dart';
import '../services/config_service.dart';

class StatsCommand extends Command {
  @override
  final name = 'stats';
  @override
  final description = '통계 조회';

  StatsCommand() {
    argParser.addOption(
      'period',
      abbr: 'p',
      help: '기간 (weekly, monthly, yearly)',
      defaultsTo: 'weekly',
    );
  }

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    final period = argResults!['period'];

    try {
      print('\n⏳ 통계 조회 중...');
      final stats = await ApiService.instance.getWeeklyStats(config['user_id']);

      if (stats.isEmpty) {
        print('\n📊 기록된 통계가 없습니다.\n');
        return;
      }

      print('\n📊 주간 체중 변화\n');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      for (final stat in stats) {
        final date = DateTime.parse(stat['date']);
        print('${date.month}/${date.day}: ${stat['weight']}kg');
        if (stat['body_fat'] != null) print(' | 체지방: ${stat['body_fat']}%');
        if (stat['muscle_mass'] != null) print(' | 골격근: ${stat['muscle_mass']}kg');
        print('');
      }

      // 체중 변화 계산
      if (stats.length >= 2) {
        final firstWeight = stats.first['weight'] as num;
        final lastWeight = stats.last['weight'] as num;
        final change = lastWeight - firstWeight;
        
        print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('체중 변화: ${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}kg');
        print('');
      }
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}