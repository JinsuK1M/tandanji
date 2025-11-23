import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealNameController = TextEditingController();
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  
  List<dynamic> _meals = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showAllMeals = false;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    final auth = context.read<AuthService>();
    try {
      final meals = _showAllMeals
          ? await auth.api.getAllMeals(auth.userId!)
          : await auth.api.getTodayMeals(auth.userId!);
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final auth = context.read<AuthService>();
      await auth.api.addMeal(
        userId: auth.userId!,
        mealName: _mealNameController.text,
        foodName: _foodNameController.text,
        calories: int.parse(_caloriesController.text),
        protein: _proteinController.text.isEmpty
            ? null
            : double.parse(_proteinController.text),
        carbs: _carbsController.text.isEmpty
            ? null
            : double.parse(_carbsController.text),
        fat: _fatController.text.isEmpty
            ? null
            : double.parse(_fatController.text),
      );

      _mealNameController.clear();
      _foodNameController.clear();
      _caloriesController.clear();
      _proteinController.clear();
      _carbsController.clear();
      _fatController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 식단 기록이 추가되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMeals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _meals.fold<int>(
      0,
      (sum, meal) => sum + (meal['calories'] as int),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('식단 관리'),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showAllMeals = !_showAllMeals;
                _isLoading = true;
              });
              _loadMeals();
            },
            icon: Icon(
              _showAllMeals ? Icons.today : Icons.calendar_month,
              color: Colors.white,
            ),
            label: Text(
              _showAllMeals ? '오늘' : '전체',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMeals,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 칼로리 요약
                    if (_meals.isNotEmpty)
                      Card(
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '총 칼로리',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$totalCalories kcal',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // 입력 폼
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '새 식단 추가',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _mealNameController,
                                decoration: const InputDecoration(
                                  labelText: '식사명 (예: 아침, 점심, 저녁) *',
                                  prefixIcon: Icon(Icons.schedule),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '식사명을 입력하세요';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _foodNameController,
                                decoration: const InputDecoration(
                                  labelText: '음식명 *',
                                  prefixIcon: Icon(Icons.restaurant),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '음식명을 입력하세요';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _caloriesController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: '칼로리 (kcal) *',
                                  prefixIcon: Icon(Icons.local_fire_department),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '칼로리를 입력하세요';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return '올바른 숫자를 입력하세요';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _proteinController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: '단백질(g)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _carbsController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: '탄수화물(g)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fatController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: '지방(g)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _handleSubmit,
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('기록 추가'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 기록 목록
                    Text(
                      _showAllMeals ? '전체 기록' : '오늘의 식단',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_meals.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.restaurant_menu,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '기록된 식단이 없습니다',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _meals.length,
                        itemBuilder: (context, index) {
                          final meal = _meals[index];
                          final date = DateTime.parse(meal['date']);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Text(
                                  '${meal['calories']}'.length > 3
                                      ? '${meal['calories']}'.substring(0, 3)
                                      : '${meal['calories']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${meal['meal_name']}: ${meal['food_name']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('칼로리: ${meal['calories']} kcal'),
                                  if (meal['protein'] != null ||
                                      meal['carbs'] != null ||
                                      meal['fat'] != null)
                                    Text(
                                      '영양소: '
                                      '${meal['protein'] != null ? "단백질 ${meal['protein']}g" : ""}'
                                      '${meal['carbs'] != null ? " 탄수화물 ${meal['carbs']}g" : ""}'
                                      '${meal['fat'] != null ? " 지방 ${meal['fat']}g" : ""}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  Text(
                                    '${date.month}/${date.day} '
                                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
