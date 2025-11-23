import 'dart:io';
import 'dart:convert';

class ConfigService {
  static final ConfigService instance = ConfigService._();
  ConfigService._();

  final String configPath = '${Platform.environment['HOME']}/.tandanji_config.json';

  Future<void> saveUserId(String userId, String name) async {
    final file = File(configPath);
    await file.writeAsString(jsonEncode({
      'user_id': userId,
      'name': name,
    }));
  }

  Future<Map<String, dynamic>?> loadConfig() async {
    final file = File(configPath);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return jsonDecode(content);
  }

  Future<void> clearConfig() async {
    final file = File(configPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}