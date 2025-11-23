import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isSignUp;
  
  const LoginScreen({super.key, this.isSignUp = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  final _signupUsernameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupPasswordConfirmController = TextEditingController();
  
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _agreeTerms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.isSignUp ? 1 : 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupUsernameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupPasswordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a0a0a), Color(0xFF1a1a2e)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildNavBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 1000) {
                        return _buildDesktopLayout();
                      } else {
                        return _buildMobileLayout();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a0a).withOpacity(0.8),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ).createShader(bounds),
              child: const Text(
                'TANDANJI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildInfoSection()),
        const SizedBox(width: 80),
        Expanded(child: _buildAuthBox()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildInfoSection(),
        const SizedBox(height: 60),
        _buildAuthBox(),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '다이어트',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 1.2),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ).createShader(bounds),
          child: const Text(
            'TANDANJI로',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
          ),
        ),
        const Text(
          '빠르게 시작',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 1.2),
        ),
        const SizedBox(height: 30),
        Text(
          '탄수화물, 단백질, 지방.\n매일 얼마나 먹어야 할지 고민되시나요?\nTANDANJI가 당신에게 맞는 영양 섭취량을 계산해드립니다.',
          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7), height: 1.6),
        ),
        const SizedBox(height: 40),
        ...[
          '개인 맞춤형 칼로리 계산',
          '탄단지 비율 자동 추천',
          '식단 기록 및 분석',
          '목표 달성 추적',
        ].map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              const Text('✓ ', style: TextStyle(color: Color(0xFF667eea), fontSize: 20, fontWeight: FontWeight.w900)),
              Text(e, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildAuthBox() {
    return Container(
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF667eea),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.5),
            labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            tabs: const [Tab(text: '로그인'), Tab(text: '회원가입')],
          ),
          const SizedBox(height: 40),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600),
            child: TabBarView(
              controller: _tabController,
              children: [_buildLoginForm(), _buildSignUpForm()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField('이메일', _loginEmailController, false),
          const SizedBox(height: 25),
          _buildTextField('비밀번호', _loginPasswordController, true),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v!),
                    fillColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                  ),
                  Text('로그인 상태 유지', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('비밀번호 찾기', style: TextStyle(color: Color(0xFF667eea), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildGradientButton('로그인', _handleLogin),
          const SizedBox(height: 30),
          _buildDivider(),
          const SizedBox(height: 30),
          _buildSocialButtons(),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField('이메일', _signupEmailController, false),
          const SizedBox(height: 25),
          _buildTextField('사용자명', _signupUsernameController, false),
          const SizedBox(height: 25),
          _buildTextField('비밀번호', _signupPasswordController, true),
          const SizedBox(height: 25),
          _buildTextField('비밀번호 확인', _signupPasswordConfirmController, true),
          const SizedBox(height: 15),
          Row(
            children: [
              Checkbox(
                value: _agreeTerms,
                onChanged: (v) => setState(() => _agreeTerms = v!),
                fillColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
              ),
              Expanded(
                child: Text('이용약관 및 개인정보 처리방침에 동의합니다', 
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildGradientButton('회원가입', _handleSignUp),
          const SizedBox(height: 30),
          _buildDivider(),
          const SizedBox(height: 30),
          _buildSocialButtons(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: '$label를 입력하세요',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text('또는', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: ['Google', 'Kakao', 'Naver'].map((name) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _buildSocialButton(name),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSocialButton(String label) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Center(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_loginEmailController.text.isEmpty || _loginPasswordController.text.isEmpty) {
      _showError('이메일과 비밀번호를 입력하세요');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_agreeTerms) {
      _showError('이용약관에 동의해주세요');
      return;
    }
    if (_signupPasswordController.text != _signupPasswordConfirmController.text) {
      _showError('비밀번호가 일치하지 않습니다');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().register(
        username: _signupUsernameController.text.trim(),
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}