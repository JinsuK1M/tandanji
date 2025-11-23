import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'body_screen.dart';
import 'meal_screen.dart';
import 'workout_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _bodyStats;
  List<dynamic> _todayMeals = [];
  List<dynamic> _todayWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final auth = context.read<AuthService>();
    final userId = auth.userId!;

    try {
      // 최근 체성분
      try {
        _bodyStats = await auth.api.getLatestBodyStat(userId);
      } catch (e) {
        // 체성분 기록이 없을 수 있음
      }

      // 오늘 식단
      try {
        _todayMeals = await auth.api.getTodayMeals(userId);
      } catch (e) {
        // 식단 기록이 없을 수 있음
      }

      // 오늘 운동
      try {
        _todayWorkouts = await auth.api.getTodayWorkouts(userId);
      } catch (e) {
        // 운동 기록이 없을 수 있음
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthService>().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tandanji'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadDashboardData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 환영 메시지
                    Text(
                      '안녕하세요, ${auth.username}님! 👋',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 빠른 액션 버튼
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            icon: Icons.monitor_weight,
                            label: '체성분',
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BodyScreen(),
                                ),
                              ).then((_) => _loadDashboardData());
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            icon: Icons.restaurant,
                            label: '식단',
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MealScreen(),
                                ),
                              ).then((_) => _loadDashboardData());
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            icon: Icons.fitness_center,
                            label: '운동',
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WorkoutScreen(),
                                ),
                              ).then((_) => _loadDashboardData());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 최근 체성분
                    _buildSectionTitle('최근 체성분'),
                    const SizedBox(height: 12),
                    _buildBodyStatsCard(),
                    const SizedBox(height: 24),

                    // 오늘 식단
                    _buildSectionTitle('오늘의 식단'),
                    const SizedBox(height: 12),
                    _buildTodayMealsCard(),
                    const SizedBox(height: 24),

                    // 오늘 운동
                    _buildSectionTitle('오늘의 운동'),
                    const SizedBox(height: 12),
                    _buildTodayWorkoutsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBodyStatsCard() {
    if (_bodyStats == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  '체성분 기록이 없습니다',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('체중', '${_bodyStats!['weight']}kg', Icons.monitor_weight),
                if (_bodyStats!['body_fat'] != null)
                  _buildStatItem('체지방률', '${_bodyStats!['body_fat']}%', Icons.pie_chart),
                if (_bodyStats!['muscle_mass'] != null)
                  _buildStatItem('골격근량', '${_bodyStats!['muscle_mass']}kg', Icons.fitness_center),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '기록일: ${_bodyStats!['date'].toString().split('T')[0]}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayMealsCard() {
    if (_todayMeals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  '오늘의 식단 기록이 없습니다',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalCalories = _todayMeals.fold<int>(
      0,
      (sum, meal) => sum + (meal['calories'] as int),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 칼로리',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalCalories kcal',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ..._todayMeals.take(3).map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${meal['meal_name']}: ${meal['food_name']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${meal['calories']} kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
            if (_todayMeals.length > 3)
              Text(
                '외 ${_todayMeals.length - 3}개',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayWorkoutsCard() {
    if (_todayWorkouts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  '오늘의 운동 기록이 없습니다',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '총 ${_todayWorkouts.length}개 운동',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ..._todayWorkouts.take(3).map((workout) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${workout['exercise_name']} - ${workout['sets']}세트 x ${workout['reps']}회',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
            if (_todayWorkouts.length > 3)
              Text(
                '외 ${_todayWorkouts.length - 3}개',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
