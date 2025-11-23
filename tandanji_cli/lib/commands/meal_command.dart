import 'dart:io';
import 'package:args/command_runner.dart';
import '../services/api_service.dart';
import '../services/config_service.dart';

class MealCommand extends Command {
  @override
  final name = 'meal';
  @override
  final description = '식단 관련 명령어 (add, list, edit, delete, clear)';

  MealCommand() {
    addSubcommand(AddMealCommand());
    addSubcommand(ListMealsCommand());
    addSubcommand(EditMealCommand());
    addSubcommand(DeleteMealCommand());
    addSubcommand(ClearMealsCommand());
  }
}

class AddMealCommand extends Command {
  @override
  final name = 'add';
  @override
  final description = '식단 추가';

  AddMealCommand() {
    argParser.addOption('meal', abbr: 'm', help: '끼니 번호 (1-4)', mandatory: true);
  }

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다. "tandanji auth login" 명령어를 실행하세요.\n');
      return;
    }

    final mealNumber = int.tryParse(argResults!['meal']);
    if (mealNumber == null || mealNumber < 1 || mealNumber > 4) {
      print('❌ 끼니 번호는 1-4 사이여야 합니다.\n');
      return;
    }

    print('\n🍽️ Meal $mealNumber 입력');
    print('음식을 추가하세요 (완료하려면 빈 줄 입력):\n');
    
    final foods = <Map<String, dynamic>>[];
    
    while (true) {
      stdout.write('음식 이름 (또는 엔터로 완료): ');
      final name = stdin.readLineSync()?.trim() ?? '';
      if (name.isEmpty) break;

      stdout.write('양(g): ');
      final amountStr = stdin.readLineSync()?.trim() ?? '';
      final amount = double.tryParse(amountStr);
      if (amount == null) {
        print('❌ 올바른 숫자를 입력하세요.');
        continue;
      }

      stdout.write('탄수화물(g): ');
      final carbsStr = stdin.readLineSync()?.trim() ?? '';
      final carbs = double.tryParse(carbsStr);
      if (carbs == null) {
        print('❌ 올바른 숫자를 입력하세요.');
        continue;
      }

      stdout.write('단백질(g): ');
      final proteinStr = stdin.readLineSync()?.trim() ?? '';
      final protein = double.tryParse(proteinStr);
      if (protein == null) {
        print('❌ 올바른 숫자를 입력하세요.');
        continue;
      }

      stdout.write('지방(g): ');
      final fatStr = stdin.readLineSync()?.trim() ?? '';
      final fat = double.tryParse(fatStr);
      if (fat == null) {
        print('❌ 올바른 숫자를 입력하세요.');
        continue;
      }

      foods.add({
        'name': name,
        'amount': amount,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
      });

      print('✅ $name 추가됨\n');
    }

    if (foods.isEmpty) {
      print('❌ 음식이 추가되지 않았습니다.\n');
      return;
    }

    try {
      print('⏳ 식단 저장 중...');
      await ApiService.instance.addMeal(
        userId: config['user_id'],
        name: 'Meal $mealNumber',
        mealNumber: mealNumber,
        foods: foods,
      );

      print('\n✅ Meal $mealNumber이 추가되었습니다!\n');
      
      final totalCarbs = foods.fold(0.0, (sum, food) => sum + (food['carbs'] as num));
      final totalProtein = foods.fold(0.0, (sum, food) => sum + (food['protein'] as num));
      final totalFat = foods.fold(0.0, (sum, food) => sum + (food['fat'] as num));
      final totalCalories = (totalCarbs * 4) + (totalProtein * 4) + (totalFat * 9);
      
      print('📊 영양소 합계:');
      print('  탄수화물: ${totalCarbs.toStringAsFixed(1)}g');
      print('  단백질: ${totalProtein.toStringAsFixed(1)}g');
      print('  지방: ${totalFat.toStringAsFixed(1)}g');
      print('  칼로리: ${totalCalories.toStringAsFixed(0)}kcal\n');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

class ListMealsCommand extends Command {
  @override
  final name = 'list';
  @override
  final description = '오늘의 식단 조회';

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    try {
      print('\n⏳ 식단 조회 중...');
      final meals = await ApiService.instance.getTodayMeals(config['user_id']);

      if (meals.isEmpty) {
        print('\n📝 오늘 등록된 식단이 없습니다.\n');
        return;
      }

      print('\n🍽️ 오늘의 식단\n');
      
      double totalCarbs = 0, totalProtein = 0, totalFat = 0;

      for (final meal in meals) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('${meal['name']} (Meal ${meal['meal_number']})');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        for (final food in meal['foods']) {
          print('  • ${food['name']} ${food['amount']}g');
          print('    탄: ${food['carbs']}g | 단: ${food['protein']}g | 지: ${food['fat']}g');
          
          totalCarbs += (food['carbs'] as num);
          totalProtein += (food['protein'] as num);
          totalFat += (food['fat'] as num);
        }
        print('');
      }

      final totalCalories = (totalCarbs * 4) + (totalProtein * 4) + (totalFat * 9);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 오늘의 총 영양소');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('  탄수화물: ${totalCarbs.toStringAsFixed(1)}g');
      print('  단백질: ${totalProtein.toStringAsFixed(1)}g');
      print('  지방: ${totalFat.toStringAsFixed(1)}g');
      print('  칼로리: ${totalCalories.toStringAsFixed(0)}kcal\n');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

class EditMealCommand extends Command {
  @override
  final name = 'edit';
  @override
  final description = '식단 수정 (음식 추가/삭제)';

  EditMealCommand() {
    argParser.addOption('meal', abbr: 'm', help: '끼니 번호 (1-4)', mandatory: true);
  }

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    final mealNumber = int.tryParse(argResults!['meal']);
    if (mealNumber == null || mealNumber < 1 || mealNumber > 4) {
      print('❌ 끼니 번호는 1-4 사이여야 합니다.\n');
      return;
    }

    try {
      print('\n⏳ 식단 조회 중...');
      final meals = await ApiService.instance.getTodayMeals(config['user_id']);
      
      final currentMeal = meals.cast<Map<String, dynamic>>().firstWhere(
        (meal) => meal['meal_number'] == mealNumber,
        orElse: () => {},
      );

      if (currentMeal.isEmpty) {
        print('❌ Meal $mealNumber이 존재하지 않습니다. 먼저 추가해주세요.\n');
        return;
      }

      final foods = List<Map<String, dynamic>>.from(currentMeal['foods']);

      while (true) {
        print('\n🍽️ Meal $mealNumber 수정\n');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        if (foods.isEmpty) {
          print('  (음식 없음)');
        } else {
          for (int i = 0; i < foods.length; i++) {
            final food = foods[i];
            print('  ${i + 1}. ${food['name']} ${food['amount']}g');
            print('     탄: ${food['carbs']}g | 단: ${food['protein']}g | 지: ${food['fat']}g');
          }
        }
        
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        print('옵션:');
        print('  1. 음식 추가');
        print('  2. 음식 삭제');
        print('  3. 저장하고 종료');
        print('  4. 취소\n');

        stdout.write('선택 (1-4): ');
        final choice = stdin.readLineSync()?.trim();

        switch (choice) {
          case '1':
            stdout.write('\n음식 이름: ');
            final name = stdin.readLineSync()?.trim() ?? '';
            if (name.isEmpty) continue;

            stdout.write('양(g): ');
            final amount = double.tryParse(stdin.readLineSync()?.trim() ?? '');
            if (amount == null) {
              print('❌ 올바른 숫자를 입력하세요.');
              continue;
            }

            stdout.write('탄수화물(g): ');
            final carbs = double.tryParse(stdin.readLineSync()?.trim() ?? '');
            if (carbs == null) {
              print('❌ 올바른 숫자를 입력하세요.');
              continue;
            }

            stdout.write('단백질(g): ');
            final protein = double.tryParse(stdin.readLineSync()?.trim() ?? '');
            if (protein == null) {
              print('❌ 올바른 숫자를 입력하세요.');
              continue;
            }

            stdout.write('지방(g): ');
            final fat = double.tryParse(stdin.readLineSync()?.trim() ?? '');
            if (fat == null) {
              print('❌ 올바른 숫자를 입력하세요.');
              continue;
            }

            foods.add({
              'name': name,
              'amount': amount,
              'carbs': carbs,
              'protein': protein,
              'fat': fat,
            });
            print('✅ $name 추가됨');
            break;

          case '2':
            if (foods.isEmpty) {
              print('❌ 삭제할 음식이 없습니다.');
              break;
            }

            stdout.write('\n삭제할 음식 번호 (1-${foods.length}): ');
            final indexStr = stdin.readLineSync()?.trim();
            final index = int.tryParse(indexStr ?? '');

            if (index == null || index < 1 || index > foods.length) {
              print('❌ 올바른 번호를 입력하세요.');
              break;
            }

            final removedFood = foods.removeAt(index - 1);
            print('✅ ${removedFood['name']} 삭제됨');
            break;

          case '3':
            print('\n⏳ 저장 중...');
            await ApiService.instance.updateMeal(
              userId: config['user_id'],
              mealNumber: mealNumber,
              name: 'Meal $mealNumber',
              foods: foods,
            );

            print('✅ Meal $mealNumber이 수정되었습니다!\n');
            
            final totalCarbs = foods.fold(0.0, (sum, food) => sum + (food['carbs'] as num));
            final totalProtein = foods.fold(0.0, (sum, food) => sum + (food['protein'] as num));
            final totalFat = foods.fold(0.0, (sum, food) => sum + (food['fat'] as num));
            final totalCalories = (totalCarbs * 4) + (totalProtein * 4) + (totalFat * 9);
            
            print('📊 영양소 합계:');
            print('  탄수화물: ${totalCarbs.toStringAsFixed(1)}g');
            print('  단백질: ${totalProtein.toStringAsFixed(1)}g');
            print('  지방: ${totalFat.toStringAsFixed(1)}g');
            print('  칼로리: ${totalCalories.toStringAsFixed(0)}kcal\n');
            return;

          case '4':
            print('❌ 수정이 취소되었습니다.\n');
            return;

          default:
            print('❌ 1-4 사이의 숫자를 입력하세요.');
        }
      }
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

class DeleteMealCommand extends Command {
  @override
  final name = 'delete';
  @override
  final description = '오늘의 식단 삭제';

  DeleteMealCommand() {
    argParser.addOption(
      'meal', 
      abbr: 'm', 
      help: '삭제할 끼니 번호 (1-4)', 
      mandatory: true
    );
  }

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    final mealNumber = int.tryParse(argResults!['meal']);
    if (mealNumber == null || mealNumber < 1 || mealNumber > 4) {
      print('❌ 끼니 번호는 1-4 사이여야 합니다.\n');
      return;
    }

    stdout.write('\n⚠️ Meal $mealNumber을(를) 정말 삭제하시겠습니까? (y/n): ');
    final confirm = stdin.readLineSync()?.trim().toLowerCase();
    
    if (confirm != 'y' && confirm != 'yes') {
      print('❌ 삭제가 취소되었습니다.\n');
      return;
    }

    try {
      print('\n⏳ 식단 삭제 중...');
      await ApiService.instance.deleteTodayMeal(
        config['user_id'], 
        mealNumber
      );

      print('✅ Meal $mealNumber이 삭제되었습니다.\n');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}

class ClearMealsCommand extends Command {
  @override
  final name = 'clear';
  @override
  final description = '오늘의 모든 식단 삭제';

  @override
  Future<void> run() async {
    final config = await ConfigService.instance.loadConfig();
    if (config == null) {
      print('❌ 로그인이 필요합니다.\n');
      return;
    }

    try {
      final meals = await ApiService.instance.getTodayMeals(config['user_id']);
      
      if (meals.isEmpty) {
        print('📝 오늘 등록된 식단이 없습니다.\n');
        return;
      }

      print('\n⚠️ 다음 식단들이 삭제됩니다:\n');
      for (final meal in meals) {
        print('  • Meal ${meal['meal_number']} - ${(meal['foods'] as List).length}개 음식');
      }

      stdout.write('\n정말로 오늘의 모든 식단을 삭제하시겠습니까? (y/n): ');
      final confirm = stdin.readLineSync()?.trim().toLowerCase();
      
      if (confirm != 'y' && confirm != 'yes') {
        print('❌ 삭제가 취소되었습니다.\n');
        return;
      }

      print('\n⏳ 모든 식단 삭제 중...');
      
      int deletedCount = 0;
      for (int i = 1; i <= 4; i++) {
        try {
          await ApiService.instance.deleteTodayMeal(config['user_id'], i);
          deletedCount++;
        } catch (e) {
          // 해당 끼니가 없으면 무시
        }
      }

      print('✅ 오늘의 모든 식단이 삭제되었습니다. (총 $deletedCount개)\n');
    } catch (e) {
      print('\n❌ $e\n');
    }
  }
}